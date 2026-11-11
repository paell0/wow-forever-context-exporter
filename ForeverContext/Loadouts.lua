local _, NS = ...
local call, clean, number, object = NS.SafeCall, NS.Clean, NS.ReadNumber, NS.ReadTable

local function text(value, max)
    if type(value) ~= "string" or value:find("[|\r\n]") then return nil end
    value = clean(value, "")
    return value ~= "" and #value <= max and value or nil
end

local function integer(value, max, allowZero)
    if type(value) ~= "string" or not value:match("^%d+$") then return nil end
    local n = tonumber(value)
    return n and n >= (allowZero and 0 or 1) and n <= max and n or nil
end

function NS.CaptureTalentProfile(name, activity)
    name, activity = text(name, 80), text(activity, 120)
    if not name or not activity then return nil, "Enter a profile name (80 bytes) and activity (120 bytes), without pipes or line breaks." end
    local snapshot = NS.CaptureSnapshot()
    if not snapshot.talentsReadable then return nil, "Committed talents cannot be verified. Apply/cancel staged changes and reopen Talents first." end
    local _, class = call(UnitClass, "player")
    class = clean(class, "")
    if class == "" then return nil, "Character class unavailable." end
    local group = number(call(C_SpecializationInfo and C_SpecializationInfo.GetActiveSpecGroup or GetActiveSpecGroup)) or 1
    local config = number(call(C_SpecializationInfo and C_SpecializationInfo.GetCombatConfigIDForSpecGroup, group))
        or number(call(C_ClassTalents and C_ClassTalents.GetActiveConfigID))
    local native = call(C_Traits and C_Traits.GenerateImportString, config)
    if type(native) ~= "string" or (issecretvalue and issecretvalue(native)) or #native > 8192 or not native:match("^[%w+/=:_%-]+$") then native = nil end
    local profile = {name=name, activity=activity, class=class, level=snapshot.level, build=snapshot.build,
        at=snapshot.at, native=native, nodes={}}
    local count = 0
    for id, rank in pairs(snapshot.talents) do
        count=count+1
        if count > 512 then return nil, "Talent tree exceeds the profile's 512-node limit." end
        local info = object(call(C_Traits and C_Traits.GetNodeInfo, config, id))
        local entry = info and object(info.activeEntry)
        if not info or (rank > 0 and (not entry or not number(entry.entryID))) then return nil, "A talent selection is unavailable. Open Talents and capture again." end
        profile.nodes[id] = {rank=rank, entry=entry and number(entry.entryID) or 0}
    end
    if count == 0 then return nil, "No readable talent nodes found." end
    return profile
end

