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
descriptionText = "Incrementa el daño un 5%."
traitRanks = {}
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
    GetSpellDescription = function(id) return descriptionText end,
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
    GetItemInfoInstant = function(id) return id, 'Arma', 'Espada', 'INVTYPE_WEAPON', 1, 2, 7 end,
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
end,
GetTraitEntry = function(...)
    assert(select('#', ...) == 2)
    local entryID, rank = ...
    assert((entryID == 100 or entryID == 102) and rank > 0)
    traitRanks[entryID] = rank
    return {lines = {{type = 34, leftText = descriptionText}}}
end }
C_UnitAuras = { GetAuraDataByIndex = function(unit, index, filter)
    assert(unit == "player" and filter == "HELPFUL")
    if index == 1 then return {name = "Bendición", spellId = 77, applications = 1} end
end }
Enum = { SpellBookSpellBank = {Player = 0, Pet = 1}, ItemClass = {Weapon = 2},
    TooltipDataLineType = {None = 0, SpellName = 13, SpellDescription = 34, DisabledLine = 42} }
ITEM_SET_BONUS = "Conjunto: %s"
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
    local w = {scripts = {}, events = {}, shown = true, enabled = true, value = "", width = 800, height = 600, scroll = 0}
    setmetatable(w, {__index = widget})
    if name then _G[name] = w end
    frames[#frames + 1] = w
    return w
end
function widget:SetScript(name, fn) self.scripts[name] = fn end
function widget:HookScript(name, fn)
    local previous = self.scripts[name]
    self.scripts[name] = function(self, ...)
        if previous then previous(self, ...) end
        fn(self, ...)
    end
end
function widget:SetPoint(...) self.point = {...} end
function widget:ClearAllPoints() self.point = nil end
function widget:GetCenter() return self.centerX or 500, self.centerY or 500 end
function widget:GetEffectiveScale() return self.scale or 1 end
function widget:GetFrameLevel() return self.frameLevel or 0 end
function widget:SetFrameLevel(value) self.frameLevel = value end
function widget:GetFrameStrata() return self.strata or (self.parent and self.parent:GetFrameStrata()) or 'MEDIUM' end
function widget:SetFrameStrata(value)
    local strata = {BACKGROUND=true, LOW=true, MEDIUM=true, HIGH=true, DIALOG=true, FULLSCREEN=true, FULLSCREEN_DIALOG=true, TOOLTIP=true}
    assert(strata[value], 'Unknown frame strata: ' .. tostring(value))
    self.strata = value
end
function widget:RegisterForClicks(...) self.clicks = {...} end
function widget:SetHighlightTexture(path) assert(self.kind == 'Button'); self.highlight = path end
function widget:CreateTexture()
    local texture = newWidget()
    texture.kind = 'Texture'
    return texture
end
function widget:SetTexture(path) assert(self.kind == 'Texture'); self.texture = path end
function widget:SetTexCoord(...) assert(self.kind == 'Texture'); self.texcoord = {...} end
function widget:SetOwner(owner, anchor) self.owner, self.anchor = owner, anchor end
function widget:AddLine(text) self.lines = self.lines or {}; table.insert(self.lines, text) end
function widget:RegisterEvent(name) self.events[name] = true end
function widget:SetSize(w, h) self.width = w; self.height = h end
function widget:SetWidth(w) self.width = w end
function widget:SetHeight(h) self.height = h end
function widget:GetWidth() return self.width end
function widget:GetHeight() return self.height end
function widget:Hide() self.shown = false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
function widget:Show() self.shown = true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
function widget:IsShown() return self.shown end
function widget:IsVisible() return self.shown and (not self.parent or self.parent:IsVisible()) end
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
function widget:SetVerticalScroll(y) assert(self.kind == "ScrollFrame"); self.scroll = y end
function widget:GetVerticalScroll() assert(self.kind == "ScrollFrame"); return self.scroll end
function widget:SetScrollChild(child) assert(self.kind == "ScrollFrame"); self.child = child end
for _, method in ipairs({"SetClampedToScreen", "SetMovable", "EnableMouse", "RegisterForDrag", "StartMoving", "StopMovingOrSizing", "SetBackdrop", "SetBackdropColor", "SetBackdropBorderColor", "SetAutoFocus", "SetMaxLetters", "SetMultiLine", "SetFontObject", "SetTextInsets", "SetCursorPosition", "SetJustifyH", "SetScale"}) do
    widget[method] = function() end
end
UIParent = newWidget("UIParent")
UIParent:SetSize(1920, 1080)
Minimap = newWidget('Minimap')
Minimap.kind = 'Minimap'
Minimap:SetSize(198, 198)
GameTooltip = newWidget('GameTooltip')
cursorX, cursorY = 600, 500
function GetCursorPosition() return cursorX, cursorY end
function CreateFrame(kind, name, parent, template)
    -- Independent client contracts: reject invented types/templates rather than
    -- silently accepting them, as the original permissive mock did.
    local kinds = {Frame=true, Button=true, CheckButton=true, ScrollFrame=true, EditBox=true}
    local templates = {BackdropTemplate=true, UIPanelButtonTemplate=true,
        UIPanelCloseButton=true, InputBoxTemplate=true, UICheckButtonTemplate=true,
        UIPanelScrollFrameTemplate=true}
    assert(kinds[kind], "Unknown frame type: " .. tostring(kind))
    assert(not template or templates[template], "Unknown frame template: " .. tostring(template))
    local w = newWidget(name)
    w.kind, w.template, w.parent = kind, template, parent
    w.frameLevel = parent and parent:GetFrameLevel() + 1 or 0
    if kind == "CheckButton" then w.Text = newWidget() end
    if template == "UIPanelCloseButton" then w:SetScript('OnClick', function() parent:Hide() end) end
    return w
end
function tick(delta)
    for _, frame in ipairs(frames) do if frame:IsVisible() and frame.scripts.OnUpdate then frame.scripts.OnUpdate(frame, delta) end end
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
        self.load('Progress.lua')
        self.load('Workflow.lua')

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
        self.lua.execute('descriptionText = string.rep("Descripción ", 12000)')
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
        self.assertEqual(g.ForeverContextCharacterDB.options.goal, 'Tanque en mazmorras')
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

    def test_ui_builds_scrollable_report_and_footer_controls(self):
        self.load('UI.lua')
        self.lua.execute('SlashCmdList.FOREVER_CONTEXT("")')
        frame = self.lua.globals().ForeverContextWindow
        self.assertEqual(frame.scroll.kind, 'ScrollFrame')
        self.assertEqual(frame.scroll.template, 'UIPanelScrollFrameTemplate')
        self.assertEqual(frame.scroll.child.value, frame.report)
        self.assertIn('REQUEST TO THE AI', frame.report)
        self.assertEqual(frame.generate.value, 'Generate / refresh')
        self.assertEqual(frame.select.value, 'Select all')
        self.assertTrue(frame.generate.enabled)
        self.assertTrue(frame.select.enabled)
        self.assertIn('Ctrl+C', frame.status.value)

    def test_ui_scrolls_and_selects_long_report(self):
        self.lua.execute('descriptionText = string.rep("Long description ", 12000)')
        self.load('UI.lua')
        self.lua.execute('SlashCmdList.FOREVER_CONTEXT("")')
        frame = self.lua.globals().ForeverContextWindow
        self.assertGreater(len(frame.text.value), 200000)
        self.lua.execute('ForeverContextWindow.text.scripts.OnCursorChanged(nil, 0, -1200, 1, 16)')
        self.assertGreater(frame.scroll.scroll, 0)
        self.lua.execute('ForeverContextWindow.select.scripts.OnClick()')
        self.assertEqual(frame.scroll.scroll, 0)
        self.assertTrue(frame.text.selected)

    def test_toc_load_order_and_saved_variables(self):
        toc = (ADDON / 'ForeverContext.toc').read_text(encoding='utf-8')
        self.assertIn('## Interface: 16001', toc)
        self.assertIn('## SavedVariables: ForeverContextDB', toc)
        files = [line for line in toc.splitlines() if line and not line.startswith('#')]
        self.assertEqual(files, ['Core.lua', 'Progress.lua', 'Workflow.lua', 'UI.lua', 'PlannerUI.lua', 'Minimap.lua'])
        self.assertIn('## SavedVariablesPerCharacter: ForeverContextCharacterDB', toc)
        for file in files:
            self.assertTrue((ADDON / file).is_file())

    def test_empty_offhand_omits_phantom_damage_and_speed(self):
        self.lua.execute('UnitDamage = function() return 118.9, 144.9, 20.8, 20.8 end')
        report, _, _ = self.report()
        self.assertIn('Off hand: empty.', report)
        self.assertIn('Off-hand attacks: not applicable', report)
        self.assertNotIn('Off-hand damage:', report)
        self.assertNotIn('Off-hand attack speed:', report)

    def test_shield_is_not_treated_as_an_offhand_weapon(self):
        self.lua.execute('''
            local original = GetInventoryItemID
            GetInventoryItemID = function(unit, slot) return slot == 17 and 12345 or original(unit, slot) end
            C_Item.GetItemInfoInstant = function(id) return id, 'Armadura', 'Escudo', 'INVTYPE_SHIELD', 1, 4, 6 end
        ''')
        report, _, _ = self.report()
        self.assertIn('Off-hand attacks: not applicable', report)
        self.assertNotIn('Off-hand damage:', report)

    def test_real_offhand_weapon_preserves_damage_and_speed(self):
        self.lua.execute('''
            local original = GetInventoryItemID
            local originalLink = GetInventoryItemLink
            GetInventoryItemID = function(unit, slot) return slot == 17 and 12345 or original(unit, slot) end
            GetInventoryItemLink = function(unit, slot) return originalLink(unit, slot == 17 and 16 or slot) end
        ''')
        report, _, _ = self.report()
        self.assertIn('Off-hand damage: 5.0–8.0', report)
        self.assertIn('Off-hand attack speed: 1.80 s', report)

    def test_unknown_offhand_metadata_does_not_invent_a_weapon(self):
        self.lua.execute('''
            local original = GetInventoryItemID
            GetInventoryItemID = function(unit, slot) return slot == 17 and 12345 or original(unit, slot) end
            C_Item.GetItemInfoInstant = nil
        ''')
        report, _, warnings = self.report()
        self.assertIn('weapon data unavailable; damage omitted', report)
        self.assertNotIn('Off-hand damage:', report)
        self.assertGreater(warnings, 0)

    def test_talent_description_queries_current_rank_not_base_spell(self):
        self.lua.execute('''
            local original = C_Traits.GetNodeInfo
            C_Traits.GetNodeInfo = function(config, nodeID)
                local info = original(config, nodeID)
                if nodeID == 10 then info.activeEntry.rank = 5; info.ranksPurchased = 5 end
                return info
            end
            C_Spell.GetSpellDescription = function() return 'BASE SPELL: critical chance 1%.' end
            C_TooltipInfo.GetTraitEntry = function(entryID, rank)
                if entryID == 100 then assert(rank == 5) end
                return {lines = {{type = 13, leftText = 'Title'}, {type = 34, leftText = 'CURRENT RANK: critical chance 5%.'}}}
            end
        ''')
        report, _, warnings = self.report()
        self.assertIn('Golpe mejorado: 5/5', report)
        self.assertIn('[rank 5 tooltip] CURRENT RANK: critical chance 5%.', report)
        self.assertNotIn('BASE SPELL:', report)
        self.assertEqual(warnings, 0)

    def test_talent_tooltips_include_client_bonus_ranks(self):
        self.lua.execute('''
            local original = C_Traits.GetNodeInfo
            C_Traits.GetNodeInfo = function(config, nodeID)
                local info = original(config, nodeID)
                if nodeID == 10 then info.ranksIncreased = 2 end
                return info
            end
        ''')
        report, _, _ = self.report()
        self.assertEqual(self.lua.globals().traitRanks[100], 5)
        self.assertIn('Golpe mejorado: 5/5', report)
        self.assertIn('[includes 2 bonus ranks]', report)
        self.assertIn('Purchased ranks in Armas: 3', report)

    def test_rank_description_fallback_is_explicitly_unverified(self):
        self.lua.execute('C_TooltipInfo.GetTraitEntry = nil; C_Spell.GetSpellDescription = function() return "Base reference 1%." end')
        report, pending, warnings = self.report()
        self.assertIn('[REFERENCE ONLY; current-rank effect unverified] Base reference 1%.', report)
        self.assertGreater(warnings, 0)
        self.assertEqual(pending, 0)
        self.lua.execute('C_TooltipInfo.GetTraitEntry = function() return nil end')
        report, pending, _ = self.report()
        self.assertGreater(pending, 0)
        self.assertIn('REFERENCE ONLY', report)

    def test_rank_tooltip_accepts_untyped_client_description_lines(self):
        self.lua.execute('C_TooltipInfo.GetTraitEntry = function(entry, rank) return {lines={{type=0, leftText="Untyped current rank " .. rank}}} end')
        report, _, _ = self.report()
        self.assertIn('[rank 3 tooltip] Untyped current rank 3', report)

    def test_observed_spanish_set_bonuses_are_marked_active_or_inactive(self):
        self.lua.execute('''
            C_TooltipInfo.GetInventoryItem = function(_, slot)
                if slot ~= 16 then return end
                return {lines = {
                    {leftText='Cuero Defias (2/5)'},
                    {leftText='Conjunto: +5 p. de resistencia Arcana.'},
                    {leftText='(3) Bonif.: +15 p. de poder de ataque contra humanoides.'},
                    {leftText='(4) Bonif.: Efecto de sangrado.'},
                    {leftText='(5) Bonif.: Dagas aumentadas +1.'},
                    {leftText='Durabilidad 24 / 30'},
                }}
            end
        ''')
        report, _, _ = self.report()
        self.assertIn('[SET: 2/5 equipped] Cuero Defias', report)
        self.assertIn('[SET BONUS ACTIVE (client)] Conjunto: +5', report)
        for threshold in (3, 4, 5):
            self.assertIn(f'[SET BONUS INACTIVE: requires {threshold} pieces; equipped 2/5]', report)
        self.assertIn('  Durabilidad 24 / 30', report)

    def test_client_disabled_set_bonus_is_not_enabled_by_piece_count(self):
        self.lua.execute('''
            C_TooltipInfo.GetInventoryItem = function()
                return {lines={
                    {leftText='Test set (3/5)'},
                    {leftText='(2) Bonus: blocked by a requirement', leftColor={r=1,g=0,b=0}},
                    {leftText='Conjunto: disabled effect', type=42},
                }}
            end
        ''')
        report, _, _ = self.report()
        self.assertIn('[SET BONUS INACTIVE: requires 2 pieces; equipped 3/5]', report)
        self.assertIn('[SET BONUS INACTIVE] Conjunto: disabled effect', report)
        self.assertNotIn('[SET BONUS ACTIVE', report)

    def test_unknown_set_status_and_fullwidth_localized_punctuation(self):
        self.lua.execute('C_TooltipInfo.GetInventoryItem = function() return {lines={{leftText="(3) Bonus: uncertain"},{leftText="Conjunto: uncertain"}}} end')
        report, _, _ = self.report()
        self.assertIn('[POSSIBLE SET BONUS; STATUS UNKNOWN:', report)
        self.assertIn('[SET BONUS STATUS UNKNOWN]', report)
        self.assertNotIn('[SET BONUS ACTIVE', report)
        self.lua.execute('ITEM_SET_BONUS="套装：%s"; C_TooltipInfo.GetInventoryItem=function() return {lines={{leftText="套装（2／5）"},{leftText="套装：当前效果"},{leftText="（3） 套装：未激活"}}} end')
        report, _, _ = self.report()
        self.assertIn('[SET: 2/5 equipped]', report)
        self.assertIn('[SET BONUS ACTIVE (client)] 套装：当前效果', report)
        self.assertIn('[SET BONUS INACTIVE: requires 3 pieces;', report)

    def test_duplicate_resistance_aliases_are_not_exported_twice(self):
        self.lua.execute('RESISTANCE3_NAME="Nature resistance"; C_Item.GetItemStats=function() return {ITEM_MOD_NATURE_RESISTANCE_SHORT=7, RESISTANCE3_NAME=7, ITEM_MOD_STRENGTH_SHORT=7} end')
        report, _, _ = self.report()
        stats_line = next(line for line in report.splitlines() if 'Item stats:' in line)
        self.assertEqual(stats_line.count('Nature resistance=7.00'), 1)
        self.assertIn('Strength=7.00', stats_line)
        self.assertNotIn('ITEM_MOD_NATURE_RESISTANCE_SHORT=', stats_line)

    def test_conflicting_stat_aliases_are_preserved_with_warning(self):
        self.lua.execute('RESISTANCE3_NAME="Nature resistance"; C_Item.GetItemStats=function() return {ITEM_MOD_NATURE_RESISTANCE_SHORT=5, RESISTANCE3_NAME=7} end')
        report, _, warnings = self.report()
        self.assertIn('Nature resistance=5.00', report)
        self.assertIn('differs]=7.00', report)
        self.assertIn('Conflicting item-stat aliases', report)
        self.assertGreater(warnings, 0)

    def test_plural_markup_and_armor_resistance_duplication_are_cleaned(self):
        self.assertEqual(self.lua.globals().NS.Clean('13 |4carga:cargas;'), '13 cargas')
        self.assertEqual(self.lua.globals().NS.Clean('1 |4carga:cargas;'), '1 carga')
        self.lua.execute('RESISTANCE0_NAME="armadura"')
        report, _, _ = self.report()
        self.assertNotIn('Resistance armadura:', report)
        self.assertIn('Effective armor: 250', report)
        self.assertIn('(client stat:', report)

    def start_minimap(self):
        self.load('UI.lua')
        self.load('Minimap.lua')
        self.lua.execute('dispatch("PLAYER_LOGIN")')

    def test_minimap_button_opens_closes_and_explains_controls(self):
        self.start_minimap()
        g = self.lua.globals()
        button = g.ForeverContextMinimapButton
        self.assertTrue(button.shown)
        self.assertIn('INV_Misc_Note_01', button.icon.texture)
        self.assertIsNone(button.scripts.OnUpdate)
        self.lua.execute('ForeverContextMinimapButton.scripts.OnEnter(ForeverContextMinimapButton)')
        self.assertEqual(g.GameTooltip.value, 'ForeverContext')
        self.assertIn('/fcontext minimap', g.GameTooltip.lines[3])
        self.lua.execute('ForeverContextMinimapButton.scripts.OnClick(ForeverContextMinimapButton)')
        self.assertTrue(g.ForeverContextWindow.shown)
        self.assertIn('REQUEST TO THE AI', g.ForeverContextWindow.report)
        self.lua.execute('ForeverContextMinimapButton.scripts.OnClick(ForeverContextMinimapButton)')
        self.assertFalse(g.ForeverContextWindow.shown)
        total = len(g.frames)
        self.lua.execute('dispatch("PLAYER_LOGIN")')
        self.assertEqual(len(g.frames), total)

    def test_minimap_drag_saves_scaled_cursor_angle_and_tracks_resize(self):
        self.start_minimap()
        g = self.lua.globals()
        self.lua.execute('Minimap.scale = 0.5; cursorX = 250; cursorY = 300; ForeverContextMinimapButton.scripts.OnDragStart(ForeverContextMinimapButton)')
        self.assertAlmostEqual(g.ForeverContextDB.minimap.angle, 90)
        self.assertAlmostEqual(g.ForeverContextMinimapButton.point[4], 0)
        self.assertAlmostEqual(g.ForeverContextMinimapButton.point[5], 107)
        self.lua.execute('ForeverContextMinimapButton.scripts.OnDragStop(ForeverContextMinimapButton)')
        self.assertIsNone(g.ForeverContextMinimapButton.scripts.OnUpdate)
        self.lua.execute('Minimap:SetSize(300, 300); Minimap.scripts.OnSizeChanged(Minimap)')
        self.assertAlmostEqual(g.ForeverContextMinimapButton.point[5], 158)

    def test_minimap_restores_position_and_visibility_preferences(self):
        self.lua.execute('ForeverContextDB = {minimap = {angle = 90, hide = true}}')
        self.start_minimap()
        g = self.lua.globals()
        self.assertFalse(g.ForeverContextMinimapButton.shown)
        self.assertAlmostEqual(g.ForeverContextMinimapButton.point[5], 107)
        self.lua.execute('SlashCmdList.FOREVER_CONTEXT("minimap")')
        self.assertTrue(g.ForeverContextMinimapButton.shown)
        self.assertFalse(g.ForeverContextDB.minimap.hide)
        self.lua.execute('SlashCmdList.FOREVER_CONTEXT("minimap")')
        self.assertFalse(g.ForeverContextMinimapButton.shown)
        self.assertTrue(g.ForeverContextDB.minimap.hide)

    def test_minimap_combat_stops_drag_and_blocks_export(self):
        self.start_minimap()
        g = self.lua.globals()
        self.lua.execute('ForeverContextMinimapButton.scripts.OnDragStart(ForeverContextMinimapButton); combat = true; dispatch("PLAYER_REGEN_DISABLED")')
        self.assertFalse(g.ForeverContextMinimapButton.dragging)
        self.assertIsNone(g.ForeverContextMinimapButton.scripts.OnUpdate)
        self.lua.execute('ForeverContextMinimapButton.scripts.OnClick(ForeverContextMinimapButton)')
        self.assertIsNone(g.ForeverContextWindow)
        self.assertIn('Leave combat', g.messages[len(g.messages)])

    def test_minimap_missing_keeps_slash_export_available(self):
        self.lua.execute('Minimap = nil')
        self.start_minimap()
        self.lua.execute('SlashCmdList.FOREVER_CONTEXT("")')
        self.assertTrue(self.lua.globals().ForeverContextWindow.shown)
        self.assertIsNone(self.lua.globals().ForeverContextMinimapButton)

    def test_minimap_handles_square_shape_and_invalid_saved_angle(self):
        self.lua.execute('ForeverContextDB = {minimap = {angle = 0/0}}; function GetMinimapShape() return "SQUARE" end')
        self.start_minimap()
        g = self.lua.globals()
        self.assertEqual(g.ForeverContextDB.minimap.angle, 225)
        self.assertAlmostEqual(g.ForeverContextMinimapButton.point[4], -107)
        self.assertAlmostEqual(g.ForeverContextMinimapButton.point[5], -107)


if __name__ == '__main__':
    unittest.main(verbosity=2)
