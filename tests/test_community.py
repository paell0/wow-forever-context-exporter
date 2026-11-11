"""Integration checks for the seven community-requested workflows.

Fixtures follow Forever's generated Container, Item and SharedTraits contracts.
These checks cannot replace live-client UI verification.
"""
import unittest
import test_workflow as workflow


class CommunityTests(unittest.TestCase):
    setUp = workflow.WorkflowTests.setUp
    plan = workflow.WorkflowTests.plan

    def report(self, **options):
        settings = self.ns.CharacterSettings()
        for key, value in options.items():
            settings[key] = value
        return self.ns.BuildExport(settings)

    def bags_ready(self):
        self.lua.execute('''
            NUM_BAG_SLOTS=4
            bagReads=0
            bagItems={
                {itemID=100,hyperlink='|Hitem:100:7:0:0:0:0:0:0:24|h[Sword]|h',stackCount=1,itemName='Sword',quality=2},
                {itemID=200,hyperlink='item:200',stackCount=10,itemName='Ore',quality=1},
                {itemID=300,hyperlink='item:300',stackCount=2,itemName='Unknown value',quality=1},
                {itemID=100,hyperlink='item:100:8:0:0:0:0:0:0:24',stackCount=1,itemName='Other sword',quality=2},
            }
            C_Container={
                GetContainerNumSlots=function(bag)
                    assert(bag>=0 and bag<=4,'Bank or mail must not be scanned')
                    bagReads=bagReads+1
                    return bag==0 and #bagItems or 0
                end,
                GetContainerItemInfo=function(bag,slot) assert(bag==0); return bagItems[slot] end,
            }
            local oldInfo=C_Item.GetItemInfo
            C_Item.GetItemInfo=function(ref)
                local id=tonumber(tostring(ref):match('item:(%d+)'))
                if id==100 then return 'Sword',ref,2,25,20,'Weapon','Sword',1,'INVTYPE_WEAPON',1,150,2,7,1,0,nil,false end
                if id==200 then return 'Ore',ref,1,1,1,'Trade Goods','Metal',20,'',1,25,7,7,0,0,nil,true end
                if id==300 then return 'Unknown value',ref,1,1,1,'Miscellaneous','Other',20,'' end
                return oldInfo(ref)
            end
            C_TooltipInfo.GetHyperlink=function(ref) return {lines={{leftText='Visible carried item effect'}}} end
        ''')

    def profile(self, name='Deadmines healer', activity='Deadmines - healing'):
        self.lua.execute("C_Traits.GenerateImportString=function(config) assert(config==2020); return 'ABCdef123+/=' end")
        result = self.ns.CaptureTalentProfile(name, activity)
        self.assertNotIsInstance(result, tuple)
        return result

    def test_bags_are_opt_in_and_not_scanned_by_default(self):
        self.bags_ready()
        report, _, _, _ = self.report()
        self.assertNotIn('=== CARRIED BAG ITEMS ===', report)
        self.assertEqual(self.lua.globals().bagReads, 0)
        self.ns.SetModule('bags', True)
        report, _, _, _ = self.report()
        self.assertIn('=== CARRIED BAG ITEMS ===', report)
        self.assertGreater(self.lua.globals().bagReads, 0)

    def test_bag_export_preserves_variants_quantities_effects_and_reagents(self):
        self.bags_ready()
        self.ns.SetModule('bags', True)
        report, _, _, _ = self.report()
        for text in ('item:100:7:', 'item:100:8:', 'quantity 10', 'crafting reagent: yes',
                     'Visible carried item effect', 'Vendor sell price per item: 25 copper'):
            self.assertIn(text, report)
        self.assertIn('Vendor sell price per item: UNKNOWN', report)
        self.assertNotIn('Vendor sell price per item: 0 copper', report)

    def test_missing_or_restricted_bag_data_is_unknown_not_empty(self):
        self.ns.SetModule('bags', True)
        report, _, warnings, _ = self.report()
        self.assertIn('inventory is unknown, not empty', report)
        self.assertGreater(warnings, 0)
        self.bags_ready()
        self.lua.execute('C_Container.GetContainerItemInfo=function() return {secret=true} end')
        report, _, warnings, _ = self.report()
        self.assertIn('slot 1: data unavailable', report)
        self.assertNotIn('No carried items observed.', report)

    def test_bag_metadata_failure_retains_reference_and_unknown_price(self):
        self.bags_ready()
        self.lua.execute('C_Item.GetItemInfo=function() return nil end')
        rows, _ = self.ns.ReadBags()
        text, pending, _ = self.ns.BagItemText(rows[1], self.ns.CharacterSettings(), False)
        self.assertIn('item:100:7:', text)
        self.assertIn('UNKNOWN', text)
        self.assertGreater(pending, 0)

    def test_keep_preferences_cover_all_variants_and_reason(self):
        self.bags_ready()
        self.ns.KeepItem('item:100:999', 'For my healing set')
        self.ns.SetModule('bags', True)
        report, _, _, _ = self.report()
        self.assertEqual(report.count('KEEP / ALL COPIES: For my healing set'), 2)
        self.assertIn('Do not suggest selling, destroying, disenchanting, or consuming', report)
        self.assertTrue(self.ns.RemoveKeepItem('100'))
        self.assertNotIn('For my healing set', self.report()[0])

    def test_keep_limit_validation_and_character_separation(self):
        for i in range(1, 101):
            self.assertEqual(self.ns.KeepItem(str(i), 'Reserved'), i)
        result, message = self.ns.KeepItem('101', 'Overflow')
        self.assertIsNone(result)
        self.assertIn('100', message)
        self.assertEqual(self.ns.KeepItem('100', 'Updated'), 100)
        self.lua.execute('first=ForeverContextCharacterDB; ForeverContextCharacterDB=nil')
        self.assertEqual(len(self.ns.SortedIDs(self.ns.AdviceState().keepItems)), 0)
        self.lua.execute('ForeverContextCharacterDB=first')
        self.assertEqual(len(self.ns.SortedIDs(self.ns.AdviceState().keepItems)), 100)

    def test_source_notes_confirmation_reference_and_build_are_distinct(self):
        self.bags_ready()
        self.ns.SaveItemSource('100', 'Dungeon', 'Dungeon A / Boss A', 'https://example.com/forever/item/100', False)
        text = self.ns.SourceText(100, self.ns.CharacterSettings())
        self.assertIn('UNCONFIRMED', text)
        self.assertIn('https://example.com/forever/item/100', text)
        self.assertIn('build 70790', text)
        self.ns.SaveItemSource('100', 'Dungeon', 'Dungeon A / Boss A', 'https://example.com/forever/item/100', True)
        self.assertIn('PLAYER-CONFIRMED', self.ns.SourceText(100, self.ns.CharacterSettings()))
        self.lua.execute('GetBuildInfo=function() return "1.60.2","70999",nil,16001 end')
        text = self.ns.SourceText(100, self.ns.CharacterSettings())
        self.assertIn('PLAYER-CONFIRMED / OUTDATED / RECHECK', text)
        self.assertIn('build 70790', text)

    def test_invalid_sources_do_not_replace_existing_records(self):
        self.ns.SaveItemSource('100', 'Quest', 'Quest 1', '', False)
        for kind, place, url in [('Bad', 'X', ''), ('Quest', '', ''), ('Quest', 'X', 'javascript:run()'), ('Quest', 'X', 'http://example.com')]:
            with self.subTest(kind=kind, place=place, url=url):
                result, _ = self.ns.SaveItemSource('100', kind, place, url, True)
                self.assertIsNone(result)
        self.assertEqual(len(self.ns.SourceRecords()), 1)
        self.assertIn('Origin NOT CONFIRMED', self.ns.SourceText(999, self.ns.CharacterSettings()))

    def test_merchants_are_observed_as_offers_not_owned_items(self):
        self.lua.execute('''
            MerchantFrame=CreateFrame('Frame')
            local playerName=UnitName
            UnitName=function(unit) if unit=='npc' then return 'Vendor Test' end; return playerName(unit) end
            GetMerchantNumItems=function() return 1 end
            GetMerchantItemLink=function(index) assert(index==1); return 'item:100' end
            dispatch('MERCHANT_SHOW')
        ''')
        text = self.ns.SourceText(100, self.ns.CharacterSettings())
        self.assertIn('OBSERVED IN GAME', text)
        self.assertIn('Vendor Test', text)
        self.assertIn('merchant offer', text)
        version = self.ns.ProgressVersion()
        self.lua.execute('dispatch("MERCHANT_UPDATE")')
        self.assertEqual(self.ns.ProgressVersion(), version)

    def test_quest_observations_preserve_quest_id_and_choice_semantics(self):
        self.lua.execute('''
            QuestFrame=CreateFrame('Frame')
            GetQuestID=function() return 777 end
            GetNumQuestRewards=function() return 1 end
            GetNumQuestChoices=function() return 1 end
            GetQuestItemLink=function(kind,index) assert(index==1); return kind=='choice' and 'item:100' or 'item:200' end
            dispatch('QUEST_COMPLETE')
        ''')
        text = self.ns.SourceText(100, self.ns.CharacterSettings())
        self.assertIn('Quest 777', text)
        self.assertIn('choice shown', text)
        self.assertIn('not a completion or ownership claim', text)
        self.assertEqual(len(self.ns.SourceRecords()), 2)

    def test_disabled_observation_and_closed_windows_do_not_refresh_old_offers(self):
        self.lua.execute('''
            QuestFrame=CreateFrame('Frame'); QuestFrame:Hide()
            GetQuestID=function() return 777 end
            GetNumQuestRewards=function() return 1 end
            GetQuestItemLink=function() return 'item:100' end
        ''')
        self.assertEqual(self.ns.ObserveQuestSources(), 0)
        self.ns.AdviceState().options.observeSources = False
        self.lua.execute('dispatch("QUEST_COMPLETE")')
        self.assertEqual(len(self.ns.SourceRecords()), 0)

    def test_source_notebook_export_includes_future_candidates_without_equipping(self):
        self.ns.SaveItemSource('99999', 'Profession', 'Known recipe', 'https://example.com/recipe/999', False)
        report, _, _, _ = self.report(mode='sources')
        self.assertIn('Known recipe', report)
        self.assertIn('UNCONFIRMED', report)
        self.assertNotIn('Known recipe', self.report(mode='overview')[0])

    def test_build_change_flags_plan_and_sources_without_rewriting_references(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nMANUAL|Review build'))
        self.ns.SaveItemSource('12345', 'Vendor', 'Old source', '', True)
        self.lua.execute('baseline=NS.CharacterState().plan.baseline; GetBuildInfo=function() return "1.60.2","70999",nil,16001 end')
        report, _, warnings, _ = self.report()
        self.assertIn('PLAN OUTDATED / RECHECK', report)
        self.assertIn('source records are from another build', report)
        self.assertGreater(warnings, 0)
        self.assertTrue(self.ns.ReviewPlanForBuild())
        report = self.report()[0]
        self.assertNotIn('PLAN OUTDATED / RECHECK', report)
        self.assertIn('source records are from another build', report)
        self.assertTrue(self.lua.eval('baseline == NS.CharacterState().plan.baseline'))

    def test_talent_profiles_roundtrip_all_nodes_choices_and_native_code(self):
        profile = self.profile()
        encoded = self.ns.TalentProfileText(profile)
        self.assertIn('FCLOADOUT/1', encoded)
        self.assertIn('NODE|10|3|100', encoded)
        self.assertIn('NATIVE|ABCdef123+/=', encoded)
        parsed = self.ns.ParseTalentProfile(encoded)
        self.assertEqual(parsed.nodes[10].rank, 3)
        self.assertEqual(parsed.nodes[10].entry, 100)
        self.assertTrue(self.ns.SaveTalentProfile(parsed))
        self.assertEqual(self.ns.AdviceState().selectedTalentProfile, profile.name)

    def test_talent_profiles_reject_executable_invalid_and_duplicate_data(self):
        valid = self.ns.TalentProfileText(self.profile())
        invalid = ['print("execute")', 'x'*40001, valid+'\nNODE|10|1|100', valid+'\nNAME|Other',
                   valid.replace('NODE|10|3|100', 'NODE|10|3|0'), valid.replace('CLASS|WARRIOR', 'CLASS|../bad')]
        for value in invalid:
            with self.subTest(value=value[:30]):
                result, error = self.ns.ParseTalentProfile(value)
                self.assertIsNone(result)
                self.assertTrue(error)
        self.assertEqual(len(self.ns.TalentProfileNames()), 0)

    def test_staged_talents_cannot_be_saved_as_committed_profile(self):
        self.lua.execute('staged=true')
        result, error = self.ns.CaptureTalentProfile('Test', 'Dungeon')
        self.assertIsNone(result)
        self.assertIn('cannot be verified', error)

    def test_profile_comparison_reports_rank_and_selection_differences(self):
        profile = self.profile()
        profile.nodes[10].rank = 5
        profile.nodes[10].entry = 111
        self.ns.SaveTalentProfile(profile)
        report, _, _, _ = self.report(mode='talents')
        self.assertIn('activity: Deadmines - healing', report)
        self.assertIn('committed rank 3 -> target 5; entry 100 -> 111', report)
        self.assertIn('No talents have been applied', report)

    def test_profile_class_and_build_mismatches_are_explicit(self):
        profile = self.profile()
        profile.build = '1'
        self.ns.SaveTalentProfile(profile)
        self.assertIn('PROFILE OUTDATED / RECHECK', self.report()[0])
        profile['class'] = 'ROGUE'
        self.ns.SaveTalentProfile(profile)
        text = self.report()[0]
        self.assertIn('CLASS MISMATCH', text)
        self.assertNotIn('committed rank 3 -> target', text)

    def test_profile_limit_and_selection_clear(self):
        for i in range(12):
            self.assertTrue(self.ns.SaveTalentProfile(self.profile(f'Profile {i}', 'Activity')))
        result, error = self.ns.SaveTalentProfile(self.profile('Overflow', 'Activity'))
        self.assertIsNone(result)
        self.assertIn('12', error)
        self.ns.SelectTalentProfile(None)
        self.assertIn('No activity profile selected', self.report()[0])
        self.ns.OpenLoadoutsWindow()
        self.assertIsNone(self.ns.AdviceState().selectedTalentProfile)
        frame = self.lua.globals().ForeverContextLoadoutsWindow
        frame.compare.scripts.OnClick()
        self.assertTrue(frame.shown)
        self.assertIn('Select a saved profile', frame.status.value)

    def test_modules_can_disable_all_optional_report_sections(self):
        self.bags_ready()
        self.ns.KeepItem('100', 'Private keep reason')
        self.ns.SaveTalentProfile(self.profile())
        for definition in self.ns.ModuleDefinitions.values():
            self.ns.SetModule(definition[1], False)
        report, _, _, _ = self.report(extended=True)
        for section in ('=== TALENTS ===', '=== PROFESSIONS ===', '=== EQUIPMENT AND ITEM DETAILS ===',
                        '=== CHARACTER STATS ===', '=== ACTIVE BUFFS ===', '=== SUMMONED PET ===',
                        '=== ACTIVE QUESTS ===', '=== CARRIED BAG ITEMS ===', '=== ITEMS TO KEEP ===',
                        '=== ACTIVITY TALENT PROFILE ===', '=== ACCEPTED PROGRESS PLAN ==='):
            self.assertNotIn(section, report)
        self.assertNotIn('Private keep reason', report)
        self.assertIn('=== CHARACTER ===', report)
        self.assertEqual(self.lua.globals().bagReads, 0)

    def test_disabled_talent_and_equipment_modules_do_not_leak_plan_deltas(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nTALENT|10|5|Sensitive talent goal\nITEM|12345|Sensitive equipment goal'))
        self.ns.SetModule('talents', False)
        self.ns.SetModule('equipment', False)
        self.ns.SetModule('legacy', False)
        report = self.report()[0]
        self.assertNotIn('Sensitive talent goal', report)
        self.assertNotIn('Sensitive equipment goal', report)
        self.assertNotIn('=== ACTIVITY TALENT PROFILE ===', report)
        self.assertNotIn('Talent node 10:', report)
        self.assertIn('Task details withheld by export options', report)

    def test_spoiler_free_hides_quest_source_records_and_prompts_ai(self):
        self.ns.SaveItemSource('12345', 'Dungeon', 'SECRET BOSS REWARD', 'https://example.com/secret', True)
        self.lua.execute('C_QuestLog.GetInfo=function(i) return {questID=1,title="SECRET QUEST TITLE",level=24} end')
        self.ns.SetSpoilerFree(True)
        for mode in ('overview', 'session', 'sources', 'compare'):
            with self.subTest(mode=mode):
                report = self.report(mode=mode, extended=True)[0]
                self.assertNotIn('SECRET BOSS REWARD', report)
                self.assertNotIn('SECRET QUEST TITLE', report)
                self.assertNotIn('https://example.com/secret', report)
                self.assertIn('SPOILER-FREE REQUEST', report)
        self.ns.SetSpoilerFree(False)
        self.assertIn('SECRET BOSS REWARD', self.report(mode='overview')[0])

    def test_export_options_ui_persists_categories_and_marks_report_stale(self):
        self.lua.execute('NS.OpenReport(); ForeverContextWindow.options.scripts.OnClick()')
        g = self.lua.globals()
        frame = g.ForeverContextOptionsWindow
        frame.checks.bags.SetChecked(frame.checks.bags, True)
        frame.checks.bags.scripts.OnClick(frame.checks.bags)
        self.assertTrue(self.ns.ModuleEnabled(self.ns.CharacterSettings(), 'bags'))
        frame.close.scripts.OnClick()
        self.assertFalse(g.ForeverContextWindow.select.enabled)
        self.assertIn('Context changed', g.ForeverContextWindow.status.value)

    def test_bag_browser_filters_alternatives_keeps_and_selects_candidates(self):
        self.bags_ready()
        self.ns.OpenBagWindow()
        g = self.lua.globals()
        frame = g.ForeverContextBagsWindow
        frame.reason.SetText(frame.reason, 'Off spec')
        frame.keep.scripts.OnClick()
        self.assertIsNotNone(self.ns.AdviceState().keepItems[100])
        frame.unprotected.SetChecked(frame.unprotected, True)
        frame.unprotected.scripts.OnClick(frame.unprotected)
        self.assertNotIn('Sword', frame.item.value)
        frame.a.scripts.OnClick()
        self.assertEqual(self.ns.CharacterState().candidates.A, 'item:200')
        frame.next.scripts.OnClick()
        frame.b.scripts.OnClick()
        self.assertEqual(self.ns.CharacterState().candidates.B, 'item:300')
        frame.compare.scripts.OnClick()
        self.assertFalse(frame.shown)
        self.assertTrue(g.ForeverContextComparisonWindow.shown)

    def test_source_ui_requires_explicit_confirmation_and_exports_notebook(self):
        self.ns.OpenSourcesWindow()
        frame = self.lua.globals().ForeverContextSourcesWindow
        frame.item.SetText(frame.item, '100')
        frame.location.SetText(frame.location, 'Dungeon A / Boss A')
        frame.reference.SetText(frame.reference, 'https://example.com/forever/100')
        frame.save.scripts.OnClick()
        self.assertEqual(self.ns.SourceRecords()[1].record.provenance, 'UNCONFIRMED')
        frame.confirmed.SetChecked(frame.confirmed, True)
        frame.save.scripts.OnClick()
        self.assertEqual(self.ns.SourceRecords()[1].record.provenance, 'PLAYER-CONFIRMED')
        self.assertFalse(frame.confirmed.checked)
        frame.export.scripts.OnClick()
        self.assertIn('Dungeon A / Boss A', self.lua.globals().ForeverContextWindow.report)

    def test_profile_ui_capture_copy_and_comparison_preserve_navigation(self):
        self.profile()
        self.lua.execute('NS.OpenReport(); NS.OpenLoadoutsWindow()')
        g = self.lua.globals()
        frame = g.ForeverContextLoadoutsWindow
        frame.name.SetText(frame.name, 'Dungeon healer')
        frame.activity.SetText(frame.activity, 'Dungeon A')
        frame.capture.scripts.OnClick()
        frame.copy.scripts.OnClick()
        self.assertTrue(frame.text.selected)
        self.assertIn('FCLOADOUT/1', frame.text.value)
        frame.previewButton.scripts.OnClick()
        frame.compare.scripts.OnClick()
        self.assertTrue(frame.shown)
        self.assertIn('Import this preview', frame.status.value)
        frame['import'].scripts.OnClick()
        frame.native.scripts.OnClick()
        self.assertEqual(frame.text.value, 'ABCdef123+/=')
        self.assertFalse(frame['import'].enabled)
        frame.compare.scripts.OnClick()
        self.assertFalse(frame.shown)
        self.assertIn('activity: Dungeon A', g.ForeverContextWindow.report)

    def test_keep_ui_add_remove_and_pagination(self):
        for i in range(10):
            self.ns.KeepItem(str(100+i), f'Reason {i}')
        self.ns.OpenKeepWindow()
        frame = self.lua.globals().ForeverContextKeepWindow
        frame.next.scripts.OnClick()
        self.assertIn('page 2/2', frame.pages.value)
        removed = frame.rows[1].id
        frame.rows[1].remove.scripts.OnClick()
        self.assertIsNone(self.ns.AdviceState().keepItems[removed])

    def test_every_new_window_is_exclusive_restores_report_and_closes_in_combat(self):
        openers = ('OpenPreferencesWindow', 'OpenBagWindow', 'OpenKeepWindow', 'OpenSourcesWindow', 'OpenLoadoutsWindow')
        windows = ('ForeverContextOptionsWindow', 'ForeverContextBagsWindow', 'ForeverContextKeepWindow', 'ForeverContextSourcesWindow', 'ForeverContextLoadoutsWindow')
        self.ns.OpenReport()
        g = self.lua.globals()
        report = g.ForeverContextWindow.report
        for opener, name in zip(openers, windows):
            getattr(self.ns, opener)()
            self.assertFalse(g.ForeverContextWindow.shown)
            self.assertTrue(g[name].shown)
            for other in windows:
                if other != name and g[other] is not None:
                    self.assertFalse(g[other].shown)
        g[windows[-1]].close.scripts.OnClick()
        self.assertTrue(g.ForeverContextWindow.shown)
        self.assertEqual(g.ForeverContextWindow.report, report)
        self.ns.OpenSourcesWindow()
        self.lua.execute('combat=true; dispatch("PLAYER_REGEN_DISABLED")')
        self.assertFalse(g.ForeverContextWindow.shown)
        for name in windows:
            self.assertFalse(g[name].shown)

    def test_new_commands_and_default_reset(self):
        for command, name in [('options','ForeverContextOptionsWindow'),('bags','ForeverContextBagsWindow'),
                              ('keep','ForeverContextKeepWindow'),('sources','ForeverContextSourcesWindow'),('loadouts','ForeverContextLoadoutsWindow')]:
            self.lua.globals().SlashCmdList.FOREVER_CONTEXT(command)
            self.assertTrue(self.lua.globals()[name].shown)
        self.ns.SetSpoilerFree(True)
        self.ns.SetModule('bags', True)
        self.ns.OpenPreferencesWindow()
        self.lua.globals().ForeverContextOptionsWindow.defaults.scripts.OnClick()
        self.assertFalse(self.ns.CharacterSettings().spoilerFree)
        self.assertFalse(self.ns.ModuleEnabled(self.ns.CharacterSettings(), 'bags'))

    def test_impossible_imported_talent_target_is_flagged_against_client_tree(self):
        profile = self.profile()
        profile.nodes[10].rank = 99
        self.ns.SaveTalentProfile(profile)
        report, _, warnings, _ = self.report()
        self.assertIn('INVALID TARGET', report)
        self.assertGreater(warnings, 0)
        profile.nodes[10].rank = 3
        profile.nodes[10].entry = 999
        self.ns.SaveTalentProfile(profile)
        self.lua.execute('local old=C_Traits.GetNodeInfo; C_Traits.GetNodeInfo=function(c,id) local n=old(c,id); n.entryIDs={100,101}; return n end')
        self.assertIn('INVALID TARGET', self.report()[0])

    def test_one_bag_read_supplies_inventory_and_matching_sources(self):
        self.bags_ready()
        self.ns.SetModule('bags', True)
        self.ns.SaveItemSource('100', 'Vendor', 'Bag source', '', False)
        report = self.report()[0]
        self.assertIn('Bag source', report)
        self.assertEqual(self.lua.globals().bagReads, 5)

    def test_spoiler_mode_does_not_request_source_locations_in_freshness_prompt(self):
        self.ns.SetSpoilerFree(True)
        report = self.report(mode='sources')[0]
        self.assertNotIn('cite a Forever-specific reference, source location', report)
        self.assertIn('without revealing new sources', report)

    def test_bag_event_refresh_is_coalesced_and_cancelled_when_tool_closes(self):
        self.bags_ready()
        self.ns.OpenBagWindow()
        g = self.lua.globals()
        self.lua.execute('dispatch("BAG_UPDATE_DELAYED"); dispatch("BAG_UPDATE_DELAYED")')
        before = g.bagReads
        self.lua.execute('tick(0.1)')
        self.assertEqual(g.bagReads, before + 5)
        self.lua.execute('dispatch("BAG_UPDATE_DELAYED"); NS.OpenKeepWindow()')
        self.assertIsNone(g.ForeverContextBagsWindow.scripts.OnUpdate)

    def test_automatic_observation_preserves_a_current_player_reference(self):
        self.ns.SaveItemSource('100', 'Vendor', 'Vendor Test — Bosque del Ocaso', 'https://example.com/forever/vendor', True)
        self.lua.execute('''
            UnitName=function() return 'Vendor Test' end
            GetMerchantNumItems=function() return 1 end
            GetMerchantItemLink=function() return 'item:100' end
            dispatch('MERCHANT_SHOW')
        ''')
        self.assertIn('https://example.com/forever/vendor', self.ns.SourceText(100,self.ns.CharacterSettings()))

    def test_disabled_professions_do_not_reappear_through_skills_or_plan_history(self):
        self.lua.execute('''
            local old=C_SkillInfo.GetSkillLineInfoByID
            C_SkillInfo.GetSkillLineInfoByID=function(id)
                if id==186 then return {name='Private Mining',rank=120,maxRank=150,modifier=0} end
                return old(id)
            end
        ''')
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nSKILL|186|150|Private Mining target\nSKILL|43|100|Weapon practice'))
        self.ns.SetModule('professions', False)
        report = self.report(extended=True)[0]
        self.assertNotIn('Private Mining', report)
        self.assertIn('Weapon practice', report)
        self.assertIn('Espadas: 85/120', report)

    def test_disabled_skills_do_not_hide_enabled_profession_tasks(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nSKILL|186|150|Mining target\nSKILL|43|100|Weapon practice'))
        self.ns.SetModule('skills', False)
        report = self.report()[0]
        self.assertIn('Mining target', report)
        self.assertNotIn('Weapon practice', report)


if __name__ == '__main__':
    unittest.main(verbosity=2)
