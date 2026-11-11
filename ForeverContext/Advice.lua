local _, NS = ...
local call, clean, number, object = NS.SafeCall, NS.Clean, NS.ReadNumber, NS.ReadTable

NS.ModuleDefinitions = {
    {"talents", "Current talents", true}, {"legacy", "Legacy trees", true},
    {"professions", "Professions", true}, {"equipment", "Equipped items", true},
    {"stats", "Character stats", true}, {"buffs", "Buffs", true}, {"pet", "Summoned pet", true},
    {"skills", "Skills / proficiencies", true}, {"spells", "Known spells", true},
    {"quests", "Active quests", true}, {"reputations", "Reputations", true},
    {"bags", "Carried bags (opt-in)", false}, {"sources", "Item source notebook", true},
    {"progress", "Accepted plan / changes", true}, {"loadouts", "Selected talent profile", true},
    {"preservation", "Keep-list preferences", true},
}

function NS.ModuleEnabled(options, key)
    options = options or {}
    if type(options.modules) == "table" and type(options.modules[key]) == "boolean" then return options.modules[key] end
    return key ~= "bags"
end

function NS.ProfessionSkillIDs()
    local ids = {}
    for _, id in ipairs({129,164,165,171,182,185,186,197,202,333,356,393,755,773,794}) do ids[id]=true end
    local professions={call(GetProfessions)}
    for index=1,6 do
        if number(professions[index]) then
            local _,_,_,_,_,_,id=call(GetProfessionInfo,professions[index])
            if number(id) then ids[id]=true end
        end
    end
    return ids
end

function NS.AdviceState()
    local state = NS.CharacterState()
    for _, key in ipairs({"sources", "keepItems", "talentProfiles"}) do
        if type(state[key]) ~= "table" then state[key] = {} end
    end
    local options = state.options
    if type(options.modules) ~= "table" then options.modules = {} end
    return state
end

function NS.TouchAdvice()
    local state = NS.AdviceState()
    state.progressVersion = NS.ProgressVersion() + 1
end

function NS.ClientStamp()
    local version, build, _, interface = call(GetBuildInfo)
    return {client=clean(version), build=clean(build), interface=number(interface),
        at=clean(call(date, "%Y-%m-%d %H:%M:%S"))}
end

function NS.SetModule(key, enabled)
    for _, row in ipairs(NS.ModuleDefinitions) do
        if row[1] == key then
            NS.AdviceState().options.modules[key] = enabled == true
            NS.TouchAdvice()
            return true
        end
    end
    return false
end

function NS.SetSpoilerFree(enabled)
    NS.AdviceState().options.spoilerFree = enabled == true
    NS.TouchAdvice()
end

function NS.ItemID(value)
    local reference, message = NS.NormalizeItem(type(value) == "number" and tostring(value) or value)
    if not reference then return nil, message end
    return tonumber(reference:match("^item:(%d+)")), reference
end

function NS.ItemName(id)
    return clean(call(C_Item and C_Item.GetItemInfo or GetItemInfo, "item:" .. id), "item " .. id)
end

