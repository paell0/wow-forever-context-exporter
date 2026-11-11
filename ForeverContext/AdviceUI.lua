local _, NS = ...
local label, button, edit, check = NS.ToolLabel, NS.ToolButton, NS.ToolEdit, NS.ToolCheck
local preferences, bags, keep, sources, loadouts

local function dropInto(input, status)
    local reference, message = NS.CursorItemReference()
    if reference then
        input:SetText(reference)
        NS.SafeCall(ClearCursor)
        status:SetText("Item selected. Review the fields, then save.")
    else status:SetText(message) end
end

local function makePreferences()
    local frame=NS.CreateToolWindow("ForeverContextOptionsWindow", "ForeverContext — Export options", "Choose your report categories. Identity/client basics stay included. Settings are per character.", 610)
    preferences=frame
    frame.checks={}
    for i,row in ipairs(NS.ModuleDefinitions) do
        local key=row[1]
        frame.checks[key]=check(frame,row[2],20+math.floor((i-1)/8)*370,-85-((i-1)%8)*33,false,function(value) NS.SetModule(key,value) end)
    end
    frame.spoilers=check(frame,"Spoiler-free advice (hides quests and item origins)",20,-365,false,function(value) NS.SetSpoilerFree(value) end)
    frame.observe=check(frame,"Record sources from visited merchants / displayed quest rewards",20,-403,true,function(value)
        NS.AdviceState().options.observeSources=value; NS.TouchAdvice()
    end)
    label(frame,"Skills, spells, quests and reputations also follow the report's extra-details switch and purpose.\nThe AI is asked to honor spoiler preferences; its replies cannot be controlled by the addon.",20,-450,710)
    frame.status=label(frame,"",20,-501,710)
    frame.defaults=button(frame,"Restore defaults",20,-555,155,function()
        local options=NS.AdviceState().options
        options.modules={}; options.spoilerFree=false; options.observeSources=true
        NS.TouchAdvice(); NS.OpenPreferencesWindow()
    end)
    frame.report=button(frame,"Generate report",555,-555,175,function() NS.OpenReport() end)
end

function NS.OpenPreferencesWindow()
    if not NS.ToolsAllowed() then return end
    if not preferences then makePreferences() end
    local options=NS.AdviceState().options
    for key,widget in pairs(preferences.checks) do widget:SetChecked(NS.ModuleEnabled(options,key)) end
    preferences.spoilers:SetChecked(options.spoilerFree==true)
    preferences.observe:SetChecked(options.observeSources~=false)
    preferences.status:SetText("Client build " .. NS.ClientStamp().build .. "; addon " .. NS.VERSION .. ". No automatic internet rule updates.")
    NS.ShowToolWindow(preferences)
end

