local _, NS = ...
local planWindow, comparisonWindow
local PAGE_SIZE = 6
local allowed, showPopup = NS.ToolsAllowed, NS.ShowToolWindow
local label, button, popup = NS.ToolLabel, NS.ToolButton, NS.CreateToolWindow

local function renderPlan()
    if not planWindow then return end
    local state = NS.CharacterState()
    local plan = planWindow.preview or state.plan
    local tasks = plan and plan.tasks or {}
    local snapshot = NS.CaptureSnapshot(tasks)
    local completed, unknown = 0, 0
    for _, task in ipairs(tasks) do
        local status = NS.EvaluateTask(task, snapshot)
        if status == "DONE" then completed = completed + 1 elseif status == "UNKNOWN" then unknown = unknown + 1 end
    end
    local pages = math.max(1, math.ceil(#tasks / PAGE_SIZE))
    planWindow.page = math.min(planWindow.page or 1, pages)
    for index, row in ipairs(planWindow.rows) do
        local taskIndex = (planWindow.page - 1) * PAGE_SIZE + index
        local task = tasks[taskIndex]
        if task then
            local status, detail = NS.EvaluateTask(task, snapshot)
            row.index = taskIndex
            row.check:SetChecked(status == "DONE")
            if task.kind == "MANUAL" and not planWindow.preview then row.check:Enable() else row.check:Disable() end
            local color = status == "DONE" and "|cff65d993" or status == "UNKNOWN" and "|cffaaaaaa" or "|cffffd46a"
            NS.BindText(row.text,function() return color .. "[" .. NS.L(status) .. "]|r " .. NS.Clean(task.label) .. "\n" .. NS.L(detail) end)
            row.check:Show(); row.text:Show()
        else
            row.check:Hide(); row.text:Hide()
        end
    end
    if planWindow.preview then
        NS.SetText(planWindow.status,"DRAFT: {1} tasks to check. Click Use this plan only after reviewing them.",#tasks)
        planWindow.accept:Enable()
    elseif plan then
        NS.SetText(planWindow.status,"ACTIVE: {1}/{2} tasks done; {3} unknown. Only manual tasks need a checkbox.",completed,#tasks,unknown)
        planWindow.accept:Disable()
    else
        NS.SetText(planWindow.status,"No plan yet. Paste an AI reply above, or click Try an example.")
        planWindow.accept:Disable()
    end
    NS.SetText(planWindow.pages,"Page {1}/{2}",planWindow.page,pages)
    if #tasks>PAGE_SIZE then planWindow.previous:Show(); planWindow.next:Show(); planWindow.pages:Show()
    else planWindow.previous:Hide(); planWindow.next:Hide(); planWindow.pages:Hide() end
    if #tasks>0 then planWindow.refresh:Show() else planWindow.refresh:Hide() end
    if state.plan and not planWindow.preview then planWindow.clear:Show(); planWindow.review:Show()
    else planWindow.clear:Hide(); planWindow.review:Hide() end
    local reference=state.plan and (state.plan.reviewedBuild or (state.plan.baseline and state.plan.baseline.build))
    if state.plan and not planWindow.preview and reference~=NS.ClientStamp().build then planWindow.reviewBuild:Show()
    else planWindow.reviewBuild:Hide() end
    NS.ResizeToolWindow(planWindow,#tasks>0 and 730 or 380)
end

local function makePlanWindow()
    local frame = popup("ForeverContextPlanWindow", "ForeverContext — Use an AI plan", "Ask your AI for a plan using your report. Paste its reply, check the tasks, then choose whether to use them.", 730)
    planWindow = frame
    frame.instructions=label(frame, "1. Paste the AI reply here (or just its plan block).", 20, -78)
    frame.inputPanel=CreateFrame("Frame",nil,frame,"BackdropTemplate")
    frame.inputPanel:SetPoint("TOPLEFT",18,-98)
    frame.inputPanel:SetSize(720,144)
    frame.inputPanel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
    frame.inputPanel:SetBackdropColor(0.015,0.02,0.03,1)
    frame.scroll = CreateFrame("ScrollFrame", "ForeverContextPlanScroll", frame, "UIPanelScrollFrameTemplate")
    frame.scroll:SetPoint("TOPLEFT", 20, -100)
    frame.scroll:SetSize(690, 140)
    frame.input = CreateFrame("EditBox", "ForeverContextPlanInput", frame.scroll, "InputBoxTemplate")
    frame.input:SetPoint("TOPLEFT",0,0)
    frame.input:SetMultiLine(true)
    frame.input:SetAutoFocus(false)
    frame.input:SetFontObject(ChatFontNormal)
    frame.input:SetWidth(675)
    frame.input:SetHeight(140)
    frame.input:SetMaxLetters(24000)
    frame.scroll:SetScrollChild(frame.input)
    frame.input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    frame.input:SetScript("OnCursorChanged", function(_, _, y, _, height)
        local top, cursor, visible = frame.scroll:GetVerticalScroll(), -y, frame.scroll:GetHeight()
        if cursor < top then frame.scroll:SetVerticalScroll(math.max(0, cursor))
        elseif cursor + height > top + visible then frame.scroll:SetVerticalScroll(math.max(0, cursor + height - visible)) end
    end)
    frame.input:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            NS.CharacterState().draftText = NS.GetPlainText(self)
            local hadPreview = frame.preview ~= nil
            frame.preview = nil
            -- Only discard rendered preview rows once. Typing must not query
            -- every equipment slot and talent node on each keystroke.
            if hadPreview then renderPlan() end
            frame.accept:Disable()
            NS.SetText(frame.status,"Text changed. Click 2. Check the plan again. Your saved plan has not changed.")
        end
    end)
    frame.previewButton = button(frame, "2. Check the plan", 20, -250, 190, function()
        frame.input:ClearFocus()
        local plan, errorMessage = NS.ParsePlanReply(NS.GetPlainText(frame.input))
        frame.preview, frame.page = plan, 1
        renderPlan()
        if not plan then NS.SetText(frame.status,errorMessage) end
    end)
    frame.accept = button(frame, "3. Use this plan", 220, -250, 190, function()
        if not allowed() then return end
        local ok, message = NS.AcceptPlan(frame.preview)
        if not ok then NS.SetText(frame.status,message); return end
        frame.preview = nil
        renderPlan()
    end)
    frame.example = button(frame, "Try an example", 420, -250, 210, function()
        local level = NS.ReadNumber(NS.SafeCall(UnitLevel, "player")) or 1
        local text = "FCPLAN/1\nTITLE|My next session\nLEVEL|" .. (level + 1) .. "|Gain one level\nMANUAL|Review my next talent point"
        NS.SetPlainText(frame.input,text)
        NS.CharacterState().draftText = text
        frame.preview = nil
        renderPlan()
    end)
    frame.clear = button(frame, "Remove this plan", 20, -650, 220, function()
        if not allowed() then return end
        NS.ClearPlan()
        frame.preview = nil
        renderPlan()
    end)
    frame.status = label(frame, "", 20, -289, 710)
    frame.rows = {}
    for index = 1, PAGE_SIZE do
        local row = {}
        row.check = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        row.check:SetPoint("TOPLEFT", 20, -320 - (index-1)*41)
        row.check.Text:SetText("")
        row.text = label(frame, "", 58, -323 - (index-1)*41, 665)
        row.check:SetScript("OnClick", function(self)
            if not frame.preview then NS.MarkManualTask(row.index, self:GetChecked() == true); renderPlan() end
        end)
        frame.rows[index] = row
    end
    frame.previous = button(frame, "Previous", 20, -600, 100, function() frame.page = math.max(1, frame.page-1); renderPlan() end)
    frame.next = button(frame, "Next", 130, -600, 100, function() frame.page = frame.page+1; renderPlan() end)
    frame.refresh = button(frame, "Refresh", 240, -600, 110, renderPlan)
    frame.review = button(frame, "Review with AI", 560, -600, 175, function() NS.OpenReport("review") end)
    frame.reviewBuild = button(frame, "Mark build reviewed", 255, -650, 260, function()
        if not allowed() then return end
        local ok, message = NS.ReviewPlanForBuild()
        NS.SetText(frame.status,ok and "Plan marked reviewed for this client build. Original reference preserved." or message)
    end)
    frame.help=label(frame,"Automatic tasks update as you play. Tick manual tasks yourself. No talents or items are changed by a plan.",20,0,710)
    frame.help:ClearAllPoints()
    frame.help:SetPoint("BOTTOMLEFT",20,22)
    frame.pages = label(frame, "", 370, -609, 165)
    frame:HookScript("OnHide", function(self) self:SetScript("OnUpdate", nil); self.input:ClearFocus() end)
end

function NS.OpenPlanWindow()
    if not allowed() then return end
    if not planWindow then makePlanWindow() end
    planWindow.preview, planWindow.page = nil, 1
    NS.SetPlainText(planWindow.input,NS.CharacterState().draftText or "")
    showPopup(planWindow)
    renderPlan()
end

local function showCandidateName(widget, reference)
    if not reference then NS.SetText(widget,"No item selected."); return end
    local name = C_Item and NS.SafeCall(C_Item.GetItemInfo, reference)
    if type(name)=="string" then NS.SetText(widget,"{1}",NS.Clean(name))
    else NS.SetText(widget,"Item data loads when generating the comparison report.") end
end

local function refreshComparison()
    local frame=comparisonWindow
    if not frame or not frame.compare then return end
    local a=NS.NormalizeItem(frame.inputs.A:GetText())
    local b=NS.NormalizeItem(frame.inputs.B:GetText())
    if a and b then
        frame.compare:Enable()
        NS.SetText(frame.guide,"Ready. Prepare the comparison, then copy the report to your AI.")
    else
        frame.compare:Disable()
        NS.SetText(frame.guide,not a and "Start with the first item. Open your bags and drag it onto 1. First item." or "Now add the second item. Drag it onto 2. Second item.")
    end
end

local function makeComparisonWindow()
    local frame = popup("ForeverContextComparisonWindow", "ForeverContext — Compare two items", "Which item should you use? Add two items and prepare a report to ask your AI.", 470)
    comparisonWindow = frame
    frame.instructions=label(frame,"Open your bags. Drag an item onto each numbered button, or paste an item link in each field. Nothing is equipped.",20,-85,710)
    frame.inputs, frame.names = {}, {}
    for index, key in ipairs({"A", "B"}) do
        local slot = key
        local y = -145 - (index-1)*100
        local input = CreateFrame("EditBox", "ForeverContextCandidate" .. slot, frame, "InputBoxTemplate")
        input:SetPoint("TOPLEFT", 170, y)
        input:SetSize(540, 26)
        input:SetAutoFocus(false)
        input:SetMaxLetters(2048)
        input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        frame.inputs[slot] = input
        frame.names[slot] = label(frame, "", 170, y-35, 540)
        local function save(value)
            local reference, message = NS.SetCandidate(slot, value)
            if reference then
                input:SetText(reference)
                input:ClearFocus()
                showCandidateName(frame.names[slot],reference)
                NS.SetText(frame.status,"")
            else NS.SetText(frame.status,message) end
            return reference
        end
        local function receive()
            if not allowed() then return end
            local reference, message = NS.CursorItemReference()
            if not reference then NS.SetText(frame.status,message); input:SetFocus(); return end
            if save(reference) and type(ClearCursor) == "function" then ClearCursor() end
        end
        input:SetScript("OnEnterPressed", function(self) save(self:GetText()) end)
        input:SetScript("OnReceiveDrag", receive)
        input:SetScript("OnTextChanged",function(self)
            local reference,message=NS.NormalizeItem(self:GetText())
            if not reference and self:GetText()~="" then NS.SetText(frame.names[slot],message)
            else showCandidateName(frame.names[slot],reference) end
            if frame.status then NS.SetText(frame.status,"") end
            refreshComparison()
        end)
        local drop = button(frame, index==1 and "1. First item" or "2. Second item", 20, y, 140, receive)
        drop:SetScript("OnReceiveDrag", receive)
        frame["drop" .. slot] = drop
    end
    frame.guide=label(frame,"",20,-325,710)
    frame.status = label(frame, "", 20, -365, 710)
    frame.compare = button(frame, "3. Prepare comparison", 20, -415, 270, function()
        if not allowed() then return end
        local a, messageA = NS.NormalizeItem(frame.inputs.A:GetText())
        local b, messageB = NS.NormalizeItem(frame.inputs.B:GetText())
        if not a or not b then
            NS.BindText(frame.status,function() return NS.L("Add both candidates. {1}",NS.L(messageA or messageB or "")) end)
            return
        end
        NS.SetCandidate("A", a); NS.SetCandidate("B", b)
        NS.OpenReport("compare")
    end)
    frame.clear = button(frame, "Start again", 305, -415, 200, function()
        local state = NS.CharacterState()
        state.candidates = {}
        NS.TouchAdvice()
        for _, key in ipairs({"A", "B"}) do frame.inputs[key]:SetText(""); NS.SetText(frame.names[key],"") end
        NS.SetText(frame.status,"Candidates cleared.")
    end)
    frame:HookScript("OnHide", function(self) self.inputs.A:ClearFocus(); self.inputs.B:ClearFocus() end)
end

function NS.OpenComparisonWindow()
    if not allowed() then return end
    if not comparisonWindow then makeComparisonWindow() end
    local candidates = NS.CharacterState().candidates
    for _, key in ipairs({"A", "B"}) do
        comparisonWindow.inputs[key]:SetText(candidates[key] or "")
        showCandidateName(comparisonWindow.names[key],candidates[key])
    end
    NS.SetText(comparisonWindow.status,"")
    refreshComparison()
    showPopup(comparisonWindow)
end

local events = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_REGEN_DISABLED", "SKILL_LINES_CHANGED", "PLAYER_LEVEL_UP", "PLAYER_EQUIPMENT_CHANGED", "PLAYER_MONEY", "TRAIT_CONFIG_UPDATED"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        NS.CloseAuxiliaryWindows()
    elseif planWindow and planWindow:IsShown() and not planWindow.preview then
        planWindow:SetScript("OnUpdate", function(self) self:SetScript("OnUpdate", nil); renderPlan() end)
    end
end)