function NS.ParseTalentProfile(input)
    if type(input) ~= "string" or #input > 40000 then return nil, "Profile text must be at most 40,000 bytes." end
    input = input:gsub("\r\n", "\n"):gsub("\r", "\n"):gsub("^\239\187\191", "")
    input = input:match("^%s*(.-)%s*$"):gsub("^```[%w_-]*%s*\n", ""):gsub("\n```%s*$", "")
    local profile, started, seen, count = {nodes={}, at=NS.ClientStamp().at}, false, {}, 0
    for line in (input .. "\n"):gmatch("(.-)\n") do
        if line ~= "" then
            if not started then
                if line ~= "FCLOADOUT/1" then return nil, "First line must be FCLOADOUT/1." end
                started = true
            else
                local fields = {}
                for field in (line .. "|"):gmatch("(.-)|") do fields[#fields+1]=field end
                local kind = fields[1]
                if kind == "NODE" and #fields == 4 then
                    local id, rank, entry = integer(fields[2], 10000000), integer(fields[3], 1000, true), integer(fields[4], 10000000, true)
                    if not id or rank == nil or entry == nil or (rank > 0 and entry == 0) or profile.nodes[id] or count >= 512 then return nil, "Invalid, duplicate or excessive talent nodes." end
                    profile.nodes[id], count = {rank=rank, entry=entry}, count+1
                elseif #fields == 2 and not seen[kind] then
                    seen[kind] = true
                    local value = fields[2]
                    if kind == "NAME" then profile.name=text(value,80)
                    elseif kind == "ACTIVITY" then profile.activity=text(value,120)
                    elseif kind == "CLASS" and value:match("^[A-Z]+$") and #value <= 20 then profile.class=value
                    elseif kind == "BUILD" and value:match("^%d+$") and #value <= 12 then profile.build=value
                    elseif kind == "LEVEL" then profile.level=integer(value,1000)
                    elseif kind == "NATIVE" and #value <= 8192 and value:match("^[%w+/=:_%-]+$") then profile.native=value
                    else return nil, "Unknown or invalid profile field: " .. clean(kind) end
                else return nil, "Invalid or duplicate profile fields." end
            end
        end
    end
    if not started or not profile.name or not profile.activity or not profile.class or not profile.build or not profile.level or count == 0 then
        return nil, "Profile requires NAME, ACTIVITY, CLASS, BUILD, LEVEL and at least one NODE." end
    profile.imported = true
    return profile
end

function NS.TalentProfileText(profile)
    local lines = {"FCLOADOUT/1", "NAME|" .. profile.name, "ACTIVITY|" .. profile.activity,
        "CLASS|" .. profile.class, "BUILD|" .. profile.build, "LEVEL|" .. (profile.level or 1)}
    if profile.native then lines[#lines+1]="NATIVE|" .. profile.native end
    for _, id in ipairs(NS.SortedIDs(profile.nodes)) do
        local node = profile.nodes[id]
        lines[#lines+1]="NODE|" .. id .. "|" .. node.rank .. "|" .. node.entry
    end
    return table.concat(lines, "\n")
end

function NS.SaveTalentProfile(profile)
    -- Reparse our data representation so only the bounded format reaches saves.
    if type(profile) ~= "table" then return nil, "Preview or capture a profile first." end
    local parsed, message = NS.ParseTalentProfile(NS.TalentProfileText(profile))
    if not parsed then return nil, message end
    local state, count = NS.AdviceState(), 0
    for _ in pairs(state.talentProfiles) do count=count+1 end
    if not state.talentProfiles[parsed.name] and count >= 12 then return nil, "Keep at most 12 profiles; remove an old one first." end
    parsed.imported = profile.imported == true
    state.talentProfiles[parsed.name] = parsed
    state.selectedTalentProfile = parsed.name
    NS.TouchAdvice()
    return true
end

function NS.TalentProfileNames()
    local names = {}
    for name in pairs(NS.AdviceState().talentProfiles) do names[#names+1]=name end
    table.sort(names)
    return names
end

function NS.SelectTalentProfile(name)
    local state = NS.AdviceState()
    if name ~= nil and not state.talentProfiles[name] then return false end
    if state.selectedTalentProfile == name then return true end
    state.selectedTalentProfile=name
    NS.TouchAdvice()
    return true
end

function NS.RemoveTalentProfile(name)
    local state = NS.AdviceState()
    state.talentProfiles[name]=nil
    if state.selectedTalentProfile == name then state.selectedTalentProfile=nil end
    NS.TouchAdvice()
end

function NS.TalentProfileAdvice(snapshot, options)
    local state = NS.AdviceState()
    local profile = state.talentProfiles[state.selectedTalentProfile or ""]
    if not profile then return "=== ACTIVITY TALENT PROFILE ===\nNo activity profile selected.", 0 end
    local _, class = call(UnitClass, "player")
    local lines = {"=== ACTIVITY TALENT PROFILE ===", "Selected: " .. profile.name .. "; activity: " .. profile.activity,
        "Saved for " .. profile.class .. " level " .. profile.level .. "; build " .. profile.build .. "; saved " .. clean(profile.at),
        "Player-supplied target profile, not an automatically verified recommendation. No talents have been applied."}
    local warnings = 0
    if profile.class ~= class then lines[#lines+1]="CLASS MISMATCH: this profile cannot be assumed suitable for this character."; return table.concat(lines,"\n"),1 end
    if profile.build ~= snapshot.build then warnings=warnings+1; lines[#lines+1]="PROFILE OUTDATED / RECHECK: talent IDs or rules may differ on this client build." end
    if not snapshot.talentsReadable then lines[#lines+1]="Current committed talents UNKNOWN; no rank differences calculated."; return table.concat(lines,"\n"),warnings+1 end
    local group = number(call(C_SpecializationInfo and C_SpecializationInfo.GetActiveSpecGroup or GetActiveSpecGroup)) or 1
    local config = number(call(C_SpecializationInfo and C_SpecializationInfo.GetCombatConfigIDForSpecGroup, group))
        or number(call(C_ClassTalents and C_ClassTalents.GetActiveConfigID))
    local differences = 0
    for _, id in ipairs(NS.SortedIDs(profile.nodes)) do
        local desired, current = profile.nodes[id], snapshot.talents[id]
        local info = object(call(C_Traits and C_Traits.GetNodeInfo, config, id))
        local active = info and object(info.activeEntry)
        local entry = active and number(active.entryID) or 0
        local invalid = info and number(info.maxRanks) and desired.rank > info.maxRanks
        local choices = info and object(info.entryIDs)
        if choices and desired.rank > 0 then
            local found=false
            for _, choice in ipairs(choices) do if choice == desired.entry then found=true end end
            if not found then invalid=true end
        end
        if invalid then lines[#lines+1]="Node " .. id .. ": INVALID TARGET for the client's rank limit / available entries"; differences=differences+1; warnings=warnings+1
        elseif current == nil then lines[#lines+1]="Node " .. id .. ": UNKNOWN on current tree"; differences=differences+1
        elseif current ~= desired.rank or (desired.rank > 0 and desired.entry ~= entry) then
            lines[#lines+1]="Node " .. id .. ": committed rank " .. current .. " -> target " .. desired.rank .. "; entry " .. entry .. " -> " .. desired.entry
            differences=differences+1
        end
    end
    -- Missing target nodes are unknown targets, never an instruction to reset.
    for id, rank in pairs(snapshot.talents) do
        if rank > 0 and not profile.nodes[id] then lines[#lines+1]="Node " .. id .. ": committed " .. rank .. "; target UNSPECIFIED"; differences=differences+1 end
    end
    if differences == 0 then lines[#lines+1]="All recorded ranks and active selections match the target profile." end
    if profile.native then lines[#lines+1]="Game import code available in Talent profiles. The player must review compatibility and confirm in the game's talent UI." end
    return table.concat(lines,"\n"),warnings
end
