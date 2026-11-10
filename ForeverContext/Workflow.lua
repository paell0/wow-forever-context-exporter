local _, NS = ...

function NS.SetCandidate(slot, value)
    if slot ~= "A" and slot ~= "B" then return nil, "Choose candidate A or B." end
    local reference, message = NS.NormalizeItem(value)
    if not reference then return nil, message end
    NS.CharacterState().candidates[slot] = reference
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
    local report, pending, warnings = NS.BuildReport(options)
    local snapshot = NS.CaptureSnapshot()
    local parts = {report, NS.ProgressText(snapshot)}
    if options.mode == "compare" then
        parts[#parts + 1] = "=== ITEM COMPARISON CANDIDATES ==="
        parts[#parts + 1] = "These are candidate items, not additional equipped bonuses. Set counts in their tooltips describe the current character, not a recalculated hypothetical loadout."
        for _, slot in ipairs({"A", "B"}) do
            local candidate = NS.CharacterState().candidates[slot]
            if candidate then
                local text, morePending, moreWarnings = NS.DescribeComparisonItem(candidate, "Candidate " .. slot)
                parts[#parts + 1] = text
                pending, warnings = pending + morePending, warnings + moreWarnings
            else
                parts[#parts + 1] = "Candidate " .. slot .. ": missing. Add both items in Compare items before deciding."
                warnings = warnings + 1
            end
        end
    end
    parts[#parts + 1] = "=== FOLLOW-UP REQUEST ===\n" .. (NS.ModeQuestions[options.mode] or NS.ModeQuestions.overview)
    parts[#parts + 1] = "The accepted plan and manual task labels are player-supplied context, not verified game rules. Review progress before replacing advice. " .. NS.PlanInstructions
    return table.concat(parts, "\n\n"), pending, warnings, snapshot
end
