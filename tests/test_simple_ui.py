"""Beginner workflows, progressive settings and bounded AI-reply extraction."""
import unittest
import test_workflow as workflow


class SimpleUITests(unittest.TestCase):
    setUp = workflow.WorkflowTests.setUp
    plan = workflow.WorkflowTests.plan

    def test_main_footer_has_two_copy_steps_and_optional_navigation(self):
        self.ns.OpenReport()
        frame = self.lua.globals().ForeverContextWindow
        self.assertTrue(frame.generate.enabled)
        self.assertTrue(frame.select.enabled)
        self.assertIn('Ctrl+C', frame.copyHelp.value)
        self.assertIn('Ctrl+V', frame.copyHelp.value)
        self.assertEqual(frame.tools.value, 'More tools')
        self.assertEqual(frame.options.value, 'Settings')
        for old in ('plan','compare','bags','keep','sources','loadouts'):
            self.assertIsNone(frame[old])
        frame.select.scripts.OnClick()
        self.assertTrue(frame.text.selected)
        self.assertIn('CHARACTER CONTEXT', frame.text.value)

    def test_every_explained_hub_action_returns_to_the_original_report(self):
        self.ns.OpenReport()
        g = self.lua.globals()
        original = g.ForeverContextWindow.report
        self.lua.execute('reference=NS.CharacterState().lastExport')
        routes = {'compare':'Comparison','plan':'Plan','bags':'Bags','keep':'Keep','sources':'Sources','loadouts':'Loadouts'}
        for key, suffix in routes.items():
            with self.subTest(tool=key):
                g.ForeverContextWindow.tools.scripts.OnClick()
                hub = g.ForeverContextToolsWindow
                self.assertTrue(hub.shown)
                self.assertFalse(g.ForeverContextWindow.shown)
                self.assertTrue(hub.descriptions[key].value)
                hub.actions[key].scripts.OnClick()
                self.assertFalse(hub.shown)
                target = g['ForeverContext'+suffix+'Window']
                self.assertTrue(target.shown)
                target.close.scripts.OnClick()
                self.assertTrue(g.ForeverContextWindow.shown)
                self.assertEqual(g.ForeverContextWindow.report, original)
                self.assertTrue(self.lua.eval('reference==NS.CharacterState().lastExport'))

    def test_hub_and_detailed_settings_close_in_combat_without_restoring_report(self):
        self.lua.globals().SlashCmdList.FOREVER_CONTEXT('tools')
        self.assertTrue(self.lua.globals().ForeverContextToolsWindow.shown)
        self.ns.OpenPreferencesWindow()
        self.lua.globals().ForeverContextOptionsWindow.details.scripts.OnClick()
        g = self.lua.globals()
        self.assertFalse(g.ForeverContextToolsWindow.shown)
        self.assertFalse(g.ForeverContextOptionsWindow.shown)
        self.assertTrue(g.ForeverContextDetailsWindow.shown)
        self.lua.execute('combat=true; dispatch("PLAYER_REGEN_DISABLED"); NS.OpenToolsWindow(); NS.OpenDetailedPreferencesWindow()')
        self.assertFalse(g.ForeverContextDetailsWindow.shown)
        self.assertFalse(g.ForeverContextToolsWindow.shown)
        self.assertIsNone(g.ForeverContextWindow)

    def test_basic_settings_do_not_reset_existing_advanced_choices(self):
        self.ns.SetModule('equipment', False)
        self.lua.execute('NS.AdviceState().options.observeSources=false')
        version = self.ns.ProgressVersion()
        self.ns.OpenPreferencesWindow()
        g = self.lua.globals()
        self.assertIsNone(g.ForeverContextOptionsWindow.checks)
        self.assertIsNone(g.ForeverContextDetailsWindow)
        self.assertEqual(self.ns.ProgressVersion(), version)
        g.ForeverContextOptionsWindow.details.scripts.OnClick()
        details = g.ForeverContextDetailsWindow
        self.assertFalse(details.checks.equipment.checked)
        self.assertFalse(details.observe.checked)
        self.assertEqual(len(list(details.checks.keys())), 16)
        self.assertEqual(self.ns.ProgressVersion(), version)

    def test_bag_choice_stays_in_sync_between_basic_and_advanced_settings(self):
        self.ns.OpenPreferencesWindow()
        basic = self.lua.globals().ForeverContextOptionsWindow
        basic.bags.SetChecked(basic.bags, True)
        basic.bags.scripts.OnClick(basic.bags)
        basic.details.scripts.OnClick()
        advanced = self.lua.globals().ForeverContextDetailsWindow
        self.assertTrue(advanced.checks.bags.checked)
        advanced.checks.bags.SetChecked(advanced.checks.bags, False)
        advanced.checks.bags.scripts.OnClick(advanced.checks.bags)
        advanced.back.scripts.OnClick()
        self.assertFalse(basic.bags.checked)
        self.assertTrue(basic.shown)
        self.assertFalse(advanced.shown)

    def test_full_ai_reply_accepts_one_fenced_plan_with_prose_and_other_code(self):
        for fence in ('```','~~~','````'):
            with self.subTest(fence=fence):
                text = 'Advice first.\n```lua\nprint("never run")\n```\n'+fence+'text\nFCPLAN/1\nTITLE|Next\nMANUAL|Select all\n'+fence+'\nFinal explanation.'
                plan = self.ns.ParsePlanReply(text)
                self.assertEqual(plan.title, 'Next')
                self.assertEqual(plan.tasks[1].label, 'Select all')
        self.assertIsNone(self.ns.CharacterState().plan)

    def test_plain_and_crlf_plan_replies_keep_the_original_protocol(self):
        for text in ('FCPLAN/1\nMANUAL|Task', '\ufeffIntro\r\n```text\r\nFCPLAN/1\r\nMANUAL|Task\r\n```\r\nEnd'):
            plan = self.ns.ParsePlanReply(text)
            self.assertEqual(plan.tasks[1].kind, 'MANUAL')
            self.assertEqual(plan.tasks[1].label, 'Task')

    def test_multiple_plans_are_rejected_without_selecting_one_silently(self):
        text = '```\nFCPLAN/1\nMANUAL|One\n```\nOr:\n```\nFCPLAN/1\nMANUAL|Two\n```'
        plan, message = self.ns.ParsePlanReply(text)
        self.assertIsNone(plan)
        self.assertIn('More than one', message)
        self.assertIsNone(self.ns.CharacterState().plan)

    def test_incomplete_or_invalid_embedded_plans_are_not_partially_accepted(self):
        invalid = ['Intro\n```\nFCPLAN/1\nMANUAL|Unclosed',
                   'Intro\n```\nFCPLAN/1\nMANUAL|Valid\nWRONG|Invalid\n```\nEnd',
                   'Intro\nFCPLAN/1\nMANUAL|Valid\nProse is not a task',
                   '```\nFCPLAN/1\nMANUAL|Valid\nhacked=true\n```',
                   '```\nFCPLAN/1\n'+'MANUAL|Task\n'*33+'```',
                   'x'*24001]
        for text in invalid:
            with self.subTest(text=text[:60]):
                plan, message = self.ns.ParsePlanReply(text)
                self.assertIsNone(plan)
                self.assertTrue(message)
        self.assertIsNone(self.lua.globals().hacked)
        self.assertIsNone(self.ns.CharacterState().plan)

    def test_plan_reply_preview_keeps_saved_plan_until_explicit_acceptance(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nTITLE|Old\nMANUAL|Keep old task'))
        self.ns.OpenPlanWindow()
        frame = self.lua.globals().ForeverContextPlanWindow
        text = 'My recommendation:\n```text\nFCPLAN/1\nTITLE|New\nMANUAL|Visit a dungeon\n```\nHave fun.'
        frame.input.SetText(frame.input, text)
        frame.input.scripts.OnTextChanged(frame.input, True)
        frame.previewButton.scripts.OnClick()
        self.assertTrue(frame.accept.enabled)
        self.assertFalse(frame.clear.shown)
        self.assertEqual(self.ns.CharacterState().plan.title, 'Old')
        self.assertEqual(frame.input.value, text)
        frame.accept.scripts.OnClick()
        self.assertEqual(self.ns.CharacterState().plan.title, 'New')
        self.assertFalse(frame.accept.enabled)
        self.assertTrue(frame.clear.shown)
        self.assertFalse(frame.previous.shown)
        self.assertFalse(frame.next.shown)

    def test_comparison_steps_validate_typed_links_without_requiring_enter(self):
        self.ns.OpenComparisonWindow()
        frame = self.lua.globals().ForeverContextComparisonWindow
        self.assertFalse(frame.compare.enabled)
        self.assertIn('first item', frame.guide.value)
        a = 'item:12345:678:901:902:0:0:44:0:24:0:0'
        b = 'item:98765:888:0:0:0:0:0:0:24:0:0'
        frame.inputs.A.SetText(frame.inputs.A, a)
        self.assertFalse(frame.compare.enabled)
        self.assertIn('second item', frame.guide.value)
        frame.inputs.B.SetText(frame.inputs.B, b)
        self.assertTrue(frame.compare.enabled)
        self.assertIn('Ready.', frame.guide.value)
        frame.compare.scripts.OnClick()
        self.assertEqual(self.ns.CharacterState().candidates.A, a)
        self.assertEqual(self.ns.CharacterState().candidates.B, b)
        self.assertIn('CANDIDATE', self.lua.globals().ForeverContextWindow.report)

    def test_clearing_or_invalidating_an_item_disables_comparison_again(self):
        self.ns.SetCandidate('A','12345')
        self.ns.SetCandidate('B','98765')
        self.ns.OpenComparisonWindow()
        frame = self.lua.globals().ForeverContextComparisonWindow
        self.assertTrue(frame.compare.enabled)
        frame.inputs.B.SetText(frame.inputs.B, 'https://example.com/item/1')
        self.assertFalse(frame.compare.enabled)
        self.assertIn('not a website URL', frame.names.B.value)
        frame.clear.scripts.OnClick()
        self.assertFalse(frame.compare.enabled)
        self.assertEqual(frame.inputs.A.value, '')
        self.assertIsNone(self.ns.CharacterState().candidates.A)


if __name__ == '__main__':
    unittest.main()
