"""Behavior tests for per-character plans, candidate comparison and focused exports."""
import unittest
from lupa.lua51 import LuaRuntime
from test_addon import ADDON, MOCK


class WorkflowTests(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(MOCK)
        for name in ('Core.lua', 'Progress.lua', 'Advice.lua', 'Inventory.lua', 'Loadouts.lua', 'Workflow.lua', 'UI.lua', 'ToolUI.lua', 'PlannerUI.lua', 'AdviceUI.lua', 'Minimap.lua'):
            self.lua.execute('assert(loadstring(...))("ForeverContext", NS)', (ADDON / name).read_text(encoding='utf-8'))
        self.ns = self.lua.globals().NS

    def plan(self, text):
        result = self.ns.ParsePlan(text)
        if isinstance(result, tuple):
            self.fail(result[1])
        return result

    def test_plan_format_handles_all_supported_goals(self):
        plan = self.plan('FCPLAN/1\nTITLE|My plan\nLEVEL|25|Level up\nSKILL|186|75|Mining\nSLOT|1|Helmet\nTALENT|10|5|Talent\nITEM|12345|Sword\nGOLD|10|Save gold\nMANUAL|Visit a dungeon')
        self.assertEqual(len(plan.tasks), 7)
        self.assertEqual(plan.title, 'My plan')
        self.assertEqual(plan.tasks[2].id, 186)

    def test_plan_parser_rejects_invalid_or_executable_input_without_side_effects(self):
        invalid = ['print("run")', 'FCPLAN/2\nMANUAL|Task', 'FCPLAN/1\nSLOT|20|Invalid slot',
                   'FCPLAN/1\nSKILL|-1|75|Invalid', 'FCPLAN/1\nTALENT|10|1.5|Invalid',
                   'FCPLAN/1\nMANUAL|', 'FCPLAN/1\nLEVEL|25|Label|extra',
                   'FCPLAN/1\nUNKNOWN|Task', 'FCPLAN/1\nGOLD|1e9|Invalid', 'x' * 24001]
        for text in invalid:
            with self.subTest(text=text[:40]):
                plan, error = self.ns.ParsePlan(text)
                self.assertIsNone(plan)
                self.assertTrue(error)
        self.assertIsNone(self.lua.globals().hacked)
        self.assertIsNone(self.ns.CharacterState().plan)

    def test_fenced_plan_and_task_limit(self):
        plan = self.plan('```text\nFCPLAN/1\r\nMANUAL|Revisar talentos\n```')
        self.assertEqual(plan.tasks[1].label, 'Revisar talentos')
        self.assertEqual(len(self.plan('FCPLAN/1\n' + '\n'.join('MANUAL|Task' for _ in range(32))).tasks), 32)
        result, _ = self.ns.ParsePlan('FCPLAN/1\n' + '\n'.join('MANUAL|Task' for _ in range(33)))
        self.assertIsNone(result)

    def test_automatic_goals_transition_from_pending_to_done(self):
        self.lua.execute('''
            skillRank = 49
            C_TradeSkillUI.GetProfessionInfoBySkillLineID = function(id) return {skillLevel=skillRank, maxSkillLevel=75} end
            C_SkillInfo.GetSkillLineInfoByID = function(id) if id == 186 then return {name='Mining',rank=skillRank} end end
        ''')
        plan = self.plan('FCPLAN/1\nSKILL|186|75|Mining 75\nLEVEL|25|Level 25\nSLOT|1|Helmet\nTALENT|10|5|Talent rank 5\nITEM|12345|Equip sword\nGOLD|20|Hold 20 gold')
        self.ns.AcceptPlan(plan)
        before = self.ns.CaptureSnapshot()
        self.assertEqual(self.ns.EvaluateTask(plan.tasks[1], before)[0], 'PENDING')
        self.assertEqual(self.ns.EvaluateTask(plan.tasks[5], before)[0], 'DONE')
        self.lua.execute('''
            skillRank = 75
            UnitLevel = function() return 25 end
            GetMoney = function() return 200000 end
            local original = GetInventoryItemID
            GetInventoryItemID = function(unit, slot) return slot == 1 and 9876 or original(unit, slot) end
            local nodes = C_Traits.GetNodeInfo
            C_Traits.GetNodeInfo = function(config,id) local n=nodes(config,id); if id==10 then n.activeEntry.rank=5 end; return n end
        ''')
        after = self.ns.CaptureSnapshot()
        for index in range(1, 7):
            self.assertEqual(self.ns.EvaluateTask(plan.tasks[index], after)[0], 'DONE')

    def test_unknown_and_unapplied_data_never_completes_goals(self):
        plan = self.plan('FCPLAN/1\nSKILL|99999|1|Unknown skill\nSLOT|1|Helmet\nTALENT|10|1|Talent\nITEM|9999|Unknown item')
        self.ns.AcceptPlan(plan)
        self.lua.execute('GetInventoryItemID=function() error("unavailable") end; staged=true')
        snapshot = self.ns.CaptureSnapshot()
        for index in range(1, 5):
            self.assertEqual(self.ns.EvaluateTask(plan.tasks[index], snapshot)[0], 'UNKNOWN')

    def test_bonus_talent_ranks_do_not_count_as_committed_points(self):
        self.lua.execute('local old=C_Traits.GetNodeInfo; C_Traits.GetNodeInfo=function(c,id) local n=old(c,id); n.ranksIncreased=10; return n end')
        task = self.plan('FCPLAN/1\nTALENT|10|5|Commit rank 5').tasks[1]
        status, detail = self.ns.EvaluateTask(task, self.ns.CaptureSnapshot())
        self.assertEqual(status, 'PENDING')
        self.assertEqual(detail, '3/5')

    def test_manual_tasks_require_player_check_and_automatic_tasks_cannot_be_overridden(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nMANUAL|Visit dungeon\nLEVEL|99|Level 99'))
        self.assertTrue(self.ns.MarkManualTask(1, True))
        self.assertFalse(self.ns.MarkManualTask(2, True))
        text = self.ns.ProgressText(self.ns.CaptureSnapshot())
        self.assertIn('[DONE] Visit dungeon', text)
        self.assertIn('[PENDING] Level 99', text)

    def test_preview_does_not_replace_plan_and_acceptance_copies_input(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nTITLE|Original\nMANUAL|Old task'))
        draft = self.plan('FCPLAN/1\nTITLE|Replacement\nMANUAL|New task')
        self.assertEqual(self.ns.CharacterState().plan.title, 'Original')
        self.ns.AcceptPlan(draft)
        draft.tasks[1].label = 'Changed draft'
        self.assertEqual(self.ns.CharacterState().plan.tasks[1].label, 'New task')
        self.assertEqual(self.ns.CharacterState().history[1].title, 'Original')

    def test_reference_snapshot_is_frozen_while_last_generated_report_advances(self):
        first = self.ns.CaptureSnapshot()
        self.ns.CommitExport(first)
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nLEVEL|26|Reach 26'))
        self.lua.execute('UnitLevel=function() return 26 end; GetMoney=function() return 200000 end')
        now = self.ns.CaptureSnapshot()
        self.ns.CommitExport(now)
        first.level = 100
        text = self.ns.ProgressText(now)
        self.assertIn('Level: 24 -> 26', text)
        self.assertIn('[DONE] Reach 26', text)
        self.assertEqual(self.ns.CharacterState().plan.baseline.level, 24)
        self.assertEqual(self.ns.CharacterState().lastExport.level, 26)

    def test_archives_are_bounded_and_clear_preserves_previous_plan(self):
        for index in range(4):
            self.ns.AcceptPlan(self.plan(f'FCPLAN/1\nTITLE|Plan {index}\nMANUAL|Task'))
        self.assertEqual(len(self.ns.CharacterState().history), 2)
        self.ns.ClearPlan()
        self.assertIsNone(self.ns.CharacterState().plan)
        self.assertEqual(self.ns.CharacterState().history[1].title, 'Plan 3')

    def test_state_and_goals_are_separate_for_each_character(self):
        self.lua.execute('ForeverContextDB={goal="Old goal",extended=false}; NS.CharacterSettings().goal="Character one"')
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nMANUAL|One task'))
        self.lua.execute('firstCharacter=ForeverContextCharacterDB; ForeverContextCharacterDB=nil')
        self.assertEqual(self.ns.CharacterSettings().goal, 'Old goal')
        self.assertIsNone(self.ns.CharacterState().plan)
        self.lua.execute('NS.CharacterSettings().goal="Character two"; ForeverContextCharacterDB=firstCharacter')
        self.assertEqual(self.ns.CharacterSettings().goal, 'Character one')
        self.assertEqual(len(self.ns.CharacterState().plan.tasks), 1)

    def test_changes_do_not_treat_unknown_equipment_as_empty(self):
        before = self.ns.CaptureSnapshot()
        self.ns.CommitExport(before)
        self.lua.execute('GetInventoryItemID=function() error("unknown") end')
        text = self.ns.ProgressText(self.ns.CaptureSnapshot())
        self.assertNotIn('item 12345 -> item 0', text)

    def test_focused_exports_include_relevant_sections(self):
        options = self.lua.table_from({'mode': 'talents', 'extended': True})
        report, _, _ = self.ns.BuildReport(options)
        self.assertIn('KNOWN SPELLS', report)
        self.assertNotIn('=== ACTIVE QUESTS ===', report)
        self.assertNotIn('=== EQUIPMENT AND ITEM DETAILS ===', report)
        options.mode = 'gear'
        report, _, _ = self.ns.BuildReport(options)
        self.assertIn('=== EQUIPMENT AND ITEM DETAILS ===', report)
        self.assertNotIn('=== KNOWN SPELLS ===', report)
        options.mode, options.extended = 'session', False
        report, _, _ = self.ns.BuildReport(options)
        self.assertIn('=== ACTIVE QUESTS ===', report)
        self.assertIn('Plan a practical next play session', report)

    def test_item_link_validation_preserves_variants_and_rejects_other_inputs(self):
        reference = self.ns.SetCandidate('A', '|cff00ff00|Hitem:12345:678:901:902:0:0:44:0:24:0:0|h[Name]|h|r')
        self.assertEqual(reference, 'item:12345:678:901:902:0:0:44:0:24:0:0')
        for invalid in ('https://example.com/item/123', 'spell:123', 'hello', 'item:0', 'item:123:--', 'x'*2049):
            result, _ = self.ns.NormalizeItem(invalid)
            self.assertIsNone(result)
        self.assertEqual(self.ns.NormalizeItem('12345'), 'item:12345')

    def ready_comparison(self):
        self.lua.execute('''
            C_Item.GetItemInfo=function(reference) return 'Candidate',reference,2,25,20,'Weapon','Sword',1,'INVTYPE_WEAPON' end
            candidateQueries={}
            C_TooltipInfo.GetHyperlink=function(reference)
                table.insert(candidateQueries,reference)
                return {lines={{leftText='Effect for ' .. reference}}}
            end
        ''')
        self.ns.SetCandidate('A', 'item:12345:678:901:902:0:0:44:0:24:0:0')
        self.ns.SetCandidate('B', 'item:12345:999:901:902:0:0:44:0:24:0:0')

    def test_comparison_export_contains_two_exact_variants_and_character_context(self):
        self.ready_comparison()
        report, pending, warnings, _ = self.ns.BuildExport(self.lua.table_from({'mode':'compare', 'extended':False, 'goal':'Solo leveling'}))
        self.assertIn('Candidate A:', report)
        self.assertIn('Candidate B:', report)
        self.assertIn('item:12345:678:', report)
        self.assertIn('item:12345:999:', report)
        self.assertIn('Solo leveling', report)
        self.assertIn('=== TALENTS ===', report)
        self.assertIn('not a recalculated hypothetical loadout', report)
        self.assertEqual((pending, warnings), (0, 0))
        self.assertEqual(len(self.lua.globals().candidateQueries), 2)

    def test_missing_candidates_and_base_ids_are_not_presented_as_exact_comparisons(self):
        report, _, warnings, _ = self.ns.BuildExport(self.lua.table_from({'mode':'compare'}))
        self.assertIn('Candidate A: missing', report)
        self.assertGreater(warnings, 0)
        self.ready_comparison()
        self.ns.SetCandidate('A', '12345')
        report, _, warnings, _ = self.ns.BuildExport(self.lua.table_from({'mode':'compare'}))
        self.assertIn('BASE ITEM REFERENCE', report)
        self.assertGreater(warnings, 0)

    def test_building_reports_does_not_advance_reference_until_committed(self):
        self.ns.BuildExport(self.lua.table_from({'mode':'review'}))
        self.assertIsNone(self.ns.CharacterState().lastExport)
        _, _, _, snapshot = self.ns.BuildExport(self.lua.table_from({'mode':'review'}))
        self.ns.CommitExport(snapshot)
        self.assertEqual(self.ns.CharacterState().lastExport.level, 24)

    def test_planner_ui_preview_accept_manual_checks_and_review(self):
        self.lua.execute('NS.OpenPlanWindow()')
        g = self.lua.globals()
        frame = g.ForeverContextPlanWindow
        frame.input.SetText(frame.input, 'FCPLAN/1\nTITLE|My plan\nMANUAL|Visit dungeon\nLEVEL|99|Reach 99')
        frame.previewButton.scripts.OnClick()
        self.assertIsNone(self.ns.CharacterState().plan)
        self.assertIn('DRAFT:', frame.status.value)
        self.assertTrue(frame.accept.enabled)
        frame.accept.scripts.OnClick()
        self.assertEqual(self.ns.CharacterState().plan.title, 'My plan')
        self.assertFalse(frame.rows[2].check.enabled)
        frame.rows[1].check.SetChecked(frame.rows[1].check, True)
        frame.rows[1].check.scripts.OnClick(frame.rows[1].check)
        self.assertTrue(self.ns.CharacterState().plan.tasks[1].manualDone)
        frame.review.scripts.OnClick()
        self.assertEqual(self.ns.CharacterSettings().mode, 'review')
        self.assertIn('[DONE] Visit dungeon', g.ForeverContextWindow.report)

    def test_invalid_preview_preserves_active_plan_and_disables_acceptance(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nTITLE|Keep me\nMANUAL|Task'))
        self.lua.execute('NS.OpenPlanWindow(); ForeverContextPlanWindow.input:SetText("invalid"); ForeverContextPlanWindow.previewButton.scripts.OnClick()')
        frame = self.lua.globals().ForeverContextPlanWindow
        self.assertEqual(self.ns.CharacterState().plan.title, 'Keep me')
        self.assertFalse(frame.accept.enabled)
        self.assertIn('FCPLAN/1', frame.status.value)

    def test_plan_updates_automatic_task_after_game_event(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nLEVEL|25|Level up'))
        self.lua.execute('NS.OpenPlanWindow()')
        frame = self.lua.globals().ForeverContextPlanWindow
        self.assertIn('PENDING', frame.rows[1].text.value)
        self.lua.execute('UnitLevel=function() return 25 end; dispatch("PLAYER_LEVEL_UP"); tick(0.1)')
        self.assertIn('DONE', frame.rows[1].text.value)

    def test_comparison_ui_accepts_dragged_links_and_opens_focused_report(self):
        self.ready_comparison()
        self.lua.execute('''
            function GetCursorInfo() return 'item',12345,'|Hitem:12345:678:901:902:0:0:44:0:24:0:0|h[Name]|h' end
            function ClearCursor() cursorCleared=true end
            NS.OpenComparisonWindow()
            ForeverContextComparisonWindow.dropA.scripts.OnReceiveDrag()
        ''')
        g = self.lua.globals()
        frame = g.ForeverContextComparisonWindow
        self.assertTrue(g.cursorCleared)
        self.assertIn('item:12345:678:', frame.inputs.A.value)
        frame.compare.scripts.OnClick()
        self.assertEqual(self.ns.CharacterSettings().mode, 'compare')
        self.assertIn('Candidate B:', g.ForeverContextWindow.report)

    def test_mode_buttons_preserve_edited_goal(self):
        self.lua.execute('NS.OpenReport(); ForeverContextWindow.goal:SetText("My edited goal"); ForeverContextWindow.modes.talents.scripts.OnClick()')
        frame = self.lua.globals().ForeverContextWindow
        self.assertIn('My edited goal', frame.report)
        self.assertEqual(self.ns.CharacterSettings().mode, 'talents')
        self.assertNotIn('=== EQUIPMENT AND ITEM DETAILS ===', frame.report)

    def test_combat_hides_planner_and_comparison_and_blocks_reopening(self):
        self.lua.execute('NS.OpenPlanWindow(); NS.OpenComparisonWindow(); combat=true; dispatch("PLAYER_REGEN_DISABLED"); NS.OpenPlanWindow(); NS.OpenComparisonWindow()')
        g = self.lua.globals()
        self.assertFalse(g.ForeverContextPlanWindow.shown)
        self.assertFalse(g.ForeverContextComparisonWindow.shown)

    def test_plan_pagination_updates_the_correct_manual_task(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\n' + '\n'.join(f'MANUAL|Task {i}' for i in range(1, 14))))
        self.lua.execute('NS.OpenPlanWindow(); ForeverContextPlanWindow.next.scripts.OnClick()')
        frame = self.lua.globals().ForeverContextPlanWindow
        self.assertIn('Page 2/3', frame.pages.value)
        frame.rows[1].check.SetChecked(frame.rows[1].check, True)
        frame.rows[1].check.scripts.OnClick(frame.rows[1].check)
        self.assertTrue(self.ns.CharacterState().plan.tasks[7].manualDone)
        self.assertFalse(self.ns.CharacterState().plan.tasks[1].manualDone)

    def test_modern_cursor_fallback_and_non_item_drags(self):
        self.lua.execute('''
            GetCursorInfo=function() return 'spell',123 end
            NS.OpenComparisonWindow()
            ForeverContextComparisonWindow.dropA.scripts.OnReceiveDrag()
        ''')
        self.assertIsNone(self.ns.CharacterState().candidates.A)
        self.lua.execute('''
            GetCursorInfo=nil
            C_Cursor={GetCursorItem=function() return {bag=0,slot=1} end}
            C_Item.GetItemLink=function(location) assert(location.bag==0); return 'item:12345:777' end
        ''')
        self.assertEqual(self.ns.CursorItemReference(), 'item:12345:777')

    def test_comparison_cache_retries_commit_only_the_finished_report(self):
        self.ready_comparison()
        self.lua.execute('''
            candidateReady=false
            C_TooltipInfo.GetHyperlink=function(reference)
                if candidateReady then return {lines={{leftText='Loaded candidate'}}} end
            end
            NS.OpenReport('compare')
        ''')
        frame = self.lua.globals().ForeverContextWindow
        self.assertFalse(frame.generate.enabled)
        self.assertIsNone(self.ns.CharacterState().lastExport)
        self.lua.execute('candidateReady=true; tick(0.5)')
        self.assertTrue(frame.generate.enabled)
        self.assertIn('Loaded candidate', frame.report)
        self.assertIsNotNone(self.ns.CharacterState().lastExport)

    def test_restricted_snapshot_values_are_unknown_and_build_changes_are_flagged(self):
        self.ns.CommitExport(self.ns.CaptureSnapshot())
        self.lua.execute('UnitLevel=function() return {secret=true} end; GetMoney=function() return {secret=true} end; GetBuildInfo=function() return "1.60.1","70862" end')
        snapshot = self.ns.CaptureSnapshot()
        plan = self.plan('FCPLAN/1\nLEVEL|25|Level up\nGOLD|20|Save gold')
        self.assertEqual(self.ns.EvaluateTask(plan.tasks[1], snapshot)[0], 'UNKNOWN')
        self.assertEqual(self.ns.EvaluateTask(plan.tasks[2], snapshot)[0], 'UNKNOWN')
        self.assertIn('Client build changed:', self.ns.ProgressText(snapshot))

    def test_comparison_replaces_report_and_close_restores_exact_context(self):
        self.lua.execute('NS.OpenReport(); ForeverContextWindow.goal:SetText("Keep this goal"); ForeverContextWindow.nameCheck:SetChecked(true)')
        g = self.lua.globals()
        report = g.ForeverContextWindow.report
        self.lua.execute('reference=NS.CharacterState().lastExport; ForeverContextWindow.compare.scripts.OnClick()')
        self.assertFalse(g.ForeverContextWindow.IsShown(g.ForeverContextWindow))
        self.assertFalse(g.ForeverContextExportText.IsVisible(g.ForeverContextExportText))
        self.assertTrue(g.ForeverContextComparisonWindow.IsVisible(g.ForeverContextComparisonWindow))
        self.assertFalse(g.ForeverContextExportText.focus)
        self.assertEqual(g.ForeverContextComparisonWindow.GetFrameStrata(g.ForeverContextComparisonWindow), 'FULLSCREEN_DIALOG')
        g.ForeverContextComparisonWindow.close.scripts.OnClick()
        self.assertTrue(g.ForeverContextWindow.IsShown(g.ForeverContextWindow))
        self.assertEqual(g.ForeverContextWindow.report, report)
        self.assertEqual(g.ForeverContextWindow.goal.value, 'Keep this goal')
        self.assertTrue(self.ns.CharacterSettings().includeName)
        self.assertTrue(self.lua.eval('reference == NS.CharacterState().lastExport'))

    def test_planner_replaces_report_and_retains_draft_on_return(self):
        self.lua.execute('NS.OpenReport(); ForeverContextWindow.plan.scripts.OnClick()')
        g = self.lua.globals()
        self.assertFalse(g.ForeverContextWindow.shown)
        self.assertTrue(g.ForeverContextPlanWindow.IsVisible(g.ForeverContextPlanWindow))
        self.lua.execute('''
            ForeverContextPlanWindow.input:SetText([[FCPLAN/1
MANUAL|Remember me]])
            ForeverContextPlanWindow.input.scripts.OnTextChanged(ForeverContextPlanWindow.input, true)
            ForeverContextPlanWindow.close.scripts.OnClick()
        ''')
        self.assertTrue(g.ForeverContextWindow.shown)
        self.ns.OpenPlanWindow()
        self.assertFalse(g.ForeverContextWindow.shown)
        self.assertIn('Remember me', g.ForeverContextPlanWindow.input.value)

    def test_switching_tools_never_exposes_report_until_final_close(self):
        self.lua.execute('NS.OpenReport(); NS.OpenComparisonWindow(); NS.OpenPlanWindow()')
        g = self.lua.globals()
        self.assertFalse(g.ForeverContextWindow.shown)
        self.assertFalse(g.ForeverContextComparisonWindow.shown)
        self.assertTrue(g.ForeverContextPlanWindow.shown)
        self.lua.execute('NS.OpenComparisonWindow()')
        self.assertFalse(g.ForeverContextWindow.shown)
        self.assertFalse(g.ForeverContextPlanWindow.shown)
        g.ForeverContextComparisonWindow.close.scripts.OnClick()
        self.assertTrue(g.ForeverContextWindow.shown)

    def test_tool_open_cancels_background_retry_and_return_can_refresh(self):
        self.lua.execute('itemReady=false; NS.OpenReport(); reportReference=NS.CharacterState().lastExport')
        g = self.lua.globals()
        report = g.ForeverContextWindow.report
        self.assertFalse(g.ForeverContextWindow.generate.enabled)
        self.lua.execute('NS.OpenPlanWindow(); ForeverContextPlanWindow.input:SetFocus(); itemReady=true; tick(5)')
        self.assertTrue(g.ForeverContextPlanWindow.input.focus)
        self.assertFalse(g.ForeverContextExportText.focus)
        self.assertEqual(g.ForeverContextWindow.report, report)
        self.assertTrue(self.lua.eval('reportReference == NS.CharacterState().lastExport'))
        g.ForeverContextPlanWindow.close.scripts.OnClick()
        self.assertTrue(g.ForeverContextWindow.generate.enabled)
        self.assertIn('Loading paused', g.ForeverContextWindow.status.value)
        g.ForeverContextWindow.generate.scripts.OnClick()
        self.assertFalse(g.ForeverContextWindow.loading)
        self.assertIsNotNone(self.ns.CharacterState().lastExport)

    def test_report_navigation_closes_tools_and_combat_cannot_restore_report(self):
        self.lua.execute('NS.OpenReport(); NS.OpenPlanWindow(); NS.OpenReport("gear")')
        g = self.lua.globals()
        self.assertFalse(g.ForeverContextPlanWindow.shown)
        self.assertTrue(g.ForeverContextWindow.shown)
        self.lua.execute('NS.OpenComparisonWindow(); combat=true; dispatch("PLAYER_REGEN_DISABLED")')
        self.assertFalse(g.ForeverContextComparisonWindow.shown)
        self.assertFalse(g.ForeverContextWindow.shown)
        self.lua.execute('combat=false; NS.OpenPlanWindow(); ForeverContextPlanWindow.close.scripts.OnClick()')
        self.assertFalse(g.ForeverContextWindow.shown)

    def test_tool_opened_standalone_does_not_open_report_on_close(self):
        self.lua.execute('NS.OpenComparisonWindow(); ForeverContextComparisonWindow.close.scripts.OnClick()')
        self.assertIsNone(self.lua.globals().ForeverContextWindow)

    def test_pending_equipment_is_not_an_empty_slot_or_a_removal(self):
        self.ns.CommitExport(self.ns.CaptureSnapshot())
        self.lua.execute('GetInventoryItemID=function() return nil end; GetInventoryItemLink=function() return nil end')
        snapshot = self.ns.CaptureSnapshot()
        self.assertIsNone(snapshot.slots[16])
        self.assertFalse(snapshot.equipmentReadable)
        task = self.plan('FCPLAN/1\nSLOT|16|Equip a weapon').tasks[1]
        self.assertEqual(self.ns.EvaluateTask(task, snapshot)[0], 'UNKNOWN')
        self.assertNotIn('item 12345 -> empty', self.ns.ProgressText(snapshot))
        report, pending, _, _ = self.ns.BuildExport(self.lua.table_from({'mode':'gear'}))
        self.assertIn('Main hand: occupied; data pending.', report)
        self.assertGreater(pending, 0)

    def test_readable_item_link_resolves_snapshot_when_numeric_id_is_pending(self):
        self.lua.execute('GetInventoryItemID=function() return nil end')
        snapshot = self.ns.CaptureSnapshot()
        self.assertEqual(snapshot.slots[16], 12345)
        task = self.plan('FCPLAN/1\nITEM|12345|Keep sword equipped').tasks[1]
        self.assertEqual(self.ns.EvaluateTask(task, snapshot)[0], 'DONE')

    def test_unavailable_texture_read_cannot_confirm_empty_equipment(self):
        self.lua.execute('GetInventoryItemID=function() return nil end; GetInventoryItemLink=function() return nil end; GetInventoryItemTexture=function() error("unavailable") end')
        snapshot = self.ns.CaptureSnapshot()
        self.assertIsNone(snapshot.slots[1])
        report, _, warnings, _ = self.ns.BuildExport(self.lua.table_from({'mode':'gear'}))
        self.assertIn('Head: read unavailable.', report)
        self.assertGreater(warnings, 0)

    def test_restricted_or_malformed_staged_lists_are_not_confirmed_talents(self):
        task = self.plan('FCPLAN/1\nTALENT|10|1|Commit talent').tasks[1]
        for position in range(3):
            for value in ('{secret=true}', 'false', '"unavailable"'):
                with self.subTest(position=position, value=value):
                    lists = ['nil', 'nil', 'nil']
                    lists[position] = value
                    self.lua.execute('C_Traits.GetStagedChanges=function() return ' + ','.join(lists) + ' end')
                    snapshot = self.ns.CaptureSnapshot()
                    self.assertFalse(snapshot.talentsReadable)
                    self.assertEqual(self.ns.EvaluateTask(task, snapshot)[0], 'UNKNOWN')
                    report, _, _, _ = self.ns.BuildExport(self.lua.table_from({'mode':'talents'}))
                    self.assertIn('unable to verify whether there are unapplied changes', report)
                    self.assertNotIn('[Armas] Golpe mejorado', report)

    def test_manual_task_change_marks_restored_report_stale_until_refresh(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nMANUAL|Visit dungeon'))
        self.lua.execute('NS.OpenReport(); reportReference=NS.CharacterState().lastExport; baseline=NS.CharacterState().plan.baseline; NS.OpenPlanWindow()')
        self.assertTrue(self.ns.MarkManualTask(1, True))
        g = self.lua.globals()
        g.ForeverContextPlanWindow.close.scripts.OnClick()
        self.assertIn('Context changed.', g.ForeverContextWindow.status.value)
        self.assertFalse(g.ForeverContextWindow.select.enabled)
        self.assertTrue(self.lua.eval('reportReference == NS.CharacterState().lastExport'))
        g.ForeverContextWindow.select.scripts.OnClick()
        self.assertIn('Context changed.', g.ForeverContextWindow.status.value)
        g.ForeverContextWindow.generate.scripts.OnClick()
        self.assertIn('[DONE] Visit dungeon', g.ForeverContextWindow.report)
        self.assertTrue(g.ForeverContextWindow.select.enabled)
        self.assertTrue(self.lua.eval('baseline == NS.CharacterState().plan.baseline'))
        self.lua.execute('NS.OpenPlanWindow(); NS.MarkManualTask(1,true); ForeverContextPlanWindow.close.scripts.OnClick()')
        self.assertTrue(g.ForeverContextWindow.select.enabled)

    def test_accepting_or_archiving_plan_also_invalidates_the_existing_report(self):
        self.lua.execute('NS.OpenReport(); NS.OpenPlanWindow()')
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nMANUAL|A new task'))
        g = self.lua.globals()
        g.ForeverContextPlanWindow.close.scripts.OnClick()
        self.assertFalse(g.ForeverContextWindow.select.enabled)
        g.ForeverContextWindow.generate.scripts.OnClick()
        self.lua.execute('NS.OpenPlanWindow(); NS.ClearPlan(); ForeverContextPlanWindow.close.scripts.OnClick()')
        self.assertIn('Context changed.', g.ForeverContextWindow.status.value)
        self.assertFalse(g.ForeverContextWindow.select.enabled)
        g.ForeverContextWindow.generate.scripts.OnClick()
        self.assertIn('No plan accepted.', g.ForeverContextWindow.report)

    def test_typing_draft_does_not_rescan_character_on_each_keystroke(self):
        self.lua.execute('''
            snapshotCalls=0
            local capture=NS.CaptureSnapshot
            NS.CaptureSnapshot=function(...) snapshotCalls=snapshotCalls+1; return capture(...) end
            NS.OpenPlanWindow()
            callsBeforeTyping=snapshotCalls
            for i=1,30 do
                ForeverContextPlanWindow.input:SetText(string.rep('x',i))
                ForeverContextPlanWindow.input.scripts.OnTextChanged(ForeverContextPlanWindow.input,true)
            end
        ''')
        g = self.lua.globals()
        self.assertEqual(g.snapshotCalls, g.callsBeforeTyping)
        self.assertFalse(g.ForeverContextPlanWindow.accept.enabled)
        self.assertEqual(self.ns.CharacterState().draftText, 'x' * 30)

    def test_editing_preview_discards_it_once_and_preserves_accepted_plan(self):
        self.ns.AcceptPlan(self.plan('FCPLAN/1\nMANUAL|Accepted task'))
        self.lua.execute('''
            NS.OpenPlanWindow()
            ForeverContextPlanWindow.example.scripts.OnClick()
            ForeverContextPlanWindow.previewButton.scripts.OnClick()
            snapshotCalls=0
            local capture=NS.CaptureSnapshot
            NS.CaptureSnapshot=function(...) snapshotCalls=snapshotCalls+1; return capture(...) end
            for i=1,10 do
                ForeverContextPlanWindow.input:SetText('invalid draft ' .. i)
                ForeverContextPlanWindow.input.scripts.OnTextChanged(ForeverContextPlanWindow.input,true)
            end
        ''')
        g = self.lua.globals()
        self.assertEqual(g.snapshotCalls, 1)
        self.assertFalse(g.ForeverContextPlanWindow.accept.enabled)
        self.assertTrue(g.ForeverContextPlanWindow.rows[1].check.enabled)
        self.assertEqual(self.ns.CharacterState().plan.tasks[1].label, 'Accepted task')


if __name__ == '__main__':
    unittest.main(verbosity=2)
