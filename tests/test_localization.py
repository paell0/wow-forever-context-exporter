"""Locale detection, live UI changes and data/protocol isolation in Lua 5.1."""
import json
import re
import unittest
from pathlib import Path
import test_workflow as workflow


class LocalizationTests(unittest.TestCase):
    setUp = workflow.WorkflowTests.setUp
    plan = workflow.WorkflowTests.plan

    def test_fresh_install_uses_game_language_in_all_main_controls(self):
        self.lua.execute('ForeverContextDB={}; NS.OpenReport()')
        g = self.lua.globals()
        self.assertEqual(self.ns.GetLanguage(), 'esES')
        self.assertEqual(g.ForeverContextWindow.generate.value, 'Generar / actualizar')
        self.assertEqual(g.ForeverContextWindow.select.value, 'Seleccionar todo')
        self.assertEqual(g.ForeverContextWindow.options.value, 'Opciones de exportación')
        self.assertIn('Resumen', g.ForeverContextWindow.modes.overview.value)
        self.assertIn('CHARACTER CONTEXT', g.ForeverContextWindow.report)
        self.assertIn('Language: esES', g.ForeverContextWindow.report)

    def test_auto_aliases_and_unknown_clients_fall_back_safely(self):
        self.lua.execute('ForeverContextDB={}')
        for client, expected in [('esMX','esES'),('enGB','enUS'),('ptBR','ptBR'),('frFR','frFR'),('jaJP','enUS')]:
            with self.subTest(client=client):
                self.lua.globals().clientLocale = client
                self.lua.execute('GetLocale=function() return clientLocale end')
                self.assertEqual(self.ns.GetLanguage(), expected)
        self.lua.execute('GetLocale=nil')
        self.assertEqual(self.ns.GetLanguage(), 'enUS')

    def test_manual_override_is_account_wide_and_resettable(self):
        self.ns.SetLanguage('frFR')
        self.assertEqual(self.lua.globals().ForeverContextDB.language, 'frFR')
        self.lua.execute('ForeverContextCharacterDB=nil; NS.CharacterSettings().goal="Another character"')
        self.assertEqual(self.ns.GetLanguage(), 'frFR')
        self.ns.SetLanguage('AUTO')
        self.assertEqual(self.ns.GetLanguage(), 'esES')
        self.ns.SetLanguage('ESMX')
        self.assertEqual(self.ns.GetLanguage(), 'esES')
        self.lua.globals().ForeverContextDB.language = 'unsupported-saved-setting'
        self.assertEqual(self.ns.GetLanguage(), 'esES')

    def test_invalid_selection_does_not_replace_the_previous_choice(self):
        self.ns.SetLanguage('deDE')
        result, error = self.ns.SetLanguage('run arbitrary code')
        self.assertIsNone(result)
        self.assertTrue(error)
        self.assertEqual(self.ns.GetLanguage(), 'deDE')

    def test_switching_language_updates_existing_widgets_without_new_snapshot(self):
        self.lua.execute('NS.OpenReport(); originalReport=ForeverContextWindow.report; originalSnapshot=NS.CharacterState().lastExport; NS.OpenPreferencesWindow()')
        version = self.ns.ProgressVersion()
        self.ns.SetLanguage('esES')
        g = self.lua.globals()
        self.assertEqual(g.ForeverContextWindow.plan.value, 'Plan de progreso')
        self.assertEqual(g.ForeverContextOptionsWindow.languageLabel.value, 'Idioma')
        self.assertEqual(self.ns.ProgressVersion(), version)
        g.ForeverContextOptionsWindow.close.scripts.OnClick()
        self.assertTrue(g.ForeverContextWindow.select.enabled)
        self.assertTrue(self.lua.eval('originalReport == ForeverContextWindow.report and originalSnapshot == NS.CharacterState().lastExport'))

    def test_picker_has_auto_and_ten_languages_and_returns_to_options(self):
        self.ns.OpenReport()
        self.ns.OpenPreferencesWindow()
        self.lua.globals().ForeverContextOptionsWindow.language.scripts.OnClick()
        g = self.lua.globals()
        picker = g.ForeverContextLanguageWindow
        self.assertEqual(len(list(picker.choices.keys())), 11)
        self.assertFalse(g.ForeverContextWindow.shown)
        self.assertFalse(g.ForeverContextOptionsWindow.shown)
        picker.choices.esES.scripts.OnClick()
        self.assertFalse(picker.shown)
        self.assertTrue(g.ForeverContextOptionsWindow.shown)
        self.assertIn('Español', g.ForeverContextOptionsWindow.language.value)
        self.assertEqual(g.ForeverContextWindow.select.value, 'Seleccionar todo')

    def test_user_text_and_import_buffers_are_never_translated(self):
        text = 'FCPLAN/1\nTITLE|Next\nMANUAL|Generate / refresh'
        self.lua.execute('NS.OpenReport(); ForeverContextWindow.goal:SetText("Select all"); NS.OpenPlanWindow()')
        frame = self.lua.globals().ForeverContextPlanWindow
        frame.input.SetText(frame.input, text)
        frame.input.scripts.OnTextChanged(frame.input, True)
        self.ns.SetLanguage('esES')
        self.assertEqual(frame.input.value, text)
        self.assertEqual(self.ns.CharacterState().draftText, text)
        self.assertEqual(self.ns.CharacterSettings().goal, 'Select all')
        frame.previewButton.scripts.OnClick()
        frame.accept.scripts.OnClick()
        self.assertEqual(self.ns.CharacterState().plan.title, 'Next')
        self.assertEqual(self.ns.CharacterState().plan.tasks[1].label, 'Generate / refresh')

    def test_candidate_names_and_item_references_are_not_ui_translation_keys(self):
        self.lua.execute("C_Item.GetItemInfo=function(ref) return 'Next',ref end")
        self.ns.SetCandidate('A', 'item:12345:678:901:902:0:0:44:0:24:0:0')
        self.ns.SetLanguage('esES')
        self.ns.OpenComparisonWindow()
        frame = self.lua.globals().ForeverContextComparisonWindow
        self.assertEqual(frame.names.A.value, 'Next')
        self.assertIn('item:12345:678:901:902:', frame.inputs.A.value)
        self.assertEqual(frame.dropA.value, 'Arrastrar objeto A')
        self.ns.SetLanguage('frFR')
        self.assertEqual(frame.names.A.value, 'Next')

    def test_validation_errors_translate_dynamic_line_numbers(self):
        self.ns.SetLanguage('esES')
        self.ns.OpenPlanWindow()
        frame = self.lua.globals().ForeverContextPlanWindow
        frame.input.SetText(frame.input, 'FCPLAN/1\nMANUAL|Valid\nWRONG|Task')
        frame.previewButton.scripts.OnClick()
        self.assertEqual(frame.status.value, 'Campos no válidos en la línea 3.')
        self.assertFalse(frame.accept.enabled)
        frame.input.SetText(frame.input, 'not a plan')
        frame.previewButton.scripts.OnClick()
        self.assertIn('FCPLAN/1', frame.status.value)

    def test_source_kind_translation_does_not_change_stored_values(self):
        self.ns.SetLanguage('esES')
        self.ns.OpenSourcesWindow()
        frame = self.lua.globals().ForeverContextSourcesWindow
        self.assertEqual(frame.kind.value, 'Mazmorra')
        frame.item.SetText(frame.item, '12345')
        frame.location.SetText(frame.location, 'Next / Select all')
        frame.reference.SetText(frame.reference, 'https://example.com/forever/12345')
        frame.save.scripts.OnClick()
        record = self.ns.SourceRecords()[1].record
        self.assertEqual(record.kind, 'Dungeon')
        self.assertEqual(record.location, 'Next / Select all')
        self.assertIn('Next / Select all', frame.text.value)
        self.assertIn('Registrado:', frame.text.value)
        frame.load.scripts.OnClick()
        frame.item.SetText(frame.item, '67890')
        self.ns.SetLanguage('frFR')
        self.assertEqual(frame.item.value, '67890')
        self.assertIn('Donjon', frame.text.value)
        self.assertNotIn('Mazmorra', frame.text.value)
        self.assertIn('Next / Select all', frame.text.value)

    def test_cleared_candidates_stay_empty_after_language_change(self):
        self.ns.SetCandidate('A', '12345')
        self.ns.OpenComparisonWindow()
        frame = self.lua.globals().ForeverContextComparisonWindow
        frame.clear.scripts.OnClick()
        self.ns.SetLanguage('esES')
        self.assertEqual(frame.names.A.value, '')
        self.assertEqual(frame.inputs.A.value, '')

    def test_keep_rows_preserve_item_names_and_player_reasons_on_switch(self):
        self.lua.execute("C_Item.GetItemInfo=function(ref) return 'Next',ref end")
        self.ns.KeepItem('12345', 'Select all')
        self.ns.OpenKeepWindow()
        frame = self.lua.globals().ForeverContextKeepWindow
        original = frame.rows[1].text.value
        self.ns.SetLanguage('esES')
        self.assertEqual(frame.rows[1].text.value, original)
        self.assertIn('Next', original)
        self.assertIn('Select all', original)

    def test_drag_status_localizes_and_refreshes_without_rewriting_item(self):
        self.lua.execute('GetCursorInfo=function() return "item",12345,"item:12345:678" end')
        self.ns.OpenKeepWindow()
        frame = self.lua.globals().ForeverContextKeepWindow
        frame.drop.scripts.OnReceiveDrag()
        self.ns.SetLanguage('esES')
        self.assertEqual(frame.status.value, self.ns.L('Item selected. Review the fields, then save.'))
        self.assertNotEqual(frame.status.value, 'Item selected. Review the fields, then save.')
        self.assertIn('12345', frame.item.value)

    def test_catalogs_are_complete_and_preserve_placeholders_commands_and_protocol(self):
        directory = Path(workflow.ADDON).parent / 'locales'
        base = json.loads((directory/'enUS.json').read_text(encoding='utf-8'))
        tokens = re.compile(r'\{\d+\}|FCPLAN/1|FCLOADOUT/1|ForeverContext|WoW Forever|Ctrl\+[CV]')
        for row in self.ns.LocaleOptions.values():
            locale = row[1]
            if locale == 'auto':
                continue
            values = json.loads((directory/f'{locale}.json').read_text(encoding='utf-8'))
            self.assertEqual(set(values), set(base))
            for key, value in values.items():
                self.assertEqual(sorted(tokens.findall(key)), sorted(tokens.findall(value)), (locale,key))
                self.assertNotIn('FCTOKEN', value)
                self.assertNotIn('FCNEWLINE', value)

    def test_every_locale_builds_all_windows_using_original_client_api_names(self):
        openers = ('OpenReport','OpenPlanWindow','OpenComparisonWindow','OpenPreferencesWindow','OpenBagWindow','OpenKeepWindow','OpenSourcesWindow','OpenLoadoutsWindow','OpenLanguageWindow')
        for row in self.ns.LocaleOptions.values():
            if row[1] == 'auto':
                continue
            with self.subTest(locale=row[1]):
                self.ns.SetLanguage(row[1])
                for name in openers:
                    getattr(self.ns,name)()
                g = self.lua.globals()
                self.assertEqual(g.ForeverContextScroll.kind, 'ScrollFrame')
                self.assertEqual(g.ForeverContextScroll.template, 'UIPanelScrollFrameTemplate')
                self.assertIn('FCPLAN/1', self.ns.PlanInstructions)

    def test_cjk_and_cyrillic_fonts_preserve_size_and_restore_client_font(self):
        self.ns.OpenReport()
        font = self.lua.globals().ForeverContextWindow.generate.labelFont
        original = font.GetFont(font)
        for locale, path in [('zhCN','ARKai_T.ttf'),('zhTW','blei00d.TTF'),('koKR','2002.TTF'),('ruRU','FRIZQT___CYR.TTF')]:
            self.ns.SetLanguage(locale)
            self.assertTrue(font.fontFile.endswith(path))
            self.assertEqual(font.fontHeight, original[1])
        self.ns.SetLanguage('enUS')
        self.assertEqual(font.GetFont(font), original)
        self.ns.OpenLanguageWindow()
        native = self.lua.globals().ForeverContextLanguageWindow.choices.koKR.labelFont
        self.assertTrue(native.fontFile.endswith('2002.TTF'))

    def test_selector_respects_combat_and_language_setting_survives_default_reset(self):
        self.ns.SetLanguage('frFR')
        self.ns.OpenPreferencesWindow()
        self.lua.globals().ForeverContextOptionsWindow.defaults.scripts.OnClick()
        self.assertEqual(self.ns.GetLanguage(), 'frFR')
        self.lua.execute('combat=true; dispatch("PLAYER_REGEN_DISABLED"); NS.OpenLanguageWindow()')
        self.assertIsNone(self.lua.globals().ForeverContextLanguageWindow)
        self.assertFalse(self.lua.globals().ForeverContextOptionsWindow.shown)

    def test_language_command_and_unknown_key_fallback(self):
        self.lua.globals().SlashCmdList.FOREVER_CONTEXT('language esES')
        self.assertEqual(self.ns.GetLanguage(), 'esES')
        self.assertEqual(self.ns.L('A new untranslated label {1}', 'value'), 'A new untranslated label value')
        self.lua.globals().SlashCmdList.FOREVER_CONTEXT('language auto')
        self.assertEqual(self.lua.globals().ForeverContextDB.language, 'auto')
        self.lua.globals().SlashCmdList.FOREVER_CONTEXT('language')
        self.assertTrue(self.lua.globals().ForeverContextLanguageWindow.shown)


if __name__ == '__main__':
    unittest.main(verbosity=2)
