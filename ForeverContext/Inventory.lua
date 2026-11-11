local _, NS = ...
local call, clean, number, object = NS.SafeCall, NS.Clean, NS.ReadNumber, NS.ReadTable

function NS.ReadBags()
    local rows, warnings = {}, {}
    if not C_Container or type(C_Container.GetContainerNumSlots) ~= "function" or type(C_Container.GetContainerItemInfo) ~= "function" then
        return rows, {"Carried-bag API unavailable; inventory is unknown, not empty."}
    end
    local lastBag = math.min(number(NUM_TOTAL_EQUIPPED_BAG_SLOTS) or number(NUM_BAG_SLOTS) or 4, 8)
    for bag = 0, lastBag do
        local slots = number(call(C_Container.GetContainerNumSlots, bag))
        if not slots or slots < 0 or slots > 100 then
            warnings[#warnings+1] = "Bag " .. bag .. ": slot count unavailable."
        else
            for slot = 1, slots do
                if #rows >= 400 then warnings[#warnings+1] = "Bag export stopped at the 400-item safety limit."; return rows, warnings end
                local ok, raw = pcall(C_Container.GetContainerItemInfo, bag, slot)
                local info = object(raw)
                if not ok or (raw ~= nil and not info) then
                    warnings[#warnings+1] = "Bag " .. bag .. " slot " .. slot .. ": data unavailable."
                else
                    local reference = info and NS.NormalizeItem(info.hyperlink)
                        or NS.NormalizeItem(call(C_Container.GetContainerItemLink, bag, slot))
                    local id = info and number(info.itemID) or reference and NS.ItemID(reference)
                    if info or reference then
                        reference = reference or (id and "item:" .. id)
                        local name, _, quality, level, required, kind, subkind, _, equipLoc, _, price, classID, _, _, _, _, reagent = call(C_Item and C_Item.GetItemInfo or GetItemInfo, reference or id)
                        local _, _, _, instantLoc = call(C_Item and C_Item.GetItemInfoInstant, reference or id)
                        local hasEquipLoc = type(equipLoc) == "string" and not (issecretvalue and issecretvalue(equipLoc))
                        equipLoc = clean(equipLoc, "")
                        if not hasEquipLoc then equipLoc = clean(instantLoc, "") end
                        if not name and id then call(C_Item and C_Item.RequestLoadItemDataByID, id) end
                        local isReagent
                        if not (type(issecretvalue) == "function" and issecretvalue(reagent)) then isReagent = reagent == true end
                        rows[#rows+1] = {bag=bag, slot=slot, itemID=id, reference=reference,
                            name=clean(name, info and clean(info.itemName, "item data pending") or "item data pending"),
                            count=info and number(info.stackCount), quality=number(quality) or (info and number(info.quality)),
                            level=number(level), required=number(required), equipLoc=equipLoc,
                            kind=clean(kind), subkind=clean(subkind), classID=number(classID),
                            reagent=isReagent, price=number(price), pending=not name or not reference}
                    end
                end
            end
        end
    end
    return rows, warnings
end

function NS.BagItemText(row, options, detailed)
    local lines = {"Bag " .. row.bag .. ", slot " .. row.slot .. ": " .. row.name
        .. " [item " .. (row.itemID or "unknown") .. "]; quantity " .. (row.count or "UNKNOWN")}
    lines[#lines+1] = "Type: " .. row.kind .. " / " .. row.subkind .. "; equip slot: " .. (row.equipLoc ~= "" and row.equipLoc or "none / unknown")
        .. "; crafting reagent: " .. (row.reagent == true and "yes" or "not confirmed")
    lines[#lines+1] = "Vendor sell price per item: " .. (row.price and tostring(row.price) .. " copper" or "UNKNOWN") .. ". Vendor price is not auction value or usefulness."
    local keep = row.itemID and NS.AdviceState().keepItems[row.itemID]
    if NS.ModuleEnabled(options, "preservation") then
        lines[#lines+1] = keep and "KEEP / ALL COPIES: " .. clean(keep.reason) or "No keep preference recorded; do not assume disposable."
    end
    if detailed and row.reference then
        local text, pending, warnings = NS.DescribeComparisonItem(row.reference, "Carried item")
        lines[#lines+1] = text
        return table.concat(lines, "\n"), pending, warnings
    end
    if row.reference then lines[#lines+1] = "Exact reference: " .. row.reference end
    return table.concat(lines, "\n"), row.pending and 1 or 0, 0
end

function NS.IsBagEquipment(row)
    local slot=row.equipLoc
    return type(slot)=="string" and slot~="" and slot~="INVTYPE_NON_EQUIP_IGNORE" and slot~="INVTYPE_BAG" and slot~="INVTYPE_QUIVER"
end

function NS.BagsText(options)
    local rows, issues = NS.ReadBags()
    local lines = {"=== CARRIED BAG ITEMS ===", "Only equipped carried bags are scanned. Bank, mail and other characters are excluded. Counts are stack quantities. No items are moved or disposed of."}
    local pending, warnings, details = 0, #issues, 0
    for _, issue in ipairs(issues) do lines[#lines+1] = "WARNING: " .. issue end
    for _, row in ipairs(rows) do
        local detailed = NS.IsBagEquipment(row) and details < 80
        if detailed then details=details+1 end
        local text, p, w = NS.BagItemText(row, options, detailed)
        lines[#lines+1] = text
        pending, warnings = pending+p, warnings+w
    end
    if details == 80 then lines[#lines+1] = "Detailed effect text is limited to the first 80 carried equipment entries; other item references/quantities remain included." end
    if #rows == 0 and #issues == 0 then lines[#lines+1] = "No carried items observed." end
    return table.concat(lines, "\n\n"), pending, warnings, rows
end
