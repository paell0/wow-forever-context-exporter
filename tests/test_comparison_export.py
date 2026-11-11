"""Focused comparisons and literal pipe boundaries after a live-client export."""
import unittest
import test_workflow as workflow
import test_community as community


def copied_display(text):
    """Model escaped pipes and the reset token observed in the live report.

    This deliberately models only these tokens, not WoW's complete renderer.
    """
    output = []
    index = 0
    while index < len(text):
        token = text[index:index+2]
        if token == '||':
            output.append('|')
            index += 2
        elif token.lower() == '|r':
            index += 2
        else:
            output.append(text[index])
            index += 1
    return ''.join(output)


class ComparisonExportTests(unittest.TestCase):
    setUp = workflow.WorkflowTests.setUp
    plan = workflow.WorkflowTests.plan
    ready_comparison = workflow.WorkflowTests.ready_comparison
    bags_ready = community.CommunityTests.bags_ready
    profile = community.CommunityTests.profile

    def test_candidates_lead_the_report_without_losing_character_or_equipment(self):
        self.ready_comparison()
        report, pending, warnings, _ = self.ns.BuildExport(self.lua.table_from({'mode':'compare','goal':'Solo leveling'}))
        a, b = report.index('Candidate A:'), report.index('Candidate B:')
        self.assertLess(a, b)
        self.assertLess(b, report.index('=== CHARACTER ==='))
        for heading in ('TALENTS','PROFESSIONS','EQUIPMENT AND ITEM DETAILS','CHARACTER STATS','ACTIVE BUFFS'):
            self.assertIn('=== '+heading+' ===', report)
        self.assertIn('item:12345:678:', report)
        self.assertIn('item:12345:999:', report)
        self.assertIn('Solo leveling', report)
        self.assertIn('Comparison scope:', report)
        self.assertEqual(report.count('=== ITEM COMPARISON CANDIDATES ==='), 1)
        self.assertNotIn('=== FOLLOW-UP REQUEST ===', report)
        self.assertNotIn('FCPLAN/1', report)
        self.assertNotIn('No plan accepted.', report)
        self.assertNotIn('No activity profile selected.', report)
        self.assertEqual((pending,warnings), (0,0))

    def test_comparison_does_not_scan_bags_or_change_the_overview_preference(self):
        self.bags_ready()
        self.ready_comparison()
        self.ns.SetModule('bags', True)
        settings = self.ns.CharacterSettings()
        settings.mode = 'compare'
        report, _, _, _ = self.ns.BuildExport(settings)
        self.assertNotIn('=== CARRIED BAG ITEMS ===', report)
        self.assertEqual(self.lua.globals().bagReads, 0)
        self.assertTrue(settings.modules.bags)
        settings.mode = 'overview'
        report, _, _, _ = self.ns.BuildExport(settings)
        self.assertIn('=== CARRIED BAG ITEMS ===', report)
        self.assertGreater(self.lua.globals().bagReads, 0)
        self.assertTrue(settings.modules.bags)

    def test_comparison_sources_and_staleness_are_limited_to_candidate_ids(self):
        self.ready_comparison()
        self.ns.SaveItemSource('12345','Quest','Candidate source','https://example.com/candidate',False)
        self.ns.SaveItemSource('200','Vendor','Unrelated vendor','https://example.com/unrelated',False)
        for entry in self.ns.SourceRecords().values():
            if entry.record.itemID == 200:
                entry.record.build = 'old-build'
        report, _, warnings, _ = self.ns.BuildExport(self.lua.table_from({'mode':'compare'}))
        self.assertIn('Candidate source', report)
        self.assertNotIn('Unrelated vendor', report)
        self.assertNotIn('Origin NOT CONFIRMED for item 200', report)
        self.assertNotIn('source records are from another build', report)
        self.assertEqual(warnings, 0)
        for entry in self.ns.SourceRecords().values():
            if entry.record.itemID == 12345:
                entry.record.build = 'old-build'
        report, _, warnings, _ = self.ns.BuildExport(self.lua.table_from({'mode':'compare'}))
        self.assertIn('1 source records are from another build', report)
        self.assertGreater(warnings, 0)

    def test_focused_comparison_still_honors_disabled_categories_and_spoilers(self):
        self.ready_comparison()
        self.ns.SaveItemSource('12345','Dungeon','Hidden boss','https://example.com/boss',False)
        self.ns.SetModule('equipment', False)
        self.ns.SetModule('talents', False)
        self.ns.SetSpoilerFree(True)
        settings = self.ns.CharacterSettings()
        settings.mode = 'compare'
        report, _, _, _ = self.ns.BuildExport(settings)
        self.assertIn('Candidate A:', report)
        self.assertNotIn('=== EQUIPMENT AND ITEM DETAILS ===', report)
        self.assertNotIn('=== TALENTS ===', report)
        self.assertNotIn('Hidden boss', report)
        self.assertIn('Item origins withheld', report)

    def test_existing_advice_is_retained_when_it_can_affect_the_choice(self):
        self.ready_comparison()
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nMANUAL|Stay with my healing set'))
        self.ns.KeepItem('12345','Keep for healing')
        profile = self.profile()
        self.ns.SaveTalentProfile(profile)
        report, _, _, _ = self.ns.BuildExport(self.lua.table_from({'mode':'compare'}))
        self.assertIn('Stay with my healing set', report)
        self.assertIn('Keep for healing', report)
        self.assertIn('Deadmines healer', report)
        self.assertNotIn('If useful, finish with an optional plain-text plan', report)

    def test_pending_candidate_data_still_retries_before_copy_is_enabled(self):
        self.ready_comparison()
        self.lua.execute('''
            candidateReady=false
            local info=C_Item.GetItemInfo
            C_Item.GetItemInfo=function(ref)
                if ref:find('12345:999',1,true) and not candidateReady then return nil end
                return info(ref)
            end
        ''')
        self.ns.OpenReport('compare')
        frame = self.lua.globals().ForeverContextWindow
        self.assertTrue(frame.loading)
        self.assertFalse(frame.select.enabled)
        self.lua.execute('candidateReady=true; tick(0.5)')
        self.assertFalse(frame.loading)
        self.assertTrue(frame.select.enabled)
        self.assertIn('Candidate B: Candidate', frame.text.GetDisplayText(frame.text))

    def test_report_copy_preserves_the_plan_lines_seen_corrupted_in_game(self):
        self.ns.OpenReport('overview')
        frame = self.lua.globals().ForeverContextWindow
        copied = copied_display(frame.text.value)
        self.assertEqual(copied, frame.report)
        for line in ('LEVEL|26|Reach level 26','SKILL|186|75|Reach Mining 75','TALENT|104753|5|Reach committed rank 5'):
            self.assertIn(line, copied)
        block = copied.split('\nFCPLAN/1\n',1)[1].split('\nUse at most',1)[0]
        plan = self.plan('FCPLAN/1\n'+block)
        self.assertEqual(len(plan.tasks), 7)

    def test_read_only_restoration_never_double_encodes_or_corrupts_report(self):
        self.ns.OpenReport()
        frame = self.lua.globals().ForeverContextWindow
        original = frame.text.value
        frame.text.SetText(frame.text, 'Changed |Reach')
        frame.text.scripts.OnTextChanged(frame.text, True)
        self.assertEqual(frame.text.value, original)
        frame.text.scripts.OnTextChanged(frame.text, True)
        self.assertEqual(frame.text.value, original)
        self.assertEqual(copied_display(original), frame.report)
        self.lua.execute('plainBox=CreateFrame("EditBox",nil,UIParent)')
        plain = r'Literal |Reach, pairs || and backslashes \\ stay intact.'
        box = self.lua.globals().plainBox
        self.ns.SetPlainText(box, plain)
        self.assertEqual(copied_display(box.value), plain)
        self.assertEqual(self.ns.GetPlainText(box), plain)

    def test_plan_examples_and_reopened_drafts_keep_plain_protocol_separators(self):
        self.ns.OpenPlanWindow()
        frame = self.lua.globals().ForeverContextPlanWindow
        frame.example.scripts.OnClick()
        draft = self.ns.CharacterState().draftText
        self.assertEqual(copied_display(frame.input.value), draft)
        self.assertIn('MANUAL|Review my next talent point', draft)
        frame.close.scripts.OnClick()
        self.ns.OpenPlanWindow()
        self.assertEqual(copied_display(frame.input.value), draft)
        frame.previewButton.scripts.OnClick()
        self.assertTrue(frame.accept.enabled)
        self.assertEqual(frame.preview.tasks[2].label, 'Review my next talent point')

    def test_profile_copy_keeps_fields_whose_values_begin_with_r(self):
        profile = self.profile(name='Raid Ready', activity='Ranged practice')
        self.ns.SaveTalentProfile(profile)
        self.ns.OpenLoadoutsWindow()
        frame = self.lua.globals().ForeverContextLoadoutsWindow
        frame.copy.scripts.OnClick()
        copied = copied_display(frame.text.value)
        self.assertIn('NAME|Raid Ready', copied)
        self.assertIn('ACTIVITY|Ranged practice', copied)
        parsed = self.ns.ParseTalentProfile(copied)
        self.assertEqual(parsed.name, 'Raid Ready')
        frame.previewButton.scripts.OnClick()
        self.assertTrue(frame['import'].enabled)

    def test_non_equippable_client_token_does_not_expand_every_bag_tooltip(self):
        self.bags_ready()
        self.lua.execute('''
            local info=C_Item.GetItemInfo
            C_Item.GetItemInfo=function(ref)
                if ref=='item:200' then return 'Quest objective',ref,1,1,1,'Quest','Quest',20,'INVTYPE_NON_EQUIP_IGNORE' end
                return info(ref)
            end
        ''')
        self.ns.SetModule('bags', True)
        report, _, _, _ = self.ns.BuildExport(self.ns.CharacterSettings())
        self.assertIn('Bag 0, slot 2: Quest objective', report)
        self.assertNotIn('Carried item: Quest objective', report)
        self.assertIn('Carried item: Sword', report)
        self.ns.OpenBagWindow()
        frame = self.lua.globals().ForeverContextBagsWindow
        frame.gearOnly.SetChecked(frame.gearOnly, True)
        frame.gearOnly.scripts.OnClick(frame.gearOnly)
        self.assertEqual(len(frame.rows), 2)
        self.assertTrue(all(row.itemID == 100 for row in frame.rows.values()))


if __name__ == '__main__':
    unittest.main()
