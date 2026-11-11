local _, NS = ...

function NS.SetCandidate(slot, value)
    if slot ~= "A" and slot ~= "B" then return nil, "Choose candidate A or B." end
    local reference, message = NS.NormalizeItem(value)
    if not reference then return nil, message end
    if NS.CharacterState().candidates[slot] ~= reference then
        NS.CharacterState().candidates[slot] = reference
        NS.TouchAdvice()
    end
    return reference
end

function NS.CursorItemReference()
    local call = NS.SafeCall
    local kind, id, link = call(GetCursorInfo)
    if type(issecretvalue) == "function" and issecretvalue(kind) then return nil, "Cursor data is unavailable." end
    if kind == "item" then
        if type(link) == "string" then return NS.NormalizeItem(link) end
        local itemID = NS.ReadNumber(id)
        if itemID then return NS.NormalizeItem(tostring(itemID)) end
    end
    local location = C_Cursor and call(C_Cursor.GetCursorItem)
    if location and C_Item then
        local reference = call(C_Item.GetItemLink, location)
        if reference then return NS.NormalizeItem(reference) end
    end
    return nil, "Drag an item from your equipment or bags, or paste its game link."
end

function NS.BuildExport(options)
    options = options or NS.CharacterSettings()
    local comparing=options.mode=="compare"
    local comparison, candidateIDs, candidatePending, candidateWarnings=nil,{},0,0
    if comparing then
        local lines={"=== ITEM COMPARISON CANDIDATES ===",
            "These are candidate items, not additional equipped bonuses. Set counts in their tooltips describe the current character, not a recalculated hypothetical loadout."}
        for _, slot in ipairs({"A","B"}) do
            local candidate=NS.CharacterState().candidates[slot]
            if candidate then
                local text,p,w=NS.DescribeComparisonItem(candidate,"Candidate " .. slot)
                lines[#lines+1]=text
                candidatePending,candidateWarnings=candidatePending+p,candidateWarnings+w
                local id=NS.ItemID(candidate)
                if id then candidateIDs[id]=true end
            else
                lines[#lines+1]="Candidate " .. slot .. ": missing. Add both items under More tools > Compare two items before deciding."
                candidateWarnings=candidateWarnings+1
            end
        end
        comparison=table.concat(lines,"\n\n")
    end
    local report, pending, warnings = NS.BuildReport(options,comparison)
    pending,warnings=pending+candidatePending,warnings+candidateWarnings
    local snapshot = NS.CaptureSnapshot()
    local parts, bagRows = {report}, nil
    local state=NS.CharacterState()
    if NS.ModuleEnabled(options, "progress") and (not comparing or state.plan or state.history[1]) then parts[#parts+1] = NS.ProgressText(snapshot, options) end
    if NS.ModuleEnabled(options, "preservation") then parts[#parts+1] = NS.KeepText()
    else parts[#parts+1] = "Preservation preferences withheld. Do not recommend disposing of any item without asking the player." end
    if NS.ModuleEnabled(options, "bags") and not comparing then
        local text, p, w, rows = NS.BagsText(options)
        bagRows = rows
        parts[#parts+1] = text
        pending, warnings = pending+p, warnings+w
    end
    if NS.ModuleEnabled(options, "sources") then
        local sources = {"=== ITEM ORIGINS / SOURCE NOTEBOOK ==="}
        if options.spoilerFree then
            sources[#sources+1] = "Item origins withheld by spoiler-free preference."
        else
            local relevant = comparing and candidateIDs or {}
            if options.mode == "sources" then for _, entry in ipairs(NS.SourceRecords()) do relevant[entry.record.itemID]=true end end
            if not comparing and NS.ModuleEnabled(options, "equipment") and options.mode ~= "talents" then
                for _, id in pairs(snapshot.slots) do if id > 0 then relevant[id]=true end end
            end
            if NS.ModuleEnabled(options, "bags") then
                for _, row in ipairs(bagRows or {}) do if row.itemID then relevant[row.itemID]=true end end
            end
            for _, id in ipairs(NS.SortedIDs(relevant)) do sources[#sources+1] = NS.SourceText(id, options) end
            if not next(relevant) then sources[#sources+1] = "No item context selected. Use Sources to record a referenced origin; unknown future upgrades need external verification." end
        end
        parts[#parts+1] = table.concat(sources,"\n")
    end
    if NS.ModuleEnabled(options, "loadouts") and NS.ModuleEnabled(options, "talents") and (not comparing or NS.AdviceState().selectedTalentProfile) then
        local text, w = NS.TalentProfileAdvice(snapshot, options)
        parts[#parts+1] = text
        warnings = warnings+w
    end
    local freshness, w = NS.FreshnessText(options,comparing and candidateIDs or nil)
    parts[#parts+1] = freshness
    warnings=warnings+w
    if not comparing then parts[#parts + 1] = "=== FOLLOW-UP REQUEST ===\n" .. (NS.ModeQuestions[options.mode] or NS.ModeQuestions.overview) end
    parts[#parts + 1] = "Use only exported categories. Player notes and selected profiles are preferences, not verified game rules. Review progress before replacing advice."
    if not comparing and NS.ModuleEnabled(options, "progress") then parts[#parts+1] = NS.PlanInstructions end
    if options.spoilerFree then parts[#parts+1] = "SPOILER-FREE REQUEST: do not reveal future rewards, quest/story outcomes, boss names, undiscovered locations or routes. Give general advice using current exported facts; ask before spoilers." end
    return table.concat(parts, "\n\n"), pending, warnings, snapshot
end
