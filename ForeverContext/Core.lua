local _, NS = ...
NS.VERSION = "1.1.0"

-- Only public addon APIs. Exporting is disabled in combat by UI.lua.
local function secret(value)
    return type(issecretvalue) == "function" and issecretvalue(value)
end

local function pack(...)
    return { n = select("#", ...), ... }
end

local function call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local values = pack(pcall(fn, ...))
    if not values[1] then return nil end
    return unpack(values, 2, values.n)
end

local function number(value)
    if secret(value) then return nil end
    if type(value) == "number" then return value end
    return nil
end

local function object(value)
    if secret(value) then return nil end
    if type(value) == "table" then return value end
    return nil
end

local function clean(value, fallback)
    fallback = fallback or "Unavailable"
    if secret(value) then return fallback end
    if type(value) ~= "string" and type(value) ~= "number" then return fallback end
    local text = tostring(value)
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("|H.-|h(.-)|h", "%1")
    text = text:gsub("|T.-|t", ""):gsub("|A.-|a", "")
    text = text:gsub("(%d+)%s*|4([^:;]*):([^;]*);", function(amount, singular, plural)
        if plural:find(":", 1, true) then return amount .. " |4" .. singular .. ":" .. plural .. ";" end
        return amount .. " " .. (tonumber(amount) == 1 and singular or plural)
    end)
    text = text:gsub("[\r\n\t]+", " "):gsub("%s+", " ")
    text = text:match("^%s*(.-)%s*$")
    return text ~= "" and text or fallback
end

local function fmt(value, decimals)
    value = number(value)
    if not value then return "Unavailable" end
    return string.format("%." .. (decimals or 0) .. "f", value)
end

local function namespace(name, method)
    return _G[name] and _G[name][method]
end

