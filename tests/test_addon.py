"""Exercise the addon in Lua 5.1 using documented Forever API contracts.

This is a simulated client, not a claim of in-game verification.
"""
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

from lupa.lua51 import LuaRuntime

ADDON = ROOT / 'ForeverContext'
MOCK = r'''
NS = {}
combat = false
messages = {}
requests = 0
itemReady = true
staged = false
function issecretvalue(value) return type(value) == "table" and value.secret == true end
function GetBuildInfo() return "1.60.1", "70790", "Nov 2026", 16001 end
function GetLocale() return "esES" end
function date() return "2026-11-10 12:34:56" end
function UnitName() return "PrivateName" end
function UnitClass() return "Guerrero", "WARRIOR", 1 end
function UnitRace() return "Humano", "Human" end
function UnitFactionGroup() return "Alliance", "Alianza" end
function UnitLevel(unit) return unit == "pet" and 15 or 24 end
function UnitXP() return 12345 end
function UnitXPMax() return 25000 end
function GetXPExhaustion() return 500 end
function GetRealZoneText() return "Bosque del Ocaso" end
function GetSubZoneText() return "Villa Oscura" end
function GetMoney() return 123456 end
function GetShapeshiftForm() return 1 end
function UnitHealthMax() return 1200 end
function UnitPowerType() return 1, "RAGE" end
function UnitPowerMax(_, id) return id == 0 and 0 or 100 end
function UnitStat(_, index) return 10 * index, 12 * index, 2 * index, 0 end
function UnitArmor() return 100, 250, 100, 0, 0 end
function UnitAttackPower() return 100, 30, -5 end
function UnitRangedAttackPower() return 50, 0, 0 end
function UnitDamage() return 20, 30, 5, 8 end
function UnitAttackSpeed() return 2.5, 1.8 end
function GetCritChance() return 5.25 end
function GetDodgeChance() return 3.1 end
function GetSpellBonusDamage() return 0 end
function GetSpellCritChance() return 2 end
function GetSpellBonusHealing() return 0 end
function GetManaRegen() return 2, 1 end
function UnitResistance(_, school) return 0, school * 5 end
function UnitExists(unit) return unit == "pet" and petActive or false end
function UnitCreatureFamily() return "Lobo" end
function UnitCreatureType() return "Bestia" end
function InCombatLockdown() return combat end
function GetProfessions() return nil, 22, nil, 44, 55 end
function GetProfessionInfo(index)
    assert(index == 22 or index == 44 or index == 55)
    local name = index == 22 and "Minería" or index == 44 and "Fishing" or "Cooking"
    return name, 1, index, 150, 1, 0, index == 22 and 186 or index == 44 and 356 or 185, 5
end
C_TradeSkillUI = { GetProfessionInfoBySkillLineID = function(id)
    if id == 186 then return {skillLevel = 120, maxSkillLevel = 150, skillModifier = 10} end
    return {skillLevel = 0, maxSkillLevel = 0}
end }
C_SpecializationInfo = {
    GetActiveSpecGroup = function() return 2 end,
    GetCombatConfigIDForSpecGroup = function(group) assert(group == 2); return 2020 end,
    GetSpecialization = function() return 1 end,
    GetSpecializationInfo = function() return 1491, "Guerrero", "", 1, "DAMAGER" end,
}
C_ClassTalents = { GetActiveConfigID = function() error("Do not use fallback if Forever group config exists") end }
C_Spell = {
    GetSpellInfo = function(id) return {name = id == 500 and "Golpe mejorado" or "Talento concedido"} end,
    GetSpellDescription = function(id) return "Incrementa el daño un 5%." end,
    RequestLoadSpellData = function() end,
}
C_Traits = {
    GetConfigInfo = function(id) assert(id == 2020); return {ID = id, treeIDs = {99}, name = "Activa"} end,
    GetTreeNodes = function(...) assert(select("#", ...) == 1 and (...) == 99); return {10, 11, 12, 13} end,
    GetStagedChanges = function(id) assert(id == 2020); if staged then return {10}, {}, {} end end,
    GetGroupDisplayInfoByTreeID = function(id) assert(id == 99); return {{groupID = 7, displayName = "Armas"}} end,
    GetNodeInfo = function(config, id)
        assert(config == 2020)
        if id == 10 then return {activeEntry = {entryID = 100, rank = 3}, currentRank = 3, ranksPurchased = 3, groupIDs = {7}, posX = 0, posY = 2, maxRanks = 5} end
        if id == 11 then return {activeEntry = {entryID = 101, rank = 0}, currentRank = 0, ranksPurchased = 0, groupIDs = {7}, maxRanks = 1} end
        if id == 12 then return {activeEntry = {entryID = 102, rank = 1}, currentRank = 1, ranksPurchased = 0, groupIDs = {7}, posX = 0, posY = 1, maxRanks = 1} end
        return {currentRank = 0, ranksPurchased = 0, groupIDs = {7}}
    end,
    GetEntryInfo = function(config, id) assert(config == 2020); return {definitionID = id + 1000, maxRanks = id == 100 and 5 or 1} end,
    GetDefinitionInfo = function(id) return {spellID = id == 1100 and 500 or 501} end,
    GetTreeCurrencyInfo = function(config, tree, excludeStaged)
        assert(config == 2020 and tree == 99 and excludeStaged == true)
        return {{traitCurrencyID = 23, quantity = 2, spent = 3, spentInTree = 3}}
    end,
}
ITEM_QUALITY2_DESC = "Poco común"
ITEM_MOD_STRENGTH_SHORT = "Strength"
ITEM_MOD_STAMINA_SHORT = "Stamina"
FACTION_STANDING_LABEL5 = "Amistoso"
function GetInventoryItemID(_, slot) if slot == 16 then return 12345 end end
function GetInventoryItemTexture(_, slot) if slot == 16 then return 456 end end
function GetInventoryItemLink(_, slot)
    if slot == 16 then return "|cff00ff00|Hitem:12345:678:901:902:0:0:44:0:24:0:0|h[Espada de prueba]|h|r" end
end
function GetInventoryItemDurability(slot) if slot == 16 then return 20, 40 end end
C_Item = {
    GetItemInfo = function(query)
        assert(type(query) == "string" and query:find("item:12345:678:901:902:"))
        if not itemReady then return nil end
        return "Espada de prueba", query, 2, 25, 20, "Arma", "Espada de una mano"
    end,
    GetDetailedItemLevelInfo = function() return 26 end,
    GetItemStats = function() return {ITEM_MOD_STRENGTH_SHORT = 4, ITEM_MOD_STAMINA_SHORT = 7} end,
    RequestLoadItemDataByID = function(id) assert(id == 12345); requests = requests + 1 end,
}
C_TooltipInfo = { GetInventoryItem = function(unit, slot, hide)
    assert(unit == "player" and hide == false)
    if slot == 16 and itemReady then return {lines = {
        {leftText = "|cff00ff00Espada de prueba|r"},
        {leftText = "Daño 20 - 30", rightText = "Velocidad 2.50"},
        {leftText = "+4 Strength"}, {leftText = "Equipar: mejora especial"},
    }} end
end }
C_UnitAuras = { GetAuraDataByIndex = function(unit, index, filter)
    assert(unit == "player" and filter == "HELPFUL")
    if index == 1 then return {name = "Bendición", spellId = 77, applications = 1} end
end }
Enum = { SpellBookSpellBank = {Player = 0, Pet = 1} }
C_SpellBook = {
    GetNumSpellBookSkillLines = function() return 1 end,
    GetSpellBookSkillLineInfo = function(index) assert(index == 1); return {name = "Armas", itemIndexOffset = 5, numSpellBookItems = 2} end,
    GetSpellBookItemInfo = function(index, bank)
        if bank == 1 then return {name = "Mordedura", subName = "Rango 2", spellID = 601} end
        assert(index == 6 or index == 7)
        return {name = "Golpe", subName = "Rango 3", spellID = 600, isPassive = false, isOffSpec = false}
    end,
    HasPetSpells = function() return 1 end,
}
C_SkillInfo = {
    GetNumSkillLines = function() return 1 end,
    GetSkillLineInfo = function() return {name = "Armas", isHeader = true, isCollapsed = true} end,
    GetSkillLineInfoByID = function(id)
        if id == 43 then return {skillID = 43, name = "Espadas", rank = 85, maxRank = 120, modifier = 0} end
    end,
}
C_QuestLog = {
    GetNumQuestLogEntries = function() return 2, 1 end,
    GetInfo = function(index) return index == 1 and {isHeader = true} or {questID = 123, title = "Una misión", level = 24} end,
    IsComplete = function(id) assert(id == 123); return true end,
}
C_Reputation = {
    GetNumFactions = function() return 1 end,
    GetFactionDataByIndex = function() return {factionID = 72, name = "Ventormenta", reaction = 5, currentStanding = 3500, currentReactionThreshold = 3000, nextReactionThreshold = 9000} end,
    GetFactionDataByID = function(id) return nil end,
}
SlashCmdList = {}
UISpecialFrames = {}
DEFAULT_CHAT_FRAME = {AddMessage = function(_, message) messages[#messages + 1] = message end}
frames = {}
local widget = {}
local function newWidget(name)
    local w = {scripts = {}, events = {}, shown = true, enabled = true, value = "", width = 800, height = 600, scrolel = 0}
    setmetatable(w, {__index = widget})
    if name then _G[name] = w end
    frames[#frames + 1] = w
    return w
end
function widget:SetScript(name, fn) self.scripts[name] = fn end
function widget:RegisterEvent(name) self.events[name] = true end
function widget:SetSize(w, h) self.width = w; self.height = h end
function widget:SetWidth(w) self.width = w end
function widget:SetHeight(h) self.height = h end
function widget:GetWidth() return self.width end
function widget:GetHeight() return self.height end
function widget:Hide() self.shown = false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
function widget:Show() self.shown = true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
function widget:IsShown() return self.shown end
function widget:CreateFontString() return newWidget() end
function widget:SetText(value) self.value = value; if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self, false) end end
function widget:GetText() return self.value end
function widget:SetChecked(value) self.checked = value end
function widget:GetChecked() return self.checked end
function widget:Enable() self.enabled = true end
function widget:Disable() self.enabled = false end
function widget:SetFocus() self.focus = true end
function widget:ClearFocus() self.focus = false; if self.scripts.OnEditFocusLost then self.scripts.OnEditFocusLost(self) end end
function widget:HighlightText() self.selected = true end
function widget:SetVerticalScrolel(y) self.scrolel = y end
function widget:GetVerticalScrolel() return self.scrolel end
function widget:SetScrolelChild(child) self.child = child end
for _, method in ipairs({"SetPoint", "SetFrameStrata", "SetClampedToScreen", "SetMovable", "EnableMouse", "RegisterForDrag", "StartMoving", "StopMovingOrSizing", "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor", "SetAutoFocus", "SetMaxLetters", "SetMultiLine", "SetFontObject", "SetTextInsets", "SetCursorPosition", "SetJustifyH", "SetScale"}) do
    widget[method] = function() end
end
UIParent = newWidget("UIParent")
UIParent:SetSize(1920, 1080)
function CreateFrame(kind, name, parent, template)
    local w = newWidget(name)
    if kind == "CheckButton" then w.Text = newWidget() end
    return w
end
function tick(delta)
    for _, frame in ipairs(frames) do if frame.shown and frame.scripts.OnUpdate then frame.scripts.OnUpdate(frame, delta) end end
end
function dispatch(event)
    for _, frame in ipairs(frames) do if frame.events[event] and frame.scripts.OnEvent then frame.scripts.OnEvent(frame, event) end end
end
'''