local function renderBags(refresh)
    if not bags then return end
    if refresh then bags.all,bags.issues=NS.ReadBags() end
    bags.rows={}
    local state=NS.AdviceState()
    for _,row in ipairs(bags.all or {}) do
        if (not bags.gearOnly:GetChecked() or row.equipLoc~="") and (not bags.unprotected:GetChecked() or not state.keepItems[row.itemID]) then bags.rows[#bags.rows+1]=row end
    end
    bags.index=math.max(1,math.min(bags.index or 1,#bags.rows))
    local row=bags.rows[bags.index]
    if row then
        bags.item:SetText(row.name .. " — item " .. (row.itemID or "unknown"))
        bags.text:SetText(NS.BagItemText(row,NS.CharacterSettings(),true))
        bags.pages:SetText("Item " .. bags.index .. "/" .. #bags.rows)
    else
        bags.item:SetText("No items match this filter.")
        bags.text:SetText(table.concat(bags.issues or {},"\n"))
        bags.pages:SetText("0 items")
    end
    bags.text:SetCursorPosition(0)
    bags.scroll:SetVerticalScroll(0)
    bags.status:SetText((#(bags.issues or {})>0 and "Some bag data is unavailable. " or "") .. "No items are sold, destroyed, equipped or moved.")
end

local function makeBags()
    local frame=NS.CreateToolWindow("ForeverContextBagsWindow","ForeverContext — Carried bags","Browse carried items, record keep preferences, or select two comparison candidates.",640)
    bags=frame
    frame.gearOnly=check(frame,"Equipment only",20,-78,false,function() frame.index=1; renderBags() end)
    frame.unprotected=check(frame,"Hide kept items / show alternatives",330,-78,false,function() frame.index=1; renderBags() end)
    frame.item=label(frame,"",20,-125,710)
    frame.text,frame.scroll=NS.ToolTextArea(frame,"ForeverContextBagText",25,-160,680,260,24000)
    label(frame,"Reason to keep",20,-448,130)
    frame.reason=edit(frame,"ForeverContextBagKeepReason",160,-442,555,240)
    frame.keep=button(frame,"Keep this item",20,-485,155,function()
        local row=frame.rows[frame.index]
        if not row then frame.status:SetText("Select an item first."); return end
        local id,message=NS.KeepItem(row.reference or row.itemID,frame.reason:GetText())
        if id then renderBags(); frame.status:SetText("All copies/variants of item " .. id .. " marked KEEP.") else frame.status:SetText(message) end
    end)
    local function candidate(slot)
        local row=frame.rows[frame.index]
        if not row then frame.status:SetText("Select an item first."); return end
        local reference,message=NS.SetCandidate(slot,row.reference or (row.itemID and tostring(row.itemID)))
        frame.status:SetText(reference and "Candidate " .. slot .. " selected. Browse another item or open Compare." or message)
    end
    frame.a=button(frame,"Use as A",185,-485,115,function() candidate("A") end)
    frame.b=button(frame,"Use as B",310,-485,115,function() candidate("B") end)
    frame.compare=button(frame,"Open Compare",555,-485,175,NS.OpenComparisonWindow)
    frame.status=label(frame,"",20,-527,710)
    frame.previous=button(frame,"Previous",20,-585,100,function() frame.index=math.max(1,frame.index-1); renderBags() end)
    frame.next=button(frame,"Next",130,-585,100,function() frame.index=frame.index+1; renderBags() end)
    frame.refresh=button(frame,"Refresh bags",240,-585,130,function() renderBags(true) end)
    frame.pages=label(frame,"",400,-592,300)
end

function NS.OpenBagWindow()
    if not NS.ToolsAllowed() then return end
    if not bags then makeBags() end
    bags.index=1
    renderBags(true)
    NS.ShowToolWindow(bags)
end

local function renderKeep()
    local ids=NS.SortedIDs(NS.AdviceState().keepItems)
    keep.page=math.max(1,math.min(keep.page or 1,math.max(1,math.ceil(#ids/6))))
    for i,row in ipairs(keep.rows) do
        local id=ids[(keep.page-1)*6+i]
        row.id=id
        if id then
            row.text:SetText(NS.ItemName(id) .. " [" .. id .. "]\n" .. NS.Clean(NS.AdviceState().keepItems[id].reason))
            row.text:Show(); row.remove:Show()
        else row.text:Hide(); row.remove:Hide() end
    end
    keep.pages:SetText(#ids .. "/100 protected IDs; page " .. keep.page .. "/" .. math.max(1,math.ceil(#ids/6)))
end

local function makeKeep()
    local frame=NS.CreateToolWindow("ForeverContextKeepWindow","ForeverContext — Items to keep","Protect every copy/variant of an item ID in AI advice. This does not lock items in the game.",620)
    keep=frame
    label(frame,"Item link / ID",20,-85,140)
    frame.item=edit(frame,"ForeverContextKeepItem",170,-80,420,2048)
    frame.drop=button(frame,"Drop item",610,-80,120,function() dropInto(frame.item,frame.status) end)
    frame.drop:SetScript("OnReceiveDrag",function() dropInto(frame.item,frame.status) end)
    label(frame,"Reason",20,-130,140)
    frame.reason=edit(frame,"ForeverContextKeepReason",170,-125,550,240)
    frame.save=button(frame,"Save keep preference",20,-170,190,function()
        local id,message=NS.KeepItem(frame.item:GetText(),frame.reason:GetText())
        if id then renderKeep(); frame.status:SetText("Item " .. id .. " protected across all its variants.") else frame.status:SetText(message) end
    end)
    frame.status=label(frame,"",20,-213,710)
    frame.rows={}
    for i=1,6 do
        local row={}
        row.text=label(frame,"",20,-255-(i-1)*44,570)
        row.text:SetHeight(40)
        row.remove=button(frame,"Remove",620,-250-(i-1)*44,110,function() if row.id then NS.RemoveKeepItem(row.id); renderKeep() end end)
        frame.rows[i]=row
    end
    frame.previous=button(frame,"Previous",20,-560,100,function() frame.page=math.max(1,frame.page-1); renderKeep() end)
    frame.next=button(frame,"Next",130,-560,100,function() frame.page=frame.page+1; renderKeep() end)
    frame.pages=label(frame,"",260,-568,450)
end

function NS.OpenKeepWindow()
    if not NS.ToolsAllowed() then return end
    if not keep then makeKeep() end
    renderKeep()
    NS.ShowToolWindow(keep)
end

local function renderSources()
    local filter=sources.item:GetText()
    local id=filter~="" and NS.ItemID(filter) or nil
    sources.records=NS.SourceRecords(id)
    sources.index=math.max(1,math.min(sources.index or 1,#sources.records))
    local selected=sources.records[sources.index]
    if selected then
        local r=selected.record
        sources.text:SetText("Item " .. r.itemID .. " — " .. NS.ItemName(r.itemID) .. "\n" .. NS.SourceStatus(r) .. "\n"
            .. r.kind .. " — " .. r.location .. "\nReference: " .. NS.Clean(r.reference) .. "\nRecorded: " .. r.at .. "; build " .. r.build)
    else sources.text:SetText("No source record for this item/filter. Unknown origins stay NOT CONFIRMED.\nAdd a dungeon/boss, quest, vendor or profession source with its reference.") end
    sources.text:SetCursorPosition(0)
    sources.pages:SetText("Record " .. (#sources.records>0 and sources.index or 0) .. "/" .. #sources.records)
end

local function makeSources()
    local frame=NS.CreateToolWindow("ForeverContextSourcesWindow","ForeverContext — Item sources","Record references for upgrades. Player confirmation and direct observations remain distinguishable.",660)
    sources=frame
    label(frame,"Item link / ID",20,-85,140)
    frame.item=edit(frame,"ForeverContextSourceItem",170,-80,420,2048)
    frame.drop=button(frame,"Drop item",610,-80,120,function() dropInto(frame.item,frame.status); renderSources() end)
    frame.drop:SetScript("OnReceiveDrag",function() dropInto(frame.item,frame.status); renderSources() end)
    frame.kindIndex=1
    label(frame,"Source type",20,-130,140)
    frame.kind=button(frame,NS.SourceKinds[1],170,-125,140,function()
        frame.kindIndex=frame.kindIndex%#NS.SourceKinds+1; frame.kind:SetText(NS.SourceKinds[frame.kindIndex])
    end)
    label(frame,"Place / boss / recipe",330,-130,200)
    frame.location=edit(frame,"ForeverContextSourceLocation",480,-125,240,160)
    label(frame,"Reference URL",20,-175,140)
    frame.reference=edit(frame,"ForeverContextSourceReference",170,-170,550,500)
    frame.confirmed=check(frame,"I checked this source in Forever on this client build",20,-210,false,function() end)
    frame.save=button(frame,"Save source",20,-255,150,function()
        local key,message=NS.SaveItemSource(frame.item:GetText(),NS.SourceKinds[frame.kindIndex],frame.location:GetText(),frame.reference:GetText(),frame.confirmed:GetChecked())
        if key then frame.confirmed:SetChecked(false); renderSources(); frame.status:SetText("Source saved with its provenance and client build.") else frame.status:SetText(message) end
    end)
    frame.observe=button(frame,"Observe current offers",180,-255,190,function()
        local total=NS.ObserveMerchantSources()+NS.ObserveQuestSources()
        renderSources(); frame.status:SetText(total .. " offers/rewards read. Open a merchant or quest-reward window first.")
    end)
    frame.filter=button(frame,"Filter / refresh",380,-255,150,function() frame.index=1; renderSources() end)
    frame.status=label(frame,"",20,-297,710)
    frame.text,frame.scroll=NS.ToolTextArea(frame,"ForeverContextSourceText",25,-345,680,165,4000)
    frame.previous=button(frame,"Previous",20,-550,100,function() frame.index=math.max(1,frame.index-1); renderSources() end)
    frame.next=button(frame,"Next",130,-550,100,function() frame.index=frame.index+1; renderSources() end)
    frame.load=button(frame,"Edit selected",240,-550,130,function()
        local selected=frame.records[frame.index]
        if not selected then return end
        local r=selected.record
        frame.item:SetText(tostring(r.itemID)); frame.location:SetText(r.location)
        frame.reference:SetText(r.reference:match("^https://") and r.reference or "")
        frame.confirmed:SetChecked(false)
        for i,kind in ipairs(NS.SourceKinds) do if kind==r.kind then frame.kindIndex=i; frame.kind:SetText(kind) end end
        frame.status:SetText("Review the source and explicitly check confirmation if you verified it on this build.")
    end)
    frame.remove=button(frame,"Remove selected",380,-550,150,function()
        local selected=frame.records[frame.index]
        if selected then NS.RemoveItemSource(selected.key); renderSources() end
    end)
    frame.export=button(frame,"Review sources with AI",540,-550,190,function() NS.OpenReport("sources") end)
    frame.pages=label(frame,"",20,-605,710)
end

function NS.OpenSourcesWindow()
    if not NS.ToolsAllowed() then return end
    if not sources then makeSources() end
    renderSources()
    NS.ShowToolWindow(sources)
end

local function selectProfile(index)
    local names=NS.TalentProfileNames()
    loadouts.index=math.max(1,math.min(index,#names))
    local name=names[loadouts.index]
    if name then
        NS.SelectTalentProfile(name)
        local profile=NS.AdviceState().talentProfiles[name]
        loadouts.name:SetText(profile.name); loadouts.activity:SetText(profile.activity)
        loadouts.text:SetText(NS.TalentProfileText(profile))
        loadouts.text:SetCursorPosition(0); loadouts.scroll:SetVerticalScroll(0)
        loadouts.status:SetText("Selected " .. name .. "; saved build " .. profile.build .. "; current build " .. NS.ClientStamp().build .. ".")
    else loadouts.status:SetText("No saved profiles. Capture your committed build or paste an FCLOADOUT/1 block.") end
    loadouts.pages:SetText("Profile " .. (#names>0 and loadouts.index or 0) .. "/" .. #names .. " (maximum 12)")
    loadouts.preview=nil
    loadouts.import:Disable()
end

local function makeLoadouts()
    local frame=NS.CreateToolWindow("ForeverContextLoadoutsWindow","ForeverContext — Activity talent profiles","Save profiles per dungeon/activity. Copy codes manually; no talents are applied by the addon.",740)
    loadouts=frame
    label(frame,"Profile name",20,-85,140)
    frame.name=edit(frame,"ForeverContextProfileName",170,-80,550,80)
    label(frame,"Dungeon / activity",20,-128,140)
    frame.activity=edit(frame,"ForeverContextProfileActivity",170,-123,550,120)
    frame.capture=button(frame,"Save current build",20,-170,170,function()
        local profile,message=NS.CaptureTalentProfile(frame.name:GetText(),frame.activity:GetText())
        if not profile then frame.status:SetText(message); return end
        local ok,errorMessage=NS.SaveTalentProfile(profile)
        if not ok then frame.status:SetText(errorMessage); return end
        local names=NS.TalentProfileNames()
        for i,name in ipairs(names) do if name==profile.name then selectProfile(i) end end
    end)
    frame.previewButton=button(frame,"Preview import",200,-170,150,function()
        local profile,message=NS.ParseTalentProfile(frame.text:GetText())
        frame.preview=profile
        if profile then frame.import:Enable(); frame.status:SetText("DRAFT: " .. profile.name .. " for " .. profile.class .. ", build " .. profile.build .. ". Click Import profile to save.")
        else frame.import:Disable(); frame.status:SetText(message) end
    end)
    frame.import=button(frame,"Import profile",360,-170,150,function()
        if not frame.preview then return end
        local name=frame.preview.name
        local ok,message=NS.SaveTalentProfile(frame.preview)
        if not ok then frame.status:SetText(message); return end
        for i,candidate in ipairs(NS.TalentProfileNames()) do if candidate==name then selectProfile(i) end end
    end)
    frame.import:Disable()
    frame.compare=button(frame,"Compare with AI",555,-170,175,function()
        if frame.preview then frame.status:SetText("Import this preview to select it before comparing. The saved profile has not been replaced."); return end
        if not NS.AdviceState().selectedTalentProfile then frame.status:SetText("Select a saved profile with Previous / Next, or save/import one first."); return end
        if not NS.ModuleEnabled(NS.CharacterSettings(),"talents") or not NS.ModuleEnabled(NS.CharacterSettings(),"loadouts") then
            frame.status:SetText("Enable Current talents and Selected talent profile in Export options to compare."); return
        end
        NS.OpenReport("talents")
    end)
    frame.status=label(frame,"",20,-215,710)
    frame.status:SetHeight(40)
    frame.text,frame.scroll=NS.ToolTextArea(frame,"ForeverContextProfileText",25,-270,680,285,40000)
    frame.text:SetScript("OnTextChanged",function(_,user)
        if user then frame.preview=nil; frame.import:Disable() end
    end)
    frame.copy=button(frame,"Copy profile",20,-585,140,function()
        local state=NS.AdviceState()
        local profile=state.talentProfiles[state.selectedTalentProfile or ""]
        if not profile then frame.status:SetText("Select a saved profile first."); return end
        frame.preview=nil; frame.import:Disable()
        frame.text:SetText(NS.TalentProfileText(profile)); frame.text:SetFocus(); frame.text:HighlightText(0,-1)
        frame.status:SetText("Profile selected. Press Ctrl+C to share or back up. This is an addon profile, not the game's import code.")
    end)
    frame.native=button(frame,"Copy game code",170,-585,155,function()
        local state=NS.AdviceState()
        local profile=state.talentProfiles[state.selectedTalentProfile or ""]
        if not profile or not profile.native then frame.status:SetText("No game code available. Capture a current build after opening Talents."); return end
        frame.preview=nil; frame.import:Disable()
        frame.text:SetText(profile.native); frame.text:SetFocus(); frame.text:HighlightText(0,-1)
        frame.status:SetText("Press Ctrl+C. Check class/build compatibility and confirm manually in the game's talent UI.")
    end)
    frame.remove=button(frame,"Remove selected",335,-585,155,function()
        local name=NS.AdviceState().selectedTalentProfile
        if name then NS.RemoveTalentProfile(name); selectProfile(1) end
    end)
    frame.previous=button(frame,"Previous",20,-640,100,function() selectProfile((frame.index or 1)-1) end)
    frame.next=button(frame,"Next",130,-640,100,function() selectProfile((frame.index or 1)+1) end)
    frame.none=button(frame,"Clear selection",240,-640,140,function()
        NS.SelectTalentProfile(nil); frame.status:SetText("No activity profile will be included in reports until you select one.")
    end)
    frame.pages=label(frame,"",20,-690,710)
end

function NS.OpenLoadoutsWindow()
    if not NS.ToolsAllowed() then return end
    if not loadouts then makeLoadouts() end
    local names=NS.TalentProfileNames()
    local selected=NS.AdviceState().selectedTalentProfile
    local index=1
    for i,name in ipairs(names) do if name==selected then index=i end end
    -- Merely opening the editor must not select a profile that was explicitly cleared.
    if selected then selectProfile(index)
    else loadouts.status:SetText("Save your current build or paste a profile, preview it, then import. Use Previous/Next to select a saved profile.") end
    NS.ShowToolWindow(loadouts)
end

local events=CreateFrame("Frame")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:SetScript("OnEvent",function()
    if bags and bags:IsShown() then bags:SetScript("OnUpdate",function(self) self:SetScript("OnUpdate",nil); renderBags(true) end) end
end)