local function push(ctx, text)
    ctx.lines[#ctx.lines + 1] = text or ""
end

local function warn(ctx, text)
    ctx.warnings[text] = true
end

local function pending(ctx, key)
    ctx.pending[key] = true
end

local function count(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local function sortedKeys(t)
    local keys = {}
    for key in pairs(t) do keys[#keys + 1] = key end
    table.sort(keys)
    return keys
end

local function spellName(spellID)
    local info = object(call(namespace("C_Spell", "GetSpellInfo"), spellID))
    return info and clean(info.name, "") or clean(call(GetSpellInfo, spellID), "")
end

local function lineType(name)
    return Enum and Enum.TooltipDataLineType and Enum.TooltipDataLineType[name]
end

local function talentDescription(ctx, entryID, rank, definition)
    local fn = namespace("C_TooltipInfo", "GetTraitEntry")
    local data = object(call(fn, entryID, rank))
    local descriptions = {}
    for _, line in ipairs(data and object(data.lines) or {}) do
        local kind = number(line.type)
        -- GetTraitEntry is already scoped to the requested rank. Older builds can
        -- return untyped description lines; preserve those, excluding titles.
        if kind == lineType("SpellDescription") or kind == nil or kind == lineType("None") then
            local text = clean(line.leftText, "")
            if text ~= "" then descriptions[#descriptions + 1] = text end
        end
    end
    if #descriptions > 0 then
        return "[rank " .. fmt(rank) .. " tooltip] " .. table.concat(descriptions, " ")
    end
    if fn and not data then
        pending(ctx, "talent-tooltip:" .. entryID .. ":" .. rank)
        if definition and number(definition.spellID) then call(namespace("C_Spell", "RequestLoadSpellData"), definition.spellID) end
    end
    local reference = definition and clean(definition.overrideDescription, "") or ""
    if reference == "" and definition and number(definition.spellID) then
        reference = clean(call(namespace("C_Spell", "GetSpellDescription"), definition.spellID), "")
    end
    warn(ctx, "Some talent effects could not be verified for their current rank. Reference descriptions must not be treated as rank-scaled totals.")
    return reference ~= "" and "[REFERENCE ONLY; current-rank effect unverified] " .. reference
        or "[Current-rank description unavailable]"
end

local function offhandWeapon()
    local ok, id = pcall(GetInventoryItemID, "player", 17)
    if not ok or secret(id) then return nil end
    id = number(id)
    if not id then return false end
    local _, _, _, _, _, classID = call(namespace("C_Item", "GetItemInfoInstant") or GetItemInfoInstant, id)
    classID = number(classID)
    if not classID then return nil end
    return classID == (Enum and Enum.ItemClass and Enum.ItemClass.Weapon or 2)
end

local function normalizedPunctuation(text)
    return text:gsub("（", "("):gsub("）", ")"):gsub("／", "/")
end

local function setBonusPrefix(text)
    local format = clean(ITEM_SET_BONUS, "")
    local position = format:find("%s", 1, true)
    local prefix = position and format:sub(1, position - 1):match("^%s*(.-)%s*$") or ""
    return prefix ~= "" and text:sub(1, #prefix) == prefix
end

local function disabledTooltipLine(line)
    if lineType("DisabledLine") and number(line.type) == lineType("DisabledLine") then return true end
    local color = object(line.leftColor)
    if not color then return false end
    local r, g, b = number(color.r), number(color.g), number(color.b)
    if not r or not g or not b then return false end
    local gray = math.abs(r - g) < 0.04 and math.abs(g - b) < 0.04 and r < 0.65
    local red = r > 0.7 and g < 0.25 and b < 0.25
    return gray or red
end

local function equipmentTooltip(data)
    local result, equipped, total = {}, nil, nil
    data = object(data)
    for _, line in ipairs(data and object(data.lines) or {}) do
        local left, right = clean(line.leftText, ""), clean(line.rightText, "")
        local text = left .. (right ~= "" and (left ~= "" and " | " or "") .. right or "")
        local normalized = normalizedPunctuation(left)
        local name, have, maximum = normalized:match("^(.-)%s*%((%d+)%s*/%s*(%d+)%)%s*$")
        local threshold = tonumber(normalized:match("^%((%d+)%)%s*"))
        if name and name ~= "" and tonumber(have) <= tonumber(maximum) then
            equipped, total = tonumber(have), tonumber(maximum)
            text = "[SET: " .. equipped .. "/" .. total .. " equipped] " .. text
        elseif threshold and equipped then
            local state = equipped >= threshold and not disabledTooltipLine(line) and "ACTIVE" or "INACTIVE"
            text = "[SET BONUS " .. state .. ": requires " .. threshold .. " pieces; equipped " .. equipped .. "/" .. total .. "] " .. text
        elseif setBonusPrefix(normalized) then
            -- The client omits the threshold on active Set: lines. Do not guess
            -- it from a different spell or multiply a set bonus per item.
            local state = disabledTooltipLine(line) and "INACTIVE" or equipped and "ACTIVE (client)" or "STATUS UNKNOWN"
            text = "[SET BONUS " .. state .. "] " .. text
        elseif threshold then
            text = "[POSSIBLE SET BONUS; STATUS UNKNOWN: requires " .. threshold .. " pieces] " .. text
        end
        if text ~= "" then result[#result + 1] = text end
    end
    return result
end

local resistanceAliases = {
    ITEM_MOD_HOLY_RESISTANCE_SHORT = "RESISTANCE1_NAME",
    ITEM_MOD_FIRE_RESISTANCE_SHORT = "RESISTANCE2_NAME",
    ITEM_MOD_NATURE_RESISTANCE_SHORT = "RESISTANCE3_NAME",
    ITEM_MOD_FROST_RESISTANCE_SHORT = "RESISTANCE4_NAME",
    ITEM_MOD_SHADOW_RESISTANCE_SHORT = "RESISTANCE5_NAME",
    ITEM_MOD_ARCANE_RESISTANCE_SHORT = "RESISTANCE6_NAME",
}

local function itemStatEntries(ctx, stats)
    local entries, seen = {}, {}
    for _, key in ipairs(sortedKeys(stats)) do
        local canonical = resistanceAliases[key] or key
        local value = number(stats[key])
        if not seen[canonical] or seen[canonical].value ~= value then
            local label = clean(_G[canonical] or _G[key], canonical)
            if seen[canonical] then
                label = label .. " [alias " .. key .. "; differs]"
                warn(ctx, "Conflicting item-stat aliases were preserved separately; do not sum alias values.")
            end
            entries[#entries + 1] = label .. "=" .. fmt(stats[key], 2)
            seen[canonical] = { value = value }
        end
    end
    return entries
end

local function identity(ctx)
    local version, build, _, interface = call(GetBuildInfo)
    push(ctx, "Game: World of Warcraft: Forever")
    push(ctx, "Client: " .. clean(version) .. "; build " .. clean(build) .. "; interface " .. clean(interface))
    push(ctx, "Language: " .. clean(call(GetLocale)))
    if number(interface) and interface ~= 16001 then
        warn(ctx, "This client does not use the expected Forever interface 16001. Check compatibility.")
    end
    if ctx.options.includeName then
        push(ctx, "Name: " .. clean(call(UnitName, "player")))
    else
        push(ctx, "Name: omitted")
    end
    local class, token = call(UnitClass, "player")
    push(ctx, "Class: " .. clean(class) .. " (" .. clean(token) .. ")")
    push(ctx, "Race: " .. clean(call(UnitRace, "player")))
    local faction, localizedFaction = call(UnitFactionGroup, "player")
    push(ctx, "Faction: " .. clean(localizedFaction or faction))
    push(ctx, "Level: " .. fmt(call(UnitLevel, "player")))
    local xp, maximum = number(call(UnitXP, "player")), number(call(UnitXPMax, "player"))
    if xp and maximum and maximum > 0 then
        push(ctx, "Experience: " .. fmt(xp) .. "/" .. fmt(maximum) .. " (" .. fmt(xp / maximum * 100, 1) .. "%)")
        push(ctx, "Rested experience: " .. fmt(call(GetXPExhaustion)))
    end
    push(ctx, "Zone: " .. clean(call(GetRealZoneText)) .. "; subzone: " .. clean(call(GetSubZoneText), "no subzone"))
    local money = number(call(GetMoney))
    if money then
        push(ctx, string.format("Money: %dg %ds %dc", math.floor(money / 10000), math.floor(money / 100) % 100, money % 100))
    end
    local specIndex = number(call(namespace("C_SpecializationInfo", "GetSpecialization") or GetSpecialization))
    if specIndex then
        local _, name, _, _, role = call(namespace("C_SpecializationInfo", "GetSpecializationInfo") or GetSpecializationInfo, specIndex)
        push(ctx, "Client-reported specialization: " .. clean(name) .. "; role: " .. clean(role))
    end
    local form = number(call(GetShapeshiftForm))
    if form and form > 0 then push(ctx, "Active form/stance index " .. form) end
end

local function statistics(ctx)
    push(ctx, "Current observed stats may include gear, buffs, forms, and temporary effects.")
    push(ctx, "Maximum health: " .. fmt(call(UnitHealthMax, "player")))
    local powerID, powerToken = call(UnitPowerType, "player")
    powerID = number(powerID)
    push(ctx, "Maximum resource (" .. clean(powerToken) .. "): " .. fmt(call(UnitPowerMax, "player", powerID)))
    if powerID ~= 0 then
        local mana = number(call(UnitPowerMax, "player", 0))
        if mana and mana > 0 then push(ctx, "Maximum mana: " .. fmt(mana)) end
    end
    local names = { "Strength", "Agility", "Stamina", "Intellect", "Spirit" }
    for index, name in ipairs(names) do
        local base, effective = call(UnitStat, "player", index)
        push(ctx, name .. ": " .. fmt(effective) .. " (client stat: " .. fmt(base) .. ")")
    end
    local _, armor = call(UnitArmor, "player")
    push(ctx, "Effective armor: " .. fmt(armor))
    local baseAP, positiveAP, negativeAP = call(UnitAttackPower, "player")
    if number(baseAP) and number(positiveAP) and number(negativeAP) then
        push(ctx, "Melee attack power: " .. fmt(baseAP + positiveAP + negativeAP))
    end
    local baseRAP, positiveRAP, negativeRAP = call(UnitRangedAttackPower, "player")
    if number(baseRAP) and number(positiveRAP) and number(negativeRAP) then
        push(ctx, "Ranged attack power: " .. fmt(baseRAP + positiveRAP + negativeRAP))
    end
    local minDamage, maxDamage, offMin, offMax = call(UnitDamage, "player")
    push(ctx, "Main-hand damage: " .. fmt(minDamage, 1) .. "–" .. fmt(maxDamage, 1))
    local offhand = offhandWeapon()
    if offhand == true then
        push(ctx, "Off-hand damage: " .. fmt(offMin, 1) .. "–" .. fmt(offMax, 1))
    elseif offhand == false then
        push(ctx, "Off-hand attacks: not applicable (no off-hand weapon).")
    else
        push(ctx, "Off-hand attacks: weapon data unavailable; damage omitted.")
        warn(ctx, "Off-hand weapon metadata was unavailable; off-hand attack values were omitted.")
    end
    local mainSpeed, offSpeed = call(UnitAttackSpeed, "player")
    push(ctx, "Main-hand attack speed: " .. fmt(mainSpeed, 2) .. " s")
    if offhand == true then push(ctx, "Off-hand attack speed: " .. fmt(offSpeed, 2) .. " s") end
    local rangedSpeed, rangedMin, rangedMax = call(UnitRangedDamage, "player")
    if number(rangedSpeed) and rangedSpeed > 0 then
        push(ctx, "Ranged attack: " .. fmt(rangedMin, 1) .. "–" .. fmt(rangedMax, 1) .. "; speed " .. fmt(rangedSpeed, 2) .. " s")
    end
    for _, row in ipairs({
        { "Melee crit", GetCritChance }, { "Ranged crit", GetRangedCritChance },
        { "Dodge", GetDodgeChance }, { "Parry", GetParryChance }, { "Block", GetBlockChance },
        { "Melee haste", GetMeleeHaste }, { "Spell haste", UnitSpellHaste, "player" },
    }) do
        local value = number(call(row[2], row[3]))
        if value then push(ctx, row[1] .. ": " .. fmt(value, 2) .. "%") end
    end
    local schools = { [2] = "Holy", [3] = "Fire", [4] = "Nature", [5] = "Frost", [6] = "Shadow", [7] = "Arcane" }
    for school = 2, 7 do
        local damage = number(call(GetSpellBonusDamage, school))
        local crit = number(call(GetSpellCritChance, school))
        if damage or crit then push(ctx, schools[school] .. ": bonus damage " .. fmt(damage) .. "; crit " .. fmt(crit, 2) .. "%") end
    end
    local healing = number(call(GetSpellBonusHealing))
    if healing then push(ctx, "Bonus healing: " .. fmt(healing)) end
    local regen, casting = call(GetManaRegen)
    if number(regen) then push(ctx, "Mana regeneration: " .. fmt(regen, 2) .. "/s; casting: " .. fmt(casting, 2) .. "/s") end
    local penetration = number(call(GetSpellPenetration))
    if penetration then push(ctx, "Spell penetration: " .. fmt(penetration)) end
    for _, row in ipairs({
        { "Melee hit", "CR_HIT_MELEE" }, { "Ranged hit", "CR_HIT_RANGED" },
        { "Spell hit", "CR_HIT_SPELL" }, { "Expertise", "CR_EXPERTISE" },
        { "Defense", "CR_DEFENSE_SKILL" }, { "Dodge", "CR_DODGE" }, { "Parry", "CR_PARRY" },
        { "Block", "CR_BLOCK" }, { "Resilience", "CR_CRIT_TAKEN_MELEE" },
        { "Armor penetration", "CR_ARMOR_PENETRATION" },
    }) do
        local ratingID = number(_G[row[2]])
        local rating = ratingID and number(call(GetCombatRating, ratingID))
        if rating then
            push(ctx, "Rating " .. row[1] .. ": " .. fmt(rating) .. "; API-reported rating bonus: " .. fmt(call(GetCombatRatingBonus, ratingID), 2))
        end
    end
    for school = 1, 6 do
        local _, resistance = call(UnitResistance, "player", school)
        if number(resistance) then push(ctx, "Resistance " .. clean(_G["RESISTANCE" .. school .. "_NAME"], "school " .. school) .. ": " .. fmt(resistance)) end
    end
end

local function hasStagedChanges(configID)
    local fn = namespace("C_Traits", "GetStagedChanges")
    if type(fn) ~= "function" then return nil, false end
    local ok, purchases, refunds, selections = pcall(fn, configID)
    if not ok then return nil, false end
    return (object(purchases) and next(purchases)) or (object(refunds) and next(refunds)) or (object(selections) and next(selections))
        , true
end

local function exportTree(ctx, configID, treeID, label)
    local config = object(call(namespace("C_Traits", "GetConfigInfo"), configID))
    local nodes = object(call(namespace("C_Traits", "GetTreeNodes"), treeID))
    if not config or not nodes then
        push(ctx, label .. ": data unavailable.")
        pending(ctx, "talents:" .. treeID)
        return
    end
    push(ctx, label .. " (tree " .. treeID .. ", config " .. configID .. ")")
    local staged, checked = hasStagedChanges(configID)
    if not checked then
        push(ctx, "NOT EXPORTED: unable to verify whether there are unapplied changes.")
        warn(ctx, "Unable to confirm committed talent state.")
        return
    end
    if staged then
        push(ctx, "NOT EXPORTED: there are unapplied talent changes. Apply or cancel them and generate the report again.")
        warn(ctx, "Talents omitted because changes are unapplied; do not interpret this as an empty tree.")
        return
    end
    local groups, selected, groupRanks = {}, {}, {}
    local displays = object(call(namespace("C_Traits", "GetGroupDisplayInfoByTreeID"), treeID)) or {}
    for _, group in ipairs(displays) do groups[group.groupID] = clean(group.displayName) end
    for _, nodeID in ipairs(nodes) do
        local node = object(call(namespace("C_Traits", "GetNodeInfo"), configID, nodeID))
        if not node then
            pending(ctx, "node:" .. nodeID)
        else
            local active = object(node.activeEntry)
            local rank = active and number(active.rank) or number(node.currentRank)
            local bonusRanks = number(node.ranksIncreased) or 0
            if rank then rank = rank + bonusRanks end
            if rank and rank > 0 and active and number(active.entryID) then
                local entry = object(call(namespace("C_Traits", "GetEntryInfo"), configID, active.entryID))
                local definition = entry and number(entry.definitionID) and object(call(namespace("C_Traits", "GetDefinitionInfo"), entry.definitionID))
                local id = definition and number(definition.spellID)
                local name = definition and clean(definition.overrideName, "") or ""
                if name == "" and id then name = spellName(id) end
                if name == "" and entry and number(entry.subTreeID) then
                    local sub = object(call(namespace("C_Traits", "GetSubTreeInfo"), configID, entry.subTreeID))
                    name = sub and clean(sub.name, "") or ""
                end
                if name == "" then
                    name = "Entry " .. active.entryID
                    pending(ctx, "talent-name:" .. active.entryID)
                    if id then call(namespace("C_Spell", "RequestLoadSpellData"), id) end
                end
                local groupName = "General"
                for _, groupID in ipairs(object(node.groupIDs) or {}) do
                    if groups[groupID] then groupName = groups[groupID]; break end
                end
                groupRanks[groupName] = (groupRanks[groupName] or 0) + (number(node.ranksPurchased) or 0)
                local text = "- [" .. groupName .. "] " .. name .. ": " .. fmt(rank) .. "/" .. fmt(entry and entry.maxRanks or node.maxRanks)
                text = text .. " (node " .. nodeID .. ", entry " .. active.entryID .. (id and ", spell " .. id or "") .. ")"
                if number(node.ranksPurchased) == 0 then text = text .. " [granted, no purchased points]" end
                if bonusRanks > 0 then text = text .. " [includes " .. bonusRanks .. " bonus ranks]" end
                if definition then text = text .. " — " .. talentDescription(ctx, active.entryID, rank, definition) end
                selected[#selected + 1] = { y = number(node.posY) or 0, x = number(node.posX) or 0, id = nodeID, text = text }
            end
        end
    end
    for _, groupName in ipairs(sortedKeys(groupRanks)) do
        push(ctx, "Purchased ranks in " .. groupName .. ": " .. groupRanks[groupName])
    end
    local currencies = object(call(namespace("C_Traits", "GetTreeCurrencyInfo"), configID, treeID, true))
    if currencies then
        for _, currency in ipairs(currencies) do
            push(ctx, "Points (currency " .. clean(currency.traitCurrencyID) .. "): available " .. fmt(currency.quantity) .. "; spent in this tree " .. fmt(currency.spentInTree or currency.spent))
        end
    else
        push(ctx, "Unspent points: unavailable through the API.")
    end
    table.sort(selected, function(a, b)
        if a.y ~= b.y then return a.y < b.y end
        if a.x ~= b.x then return a.x < b.x end
        return a.id < b.id
    end)
    if #selected == 0 then push(ctx, "No active selections observed in this tree.") end
    for _, talent in ipairs(selected) do push(ctx, talent.text) end
end

local function talents(ctx)
    push(ctx, "Snapshot of the current build; the game does not provide the historical order of point allocation here.")
    local group = number(call(namespace("C_SpecializationInfo", "GetActiveSpecGroup") or GetActiveSpecGroup)) or 1
    local configID = number(call(namespace("C_SpecializationInfo", "GetCombatConfigIDForSpecGroup"), group))
        or number(call(namespace("C_ClassTalents", "GetActiveConfigID")))
    local config = configID and object(call(namespace("C_Traits", "GetConfigInfo"), configID))
    if not config or not object(config.treeIDs) then
        push(ctx, "Talents unavailable: they may be locked or their data may not be loaded yet.")
        warn(ctx, "Unable to read the talent build. Open Talents and generate again if talents are already unlocked.")
        return
    end
    push(ctx, "Active build: group " .. group .. ". Other builds are not mixed into this report.")
    for _, treeID in ipairs(config.treeIDs) do exportTree(ctx, configID, treeID, "Active class talents") end
end

local function legacy(ctx)
    local constants = Constants and Constants.LegacyConsts
    if not constants then push(ctx, "Legacy system: API unavailable."); return end
    for _, row in ipairs({
        { "Legacy: professions", constants.LEGACY_TREE_PROFESSIONS_ID },
        { "Legacy: adventure", constants.LEGACY_TREE_ADVENTURE_ID },
        { "Legacy: progression", constants.LEGACY_TREE_PROGRESSION_ID },
    }) do
        local treeID = number(row[2])
        local configID = treeID and number(call(namespace("C_Traits", "GetConfigIDByTreeID"), treeID))
        if configID then exportTree(ctx, configID, treeID, row[1]) else push(ctx, row[1] .. ": unavailable or locked.") end
    end
end

local function professions(ctx)
    if type(GetProfessions) ~= "function" or type(GetProfessionInfo) ~= "function" then
        push(ctx, "Professions: API unavailable.")
        warn(ctx, "Unable to read professions.")
        return
    end
    -- Keep fixed positions: there can be nil holes before a secondary profession.
    local result = pack(pcall(GetProfessions))
    if not result[1] then
        push(ctx, "Professions: read unavailable.")
        warn(ctx, "Unable to read professions; do not interpret them as unlearned.")
        return
    end
    local first, second, firstAid, fishing, cooking, archaeology = unpack(result, 2, result.n)
    local rows = {
        { "Primary 1", first }, { "Primary 2", second }, { "First Aid", firstAid },
        { "Fishing", fishing }, { "Cooking", cooking }, { "Archaeology", archaeology },
    }
    for index, row in ipairs(rows) do
        if number(row[2]) then
            local name, _, rank, maxRank, _, _, skillLine, modifier = call(GetProfessionInfo, row[2])
            local info = number(skillLine) and object(call(namespace("C_TradeSkillUI", "GetProfessionInfoBySkillLineID"), skillLine))
            -- Blizzard's Camelot UI uses these values, falling back to GetProfessionInfo for 0/0.
            if info and number(info.maxSkillLevel) and info.maxSkillLevel > 0 then
                rank, maxRank, modifier = info.skillLevel, info.maxSkillLevel, info.skillModifier
            end
            push(ctx, row[1] .. ": " .. clean(name) .. " " .. fmt(rank) .. "/" .. fmt(maxRank)
                .. (number(modifier) and modifier ~= 0 and " (bonus " .. fmt(modifier) .. ")" or "")
                .. "; skill ID " .. clean(skillLine))
            if not name then warn(ctx, "Unable to read the data for one profession.") end
        elseif index <= 5 then
            push(ctx, row[1] .. ": not learned.")
        end
    end
end

local slots = {
    { 1, "Head" }, { 2, "Neck" }, { 3, "Shoulders" }, { 4, "Shirt" }, { 5, "Chest" },
    { 6, "Waist" }, { 7, "Legs" }, { 8, "Feet" }, { 9, "Wrists" }, { 10, "Hands" },
    { 11, "Ring 1" }, { 12, "Ring 2" }, { 13, "Trinket 1" }, { 14, "Trinket 2" },
    { 15, "Back" }, { 16, "Main hand" }, { 17, "Off hand" }, { 18, "Ranged / relic" }, { 19, "Tabard" },
}

local function equipment(ctx)
    push(ctx, "Empty slots can be normal for your level and class. Item text comes from the client.")
    for _, slot in ipairs(slots) do
        local slotID, label = slot[1], slot[2]
        -- Preserve the original link only to query exact item bonuses; never export UI markup.
        local rawLink = call(GetInventoryItemLink, "player", slotID)
        if secret(rawLink) then rawLink = nil end
        local link = clean(rawLink, "")
        local readOK, inventoryID = pcall(GetInventoryItemID, "player", slotID)
        local itemID = number(inventoryID)
        if not itemID and rawLink then itemID = tonumber(rawLink:match("item:(%d+)")) end
        if not readOK or secret(inventoryID) then
            push(ctx, label .. ": read unavailable.")
            warn(ctx, "Unable to read an equipment slot; do not interpret it as empty.")
        elseif not itemID then
            local texture = call(GetInventoryItemTexture, "player", slotID)
            if secret(texture) or texture then
                push(ctx, label .. ": occupied; data pending.")
                pending(ctx, "slot:" .. slotID)
            else
                push(ctx, label .. ": empty.")
            end
        else
            local query = rawLink or itemID
            local name, _, quality, itemLevel, requiredLevel, itemType, subtype = call(namespace("C_Item", "GetItemInfo") or GetItemInfo, query)
            if not name then
                pending(ctx, "item:" .. itemID)
                call(namespace("C_Item", "RequestLoadItemDataByID"), itemID)
            end
            local effectiveLevel = number(call(namespace("C_Item", "GetDetailedItemLevelInfo") or GetDetailedItemLevelInfo, query))
            push(ctx, label .. ": " .. clean(name, link ~= "" and link or "item " .. itemID) .. " [ID " .. itemID .. "]")
            push(ctx, "  Type: " .. clean(itemType) .. " / " .. clean(subtype) .. "; quality: " .. clean(number(quality) and _G["ITEM_QUALITY" .. quality .. "_DESC"] or nil)
                .. "; item level: " .. fmt(effectiveLevel or itemLevel) .. "; required level: " .. fmt(requiredLevel))
            if rawLink then
                local itemString = rawLink:match("(item:[^|]+)")
                if itemString then
                    push(ctx, "  Exact reference: " .. itemString)
                    local fields = {}
                    for field in (itemString .. ":"):gmatch("(.-):") do fields[#fields + 1] = field end
                    local enchant = tonumber(fields[3])
                    push(ctx, "  Enchant (ID): " .. (enchant and enchant > 0 and tostring(enchant) or "0 / none recorded in the link"))
                    local gems = {}
                    for index = 4, 7 do
                        local gem = tonumber(fields[index])
                        if gem and gem > 0 then gems[#gems + 1] = tostring(gem) end
                    end
                    push(ctx, "  Gems (link IDs): " .. (#gems > 0 and table.concat(gems, ", ") or "none recorded"))
                end
            end
            local stats = object(call(namespace("C_Item", "GetItemStats") or GetItemStats, query))
            if stats then
                local entries = itemStatEntries(ctx, stats)
                if #entries > 0 then push(ctx, "  Item stats: " .. table.concat(entries, "; ")) end
            end
            local current, maximum = call(GetInventoryItemDurability, slotID)
            if number(maximum) and maximum > 0 then push(ctx, "  Durability: " .. fmt(current) .. "/" .. fmt(maximum)) end
            local lines = equipmentTooltip(call(namespace("C_TooltipInfo", "GetInventoryItem"), "player", slotID, false))
            if #lines > 0 then
                for _, text in ipairs(lines) do push(ctx, "  " .. text) end
            else
                push(ctx, "  Item description and effects: pending or unavailable.")
                pending(ctx, "tooltip:" .. itemID)
            end
        end
    end
end

local function auras(ctx)
    if not namespace("C_UnitAuras", "GetAuraDataByIndex") then
        push(ctx, "Buffs: API unavailable."); return
    end
    local found = 0
    for index = 1, 255 do
        local aura = object(call(namespace("C_UnitAuras", "GetAuraDataByIndex"), "player", index, "HELPFUL"))
        if not aura then break end
        found = found + 1
        push(ctx, "- " .. clean(aura.name) .. " [spell " .. clean(aura.spellId) .. "]; stacks " .. fmt(aura.applications))
    end
    if found == 0 then push(ctx, "No readable buffs observed.") end
end

local function pet(ctx)
    if not call(UnitExists, "pet") then push(ctx, "No pet summoned."); return end
    push(ctx, "Family/type: " .. clean(call(UnitCreatureFamily, "pet")) .. " / " .. clean(call(UnitCreatureType, "pet")))
    push(ctx, "Level: " .. fmt(call(UnitLevel, "pet")) .. "; maximum health: " .. fmt(call(UnitHealthMax, "pet")))
    local happiness = number(call(GetPetHappiness))
    if happiness then push(ctx, "Pet happiness (client scale): " .. happiness) end
    local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Pet
    local total = number(call(namespace("C_SpellBook", "HasPetSpells")))
    if bank and total then
        for index = 1, total do
            local info = object(call(namespace("C_SpellBook", "GetSpellBookItemInfo"), index, bank))
            if info then push(ctx, "- " .. clean(info.name) .. " " .. clean(info.subName, "") .. " [ID " .. clean(info.spellID or info.actionID) .. "]") end
        end
    end
end

local function spellbook(ctx)
    local total = number(call(namespace("C_SpellBook", "GetNumSpellBookSkillLines")))
    local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player
    if not total or not bank then push(ctx, "Spellbook: API unavailable."); return end
    push(ctx, "Known spells visible in the spellbook. This alone does not identify upgrades offered by trainers.")
    local seen = {}
    for index = 1, total do
        local skill = object(call(namespace("C_SpellBook", "GetSpellBookSkillLineInfo"), index))
        if skill and not skill.isGuild and not skill.offSpecID then
            push(ctx, "Branch: " .. clean(skill.name))
            local offset, size = number(skill.itemIndexOffset) or 0, number(skill.numSpellBookItems) or 0
            for position = offset + 1, offset + size do
                local info = object(call(namespace("C_SpellBook", "GetSpellBookItemInfo"), position, bank))
                if info and not info.isOffSpec then
                    local id = number(info.spellID)
                    if id and not seen[id] then
                        seen[id] = true
                        push(ctx, "- " .. clean(info.name) .. " " .. clean(info.subName, "") .. " [ID " .. id .. "]" .. (info.isPassive and " (passive)" or ""))
                    end
                end
            end
        end
    end
end

local function skills(ctx)
    local total = number(call(namespace("C_SkillInfo", "GetNumSkillLines")))
    if not total then push(ctx, "Skills: API unavailable."); return end
    -- Read known skill IDs directly: collapsed headers must not hide weapon/profession ranks.
    local seen, rows = {}, {}
    for index = 1, total do
        local skill = object(call(namespace("C_SkillInfo", "GetSkillLineInfo"), index))
        if skill and not skill.isHeader and number(skill.skillID) then rows[skill.skillID] = skill end
    end
    -- Classic weapon/defence and profession IDs remain queryable even with collapsed headers.
    for _, skillID in ipairs({ 43, 44, 45, 46, 54, 55, 95, 98, 118, 136, 160, 162, 172, 173, 176, 182, 185, 186, 197, 202, 261, 333, 356, 393, 414, 415, 433, 633, 164, 165, 171, 129 }) do
        local skill = object(call(namespace("C_SkillInfo", "GetSkillLineInfoByID"), skillID))
        if skill and not skill.isHeader and number(skill.rank) and skill.rank > 0 then rows[skillID] = skill end
    end
    for _, id in ipairs(sortedKeys(rows)) do
        local skill = rows[id]
        seen[id] = true
        push(ctx, "- " .. clean(skill.name) .. ": " .. fmt(skill.rank) .. "/" .. fmt(skill.maxRank) .. "; modifier " .. fmt(skill.modifier) .. "; ID " .. id)
    end
    if not next(seen) then push(ctx, "No readable skills.") end
end

local function quests(ctx)
    local entries, total = call(namespace("C_QuestLog", "GetNumQuestLogEntries") or GetNumQuestLogEntries)
    entries = number(entries)
    if not entries then push(ctx, "Quests: API unavailable."); return end
    push(ctx, "Active quests: " .. fmt(total))
    local read = 0
    for index = 1, entries do
        local info = object(call(namespace("C_QuestLog", "GetInfo"), index))
        if info and not info.isHeader and number(info.questID) then
            read = read + 1
            local done = call(namespace("C_QuestLog", "IsComplete"), info.questID)
            push(ctx, "- " .. clean(info.title) .. "; level " .. fmt(info.level) .. "; ID " .. info.questID .. (done and " (complete, ready to turn in)" or ""))
        end
    end
    if number(total) and read < total then
        warn(ctx, "Unable to list all quests. Expand quest-log groups and generate again for better coverage.")
    end
end

local function reputations(ctx)
    -- Iterate IDs to avoid opening/collapsing the player's reputation panel.
    local total = number(call(namespace("C_Reputation", "GetNumFactions")))
    if not total then push(ctx, "Reputation: API unavailable."); return end
    local rows = {}
    for index = 1, total do
        local info = object(call(namespace("C_Reputation", "GetFactionDataByIndex"), index))
        if info and (not info.isHeader or info.isHeaderWithRep) then rows[info.factionID] = info end
    end
    for _, id in ipairs({ 47, 54, 59, 68, 69, 72, 76, 81, 87, 270, 349, 369, 470, 509, 510, 529, 530, 576, 577, 589, 609, 729, 730, 749, 809, 890, 889, 910, 922, 934, 935, 2802 }) do
        local info = object(call(namespace("C_Reputation", "GetFactionDataByID"), id))
        if info and (not info.isHeader or info.isHeaderWithRep) then rows[id] = info end
    end
    for _, id in ipairs(sortedKeys(rows)) do
        local info = rows[id]
        local reaction = number(info.reaction)
        local standing, lower, upper = number(info.currentStanding), number(info.currentReactionThreshold), number(info.nextReactionThreshold)
        local progress = standing and lower and upper and (fmt(standing - lower) .. "/" .. fmt(upper - lower)) or "unavailable"
        push(ctx, "- " .. clean(info.name) .. ": " .. clean(reaction and _G["FACTION_STANDING_LABEL" .. reaction] or nil) .. "; progress " .. progress .. "; ID " .. id)
    end
    push(ctx, "Coverage: visible factions and Classic factions queryable by ID; a Forever faction hidden in a collapsed group may be missing.")
end

local function section(ctx, title, fn)
    push(ctx)
    push(ctx, "=== " .. title .. " ===")
    local ok = pcall(fn, ctx)
    if not ok then
        push(ctx, "Incomplete section: the client did not allow some data to be read.")
        warn(ctx, "Incomplete section: " .. title .. ". Do not interpret missing data as missing equipment or skills.")
    end
end

NS.ModeLabels = {overview="Overview", talents="Talent points", gear="Gear advice", session="Next session", review="Review plan", compare="Compare items"}
NS.ModeQuestions = {
    overview="Assess whether my character is on the right track for its level and my goals in WoW Forever, using the data above.",
    talents="Recommend my next talent points for my level and goals. Explain the order and trade-offs. Use node IDs only when verified; do not invent an unlisted node ID.",
    gear="Prioritize useful gear upgrades for my current build and budget. Consider existing effects and set bonuses, and explain which upgrades matter most.",
    session="Plan a practical next play session using my level, active quests, professions, goals, and accepted progress plan. Ask about session length when it matters.",
    review="Review my accepted plan against the current character and recorded changes. Explain what is complete, pending, or unverified and suggest an updated plan.",
    compare="Compare candidate A and B for my actual character and goal. Check slot compatibility, weapon restrictions, effects and whole-loadout set changes. Distinguish observed facts from hypothetical equip results.",
}

function NS.BuildReport(options)
    local ctx = { lines = {}, warnings = {}, pending = {}, options = options or {} }
    local mode = NS.ModeLabels[ctx.options.mode] and ctx.options.mode or "overview"
    push(ctx, "CHARACTER CONTEXT — ForeverContext " .. NS.VERSION)
    push(ctx, "Exported: " .. clean(call(date, "%Y-%m-%d %H:%M:%S")))
    push(ctx, "Question: " .. NS.ModeLabels[mode])
    push(ctx, "Player goal and preferences: " .. clean(ctx.options.goal, "Unspecified; ask before assuming PvE, PvP, role, or budget."))
    section(ctx, "CHARACTER", identity)
    section(ctx, "TALENTS", talents)
    section(ctx, "FOREVER LEGACY", legacy)
    section(ctx, "PROFESSIONS", professions)
    if mode ~= "talents" then section(ctx, "EQUIPMENT AND ITEM DETAILS", equipment) end
    section(ctx, "CHARACTER STATS", statistics)
    section(ctx, "ACTIVE BUFFS", auras)
    section(ctx, "SUMMONED PET", pet)
    if ctx.options.extended then
        section(ctx, "SKILLS AND PROFICIENCIES", skills)
        if mode == "overview" or mode == "talents" then section(ctx, "KNOWN SPELLS", spellbook) end
        if mode == "overview" or mode == "review" then section(ctx, "ACTIVE QUESTS", quests) end
        if mode == "overview" or mode == "session" then section(ctx, "REPUTATIONS", reputations) end
    end
    if mode == "session" then section(ctx, "ACTIVE QUESTS", quests) end
    section(ctx, "COVERAGE AND WARNINGS", function()
        push(ctx, "Local out-of-combat game snapshot; excludes a complete gameplay decision history and combat performance. Accepted plans and observed changes are reported separately when available.")
        push(ctx, "Equipment: currently equipped items only; excludes bags, bank, and alternate gear.")
        push(ctx, "Do not add individual item stats to the character stat totals.")
        push(ctx, "Only SET BONUS ACTIVE entries describe enabled set effects. Inactive or unknown entries are not confirmed benefits; repeated bonuses from the same set count once.")
        push(ctx, "Rank tooltips are requested for the current talent rank. REFERENCE ONLY descriptions are not verified rank totals and must not be multiplied automatically.")
        push(ctx, "Repeated talent-currency IDs refer to the same point pool; do not add repeated available balances.")
        if mode ~= "overview" then push(ctx, "Focused question mode: unrelated sections may be omitted. An omitted section does not indicate missing equipment or abilities.") end
        push(ctx, "Unavailable or pending does not mean zero, unlearned, or empty.")
        push(ctx, "Account, BattleTag, chat, friends, and guild data are not exported.")
        for _, message in ipairs(sortedKeys(ctx.warnings)) do push(ctx, "WARNING: " .. message) end
        if next(ctx.pending) then
            push(ctx, "WARNING: " .. count(ctx.pending) .. " pending data entries. Open Talents/Professions, hover over your gear, and click Generate again.")
        end
    end)
    section(ctx, "REQUEST TO THE AI", function()
        push(ctx, NS.ModeQuestions[mode])
        push(ctx, "Prioritize changes: talents and next points, stats and gear upgrades, professions, and skills I should review.")
        push(ctx, "Distinguish major issues from optional upgrades; explain each recommendation and consider level, money, and solo or group play.")
        push(ctx, "Verify that your sources and advice apply to Forever and this version. Do not automatically extrapolate Retail or Classic guides.")
        push(ctx, "If you do not know a Forever item, talent, or rule, say so and request the necessary information. Do not invent effects, locations, or rewards.")
    end)
    return table.concat(ctx.lines, "\n"), count(ctx.pending), count(ctx.warnings)
end

function NS.NormalizeItem(value)
    if secret(value) or type(value) ~= "string" or #value > 2048 then return nil, "Enter an item link or a numeric item ID." end
    value = value:match("^%s*(.-)%s*$")
    local reference = value:match("|H(item:[^|]+)|h") or value
    if reference:match("^%d+$") then reference = "item:" .. reference end
    if not reference:match("^item:%d+[%d:%-]*$") then return nil, "Use a game item link or item ID, not a website URL." end
    for field in reference:sub(6):gmatch("[^:]+") do
        if not field:match("^%-?%d+$") then return nil, "Invalid item reference field." end
    end
    local id = tonumber(reference:match("^item:(%d+)"))
    if not id or id < 1 or id > 10000000 then return nil, "Invalid item ID." end
    return reference
end

function NS.DescribeComparisonItem(value, label)
    local reference, message = NS.NormalizeItem(value)
    if not reference then return label .. ": " .. message, 0, 1 end
    local ctx = {lines={}, pending={}, warnings={}}
    local id = tonumber(reference:match("^item:(%d+)"))
    local name, _, quality, level, required, kind, subkind, _, equipLoc = call(namespace("C_Item", "GetItemInfo") or GetItemInfo, reference)
    if not name then pending(ctx, "item:" .. id); call(namespace("C_Item", "RequestLoadItemDataByID"), id) end
    push(ctx, label .. ": " .. clean(name, "item " .. id) .. " [ID " .. id .. "]")
    push(ctx, "Exact reference: " .. reference)
    push(ctx, "Type: " .. clean(kind) .. " / " .. clean(subkind) .. "; slot type: " .. clean(equipLoc)
        .. "; quality: " .. clean(number(quality) and _G["ITEM_QUALITY" .. quality .. "_DESC"] or nil)
        .. "; item level: " .. fmt(call(namespace("C_Item", "GetDetailedItemLevelInfo") or GetDetailedItemLevelInfo, reference) or level)
        .. "; required level: " .. fmt(required))
    if reference:match("^item:%d+$") then
        push(ctx, "BASE ITEM REFERENCE: variant, enchant and gem details were not supplied; use the full game link for an exact comparison.")
        warn(ctx, "A comparison candidate uses only a base item ID.")
    end
    local stats = object(call(namespace("C_Item", "GetItemStats") or GetItemStats, reference))
    if stats then push(ctx, "Item stats: " .. table.concat(itemStatEntries(ctx, stats), "; ")) end
    local lines = equipmentTooltip(call(namespace("C_TooltipInfo", "GetHyperlink"), reference))
    if #lines == 0 then pending(ctx, "tooltip:" .. id); push(ctx, "Candidate effects: pending or unavailable.") end
    for _, line in ipairs(lines) do push(ctx, line) end
    for _, warning in ipairs(sortedKeys(ctx.warnings)) do push(ctx, "WARNING: " .. warning) end
    return table.concat(ctx.lines, "\n"), count(ctx.pending), count(ctx.warnings)
end

NS.Clean = clean
NS.SafeCall = call
NS.ReadNumber = number
NS.ReadTable = object