class AddonTests(unittest.TestCase):
    def setUp(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(MOCK)
        self.load('Core.lua')

    def load(self, name):
        code = (ADDON / name).read_text(encoding='utf-8')
        self.lua.execute('assert(loadstring(...))("ForeverContext", NS)', code)

    def report(self, **options):
        return self.lua.globals().NS.BuildReport(self.lua.table_from(options))

    def test_full_context_exact_equipment_and_active_config(self):
        report, pending, warnings = self.report(extended=True, goal='Subir solo')
        for text in ['Guerrero', 'Level: 24', 'Alianza', 'Subir solo', 'group 2',
                     '[Armas] Golpe mejorado: 3/5', 'Purchased ranks in Armas: 3',
                     'available 2', 'Enchant (ID): 678', 'Gems (link IDs): 901, 902',
                     'Stamina=7.00', 'Daño 20 - 30 | Velocidad 2.50', 'Equipar: mejora especial',
                     'Durability: 20/40', 'Melee attack power: 125',
                     'Minería 120/150 (bonus 10)', 'Fishing 44/150', 'Cooking 55/150',
                     'Espadas: 85/120', 'Golpe Rango 3', 'Una misión', 'Ventormenta: Amistoso',
                     'Bendición', 'Effective armor: 250']:
            self.assertIn(text, report)
        self.assertNotIn('PrivateName', report)
        self.assertNotIn('|cff', report)
        self.assertEqual(report.count('Golpe Rango 3'), 1)
        self.assertNotIn('entry 101', report)
        self.assertEqual((pending, warnings), (0, 0))

    def test_profession_holes_and_no_archeology_row(self):
        report, _, _ = self.report()
        self.assertIn('Primary 1: not learned.', report)
        self.assertIn('Primary 2: Minería', report)
        self.assertIn('Fishing: Fishing', report)
        self.assertNotIn('Archaeology', report)

    def test_unapplied_talents_cannot_be_reported_as_active(self):
        self.lua.execute('staged = true')
        report, _, warnings = self.report()
        self.assertIn('NOT EXPORTED: there are unapplied talent changes', report)
        self.assertNotIn('[Armas] Golpe mejorado', report)
        self.assertGreater(warnings, 0)

    def test_staged_state_unreadable_is_not_assumed_committed(self):
        self.lua.execute('C_Traits.GetStagedChanges = function() error("restricted") end')
        report, _, warnings = self.report()
        self.assertIn('unable to verify', report)
        self.assertNotIn('[Armas] Golpe mejorado', report)
        self.assertGreater(warnings, 0)

    def test_item_cache_pending_and_retry_request(self):
        self.lua.execute('itemReady = false')
        report, pending, _ = self.report()
        self.assertGreater(pending, 0)
        self.assertGreater(self.lua.globals().requests, 0)
        self.assertIn('Main hand: [Espada de prueba] [ID 12345]', report)
        self.assertNotIn('Main hand: empty', report)
        self.lua.execute('itemReady = true')
        _, pending, _ = self.report()
        self.assertEqual(pending, 0)

    def test_profession_and_equipment_api_failures_are_not_empty(self):
        self.lua.execute('GetProfessions = function() error("unavailable") end; GetInventoryItemID = function() error("unavailable") end')
        report, _, warnings = self.report()
        self.assertIn('Professions: read unavailable.', report)
        self.assertIn('Main hand: read unavailable.', report)
        self.assertNotIn('Primary 1: not learned.', report)
        self.assertNotIn('Main hand: empty.', report)
        self.assertGreater(warnings, 0)

    def test_missing_optional_namespaces_and_pre_talent_character(self):
        self.lua.execute('C_Traits = nil; C_ClassTalents = nil; C_SkillInfo = nil; C_Reputation = nil; C_SpellBook = nil; C_QuestLog = nil; C_UnitAuras = nil')
        report, _, warnings = self.report(extended=True)
        self.assertIn('Talents unavailable', report)
        self.assertIn('PROFESSIONS', report)
        self.assertIn('Espada de prueba', report)
        self.assertIn('REQUEST TO THE AI', report)
        self.assertGreater(warnings, 0)

    def test_privacy_opt_in_and_markup_cleanup(self):
        report, _, _ = self.report(includeName=True, goal='|cffffffffMazmorras|r\ncon amigos')
        self.assertIn('Name: PrivateName', report)
        self.assertIn('Mazmorras con amigos', report)
        self.assertNotIn('KNOWN SPELLS', report)

    def test_secret_values_are_not_exported_or_treated_as_empty(self):
        self.lua.execute('UnitStat = function() return {secret=true}, {secret=true} end; GetInventoryItemID = function() return {secret=true} end')
        report, _, warnings = self.report()
        self.assertIn('Strength: Unavailable', report)
        self.assertIn('Head: read unavailable.', report)
        self.assertNotIn('table:', report)
        self.assertGreater(warnings, 0)

    def test_pet_skills_are_exported(self):
        self.lua.execute('petActive = true')
        report, _, _ = self.report()
        self.assertIn('Family/type: Lobo / Bestia', report)
        self.assertIn('Mordedura Rango 2', report)

    def test_legacy_uses_constant_tree_ids(self):
        self.lua.execute('''
            Constants = {LegacyConsts = {LEGACY_TREE_PROFESSIONS_ID = 99}}
            C_Traits.GetConfigIDByTreeID = function(id) assert(id == 99); return 2020 end
        ''')
        report, _, _ = self.report()
        self.assertIn('Legacy: professions (tree 99', report)

    def test_large_report_not_truncated(self):
        self.lua.execute('C_Spell.GetSpellDescription = function() return string.rep("Descripción ", 12000) end')
        report, _, _ = self.report()
        self.assertGreater(len(report), 200000)
        self.assertTrue(report.endswith('Do not invent effects, locations, or rewards.'))

    def test_ui_open_select_refresh_persist_and_combat(self):
        self.load('UI.lua')
        self.lua.execute('dispatch("PLAYER_LOGIN"); SlashCmdList.FOREVER_CONTEXT("")')
        g = self.lua.globals()
        frame = g.ForeverContextWindow
        self.assertTrue(frame.shown)
        self.assertTrue(frame.text.selected)
        self.assertIn('Level: 24', frame.text.value)
        self.assertIn('Ctrl+C', frame.status.value)
        self.lua.execute('ForeverContextWindow.goal:SetText("Tanque en mazmorras"); ForeverContextWindow.generate.scripts.OnClick()')
        self.assertIn('Tanque en mazmorras', frame.text.value)
        self.assertEqual(g.ForeverContextDB.goal, 'Tanque en mazmorras')
        self.lua.execute('combat = true; dispatch("PLAYER_REGEN_DISABLED")')
        self.assertFalse(frame.shown)
        self.lua.execute('SlashCmdList.FOREVER_CONTEXT("")')
        self.assertFalse(frame.shown)
        self.lua.execute('combat = false; SlashCmdList.FOREVER_CONTEXT("")')
        self.assertTrue(frame.shown)
        self.lua.execute('ForeverContextWindow.text.scripts.OnEscapePressed()')
        self.assertFalse(frame.shown)

    def test_ui_cache_retry_finishes_and_timeout_does_not_overwrite_afterward(self):
        self.load('UI.lua')
        self.lua.execute('itemReady = false; SlashCmdList.FOREVER_CONTEXT("")')
        frame = self.lua.globals().ForeverContextWindow
        self.assertFalse(frame.generate.enabled)
        self.lua.execute('itemReady = true; tick(0.5)')
        self.assertTrue(frame.generate.enabled)
        self.assertTrue(frame.text.selected)
        self.assertIsNone(frame.scripts.OnUpdate)
        self.lua.execute('itemReady = false; ForeverContextWindow.generate.scripts.OnClick(); for i = 1, 10 do tick(0.5) end')
        self.assertIsNone(frame.scripts.OnUpdate)
        self.assertTrue(frame.select.enabled)
        self.assertIn('pending data', frame.status.value)

    def test_toc_load_order_and_saved_variables(self):
        toc = (ADDON / 'ForeverContext.toc').read_text(encoding='utf-8')
        self.assertIn('## Interface: 16001', toc)
        self.assertIn('## SavedVariables: ForeverContextDB', toc)
        files = [line for line in toc.splitlines() if line and not line.startswith('#')]
        self.assertEqual(files, ['Core.lua', 'UI.lua'])
        for file in files:
            self.assertTrue((ADDON / file).is_file())


if __name__ == '__main__':
    unittest.main(verbosity=2)