function NS.SortedIDs(values)
    local ids = {}
    for id in pairs(values) do if number(id) then ids[#ids+1] = id end end
    table.sort(ids)
    return ids
end

function NS.KeepItem(value, reason)
    local id, message = NS.ItemID(value)
    if not id then return nil, message end
    local state = NS.AdviceState()
    if not state.keepItems[id] and #NS.SortedIDs(state.keepItems) >= 100 then return nil, "The keep list is limited to 100 item IDs." end
    reason = clean(reason, "Keep for personal use")
    if #reason > 240 then return nil, "Keep reasons must be at most 240 bytes." end
    state.keepItems[id] = {reason=reason, at=NS.ClientStamp().at}
    NS.TouchAdvice()
    return id
end

function NS.RemoveKeepItem(value)
    local id = NS.ItemID(value)
    local state = NS.AdviceState()
    if id and state.keepItems[id] then state.keepItems[id] = nil; NS.TouchAdvice(); return true end
    return false
end

function NS.KeepText()
    local state = NS.AdviceState()
    local lines = {"=== ITEMS TO KEEP ===", "Player preferences: preserve every copy/variant of these item IDs. Do not suggest selling, destroying, disenchanting, or consuming them; offer alternatives."}
    for _, id in ipairs(NS.SortedIDs(state.keepItems)) do
        lines[#lines+1] = "KEEP " .. NS.ItemName(id) .. " [item " .. id .. "]: " .. clean(state.keepItems[id].reason)
    end
    if #lines == 2 then lines[#lines+1] = "No item IDs protected. This is not permission to dispose of other items; ask before recommending irreversible choices." end
    return table.concat(lines, "\n")
end

NS.SourceKinds = {"Dungeon", "Quest", "Vendor", "Profession", "Other"}

local function sourceKey(id, kind, location)
    return id .. ":" .. kind .. ":" .. location
end

local function putSource(id, kind, location, reference, provenance, stamp, evidenceID)
    local state = NS.AdviceState()
    local key = sourceKey(id, kind, location)
    local count = 0
    for _ in pairs(state.sources) do count = count+1 end
    if not state.sources[key] and count >= 300 then return nil, "The source notebook is limited to 300 records. Remove an old record first." end
    local existing = state.sources[key]
    -- Visiting an already checked vendor must not erase a player's reference.
    if existing and existing.build == stamp.build and existing.provenance == "PLAYER-CONFIRMED" and provenance == "OBSERVED IN GAME" then return key end
    if existing and existing.build == stamp.build and existing.provenance == provenance and existing.reference == reference then return key end
    state.sources[key] = {itemID=id, kind=kind, location=location, reference=reference, provenance=provenance,
        build=stamp.build, client=stamp.client, at=stamp.at, evidenceID=evidenceID}
    NS.TouchAdvice()
    return key
end

function NS.SaveItemSource(value, kind, location, reference, confirmed)
    local id, message = NS.ItemID(value)
    if not id then return nil, message end
    local valid = false
    for _, candidate in ipairs(NS.SourceKinds) do if candidate == kind then valid = true end end
    location, reference = clean(location, ""), clean(reference, "")
    if not valid or location == "" or #location > 160 or #reference > 500 then
        return nil, "Choose a source type and enter a location/note (160 bytes) and optional reference (500 bytes)."
    end
    if reference ~= "" and not reference:match("^https://[%w%.%-]+[/#?]?.*$") then return nil, "References must be HTTPS page URLs, or leave the reference empty." end
    return putSource(id, kind, location, reference, confirmed and "PLAYER-CONFIRMED" or "UNCONFIRMED", NS.ClientStamp())
end

function NS.SourceRecords(id)
    local records = {}
    for key, record in pairs(NS.AdviceState().sources) do
        if type(record) == "table" and (not id or record.itemID == id) then records[#records+1] = {key=key, record=record} end
    end
    table.sort(records, function(a,b) return a.key < b.key end)
    return records
end

function NS.SourceStatus(record)
    if record.build ~= NS.ClientStamp().build then return (record.provenance or "UNCONFIRMED") .. " / OUTDATED / RECHECK" end
    return record.provenance or "UNCONFIRMED"
end

function NS.SourceText(id, options)
    if options and options.spoilerFree then return "Item origins withheld by spoiler-free preference." end
    local lines = {}
    for _, entry in ipairs(NS.SourceRecords(id)) do
        local r = entry.record
        lines[#lines+1] = "Item " .. r.itemID .. " [" .. NS.SourceStatus(r) .. "]: " .. clean(r.kind) .. " — " .. clean(r.location)
            .. "; reference: " .. clean(r.reference, "No external reference recorded")
            .. "; recorded " .. clean(r.at) .. "; build " .. clean(r.build)
    end
    if #lines == 0 then lines[1] = "Origin NOT CONFIRMED" .. (id and " for item " .. id or ": no source records yet") .. ". Do not substitute Classic loot tables." end
    return table.concat(lines, "\n")
end

function NS.RemoveItemSource(key)
    local sources = NS.AdviceState().sources
    if sources[key] then sources[key] = nil; NS.TouchAdvice(); return true end
    return false
end

function NS.ObserveMerchantSources(fromEvent)
    if NS.AdviceState().options.observeSources == false or (InCombatLockdown and InCombatLockdown()) then return 0 end
    if not fromEvent and (not MerchantFrame or not MerchantFrame:IsShown()) then return 0 end
    local name = clean(call(UnitName, "npc"), "")
    if name == "" then return 0 end
    local stamp, count = NS.ClientStamp(), 0
    for index = 1, math.min(number(call(GetMerchantNumItems)) or 0, 200) do
        local id = NS.ItemID(call(GetMerchantItemLink, index))
        if id then
            local key = putSource(id, "Vendor", name .. " — " .. clean(call(GetRealZoneText)),
                "Observed merchant offer", "OBSERVED IN GAME", stamp)
            if key then count=count+1 end
        end
    end
    return count
end

function NS.ObserveQuestSources(fromEvent)
    if NS.AdviceState().options.observeSources == false or (InCombatLockdown and InCombatLockdown()) then return 0 end
    if not fromEvent and (not QuestFrame or not QuestFrame:IsShown()) then return 0 end
    local quest = number(call(GetQuestID))
    if not quest or quest <= 0 then return 0 end
    local stamp, count = NS.ClientStamp(), 0
    for _, row in ipairs({{"reward", GetNumQuestRewards}, {"choice", GetNumQuestChoices}}) do
        for index = 1, math.min(number(call(row[2])) or 0, 32) do
            local id = NS.ItemID(call(GetQuestItemLink, row[1], index))
            if id then
                local key = putSource(id, "Quest", "Quest " .. quest .. " — " .. row[1] .. " shown by the client",
                    "Observed quest reward; not a completion or ownership claim", "OBSERVED IN GAME", stamp, quest)
                if key then count=count+1 end
            end
        end
    end
    return count
end

function NS.ReviewPlanForBuild()
    local plan = NS.CharacterState().plan
    if not plan then return nil, "No accepted plan to review." end
    plan.reviewedBuild, plan.reviewedAt = NS.ClientStamp().build, NS.ClientStamp().at
    NS.TouchAdvice()
    return true
end

function NS.FreshnessText(options)
    options = options or NS.CharacterSettings()
    local stamp, state = NS.ClientStamp(), NS.AdviceState()
    local lines = {"=== DATA FRESHNESS ===", "Current client: " .. stamp.client .. "; build " .. stamp.build .. "; addon " .. NS.VERSION}
    local warnings = 0
    if NS.ModuleEnabled(options, "progress") and state.plan then
        local reference = state.plan.reviewedBuild or (state.plan.baseline and state.plan.baseline.build)
        if reference ~= stamp.build then warnings=warnings+1; lines[#lines+1] = "PLAN OUTDATED / RECHECK: recorded for build " .. clean(reference) .. ". Re-evaluate advice before following it."
        else lines[#lines+1] = "Plan reference/review matches this build. This does not verify the AI's recommendations." end
    end
    if NS.ModuleEnabled(options, "sources") and not options.spoilerFree then
        local stale = 0
        for _, entry in ipairs(NS.SourceRecords()) do if entry.record.build ~= stamp.build then stale=stale+1 end end
        if stale > 0 then warnings=warnings+1; lines[#lines+1] = stale .. " source records are from another build and need checking." end
    end
    lines[#lines+1] = "No automatic internet rule updates. Dates/builds show provenance, not proof that all game rules or drops are known."
    lines[#lines+1] = options.spoilerFree and "Cite Forever-specific rules without revealing new sources, rewards or locations. Ask before spoilers."
        or "For proposed upgrades, cite a Forever-specific reference, source location and verification date; label unverified claims."
    return table.concat(lines, "\n"), warnings
end

local events = CreateFrame("Frame")
for _, event in ipairs({"MERCHANT_SHOW", "MERCHANT_UPDATE", "QUEST_DETAIL", "QUEST_COMPLETE"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" then NS.ObserveMerchantSources(true) else NS.ObserveQuestSources(true) end
end)
