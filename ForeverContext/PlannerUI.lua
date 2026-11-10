local _, NS = ...
local planWindow, comparisonWindow
local PAGE_SIZE = 6

local function allowed()
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("ForeverContext: leave combat to use the planner or comparison.") end
        return false
    end
    return true
end

local function label(parent, text, x, y, width)
    local font = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    font:SetPoint("TOPLEFT", x, y)
    font:SetWidth(width or 700)
    font:SetJustifyH("LEFT")
    font:SetText(text)
    return font
end

local function button(parent, text, x, y, width, action)
    local widget = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    widget:SetPoint("TOPLEFT", x, y)
    widget:SetSize(width, 26)
    widget:SetText(text)
    widget:SetScript("OnClick", action)
    return widget
end

local function popup(name, title, subtitle, height)
    local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(760, height)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=16,
        insets={left=4,right=4,top=4,bottom=4}})
    frame:SetBackdropColor(0.035, 0.05, 0.075, 0.99)
    frame:SetBackdropBorderColor(0.3, 0.65, 0.8, 1)
    frame.title = label(frame, "|cffffd46a" .. title .. "|r", 20, -20)
    frame.subtitle = label(frame, subtitle, 20, -45)
    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", -5, -5)
    frame:SetScript("OnShow", function(self)
        self:SetScale(math.min(1, (UIParent:GetWidth()-40)/760, (UIParent:GetHeight()-40)/height))
    end)
    UISpecialFrames = UISpecialFrames or {}
    table.insert(UISpecialFrames, name)
    return frame
end

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
            row.text:SetText(color .. "[" .. status .. "]|r " .. NS.Clean(task.label) .. "\n" .. detail)
            row.check:Show(); row.text:Show()
        else
            row.check:Hide(); row.text:Hide()
        end
    end
    if planWindow.preview then
        planWindow.status:SetText("DRAFT: " .. plan.title .. " — " .. #tasks .. " tasks. Click Accept plan to replace the active plan.")
        planWindow.accept:Enable()
    elseif plan then
        planWindow.status:SetText("ACTIVE: " .. plan.title .. " — " .. completed .. "/" .. #tasks .. " done; " .. unknown .. " unknown. Checks reflect current state.")
        planWindow.accept:Disable()
    else
        planWindow.status:SetText("No active plan. Paste an FCPLAN/1 block, preview it, and accept the tasks you want to follow.")
        planWindow.accept:Disable()
    end
    planWindow.pages:SetText("Page " .. planWindow.page .. "/" .. pages)
end

local function makePlanWindow()
    local frame = popup("ForeverContextPlanWindow", "ForeverContext — Progress plan", "Preview an AI plan before accepting it. Only manual tasks have editable checkboxes.", 650)
    planWindow = frame
    label(frame, "Paste the plan block from your AI reply. Example shows a valid starting format.", 20, -78)
    frame.scroll = CreateFrame("ScrollFrame", "ForeverContextPlanScroll", frame, "UIPanelScrollFrameTemplate")
    frame.scroll:SetPoint("TOPLEFT", 20, -100)
    frame.scroll:SetSize(690, 140)
    frame.input = CreateFrame("EditBox", "ForeverContextPlanInput", frame.scroll, "InputBoxTemplate")
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
            NS.CharacterState().draftText = self:GetText()
            frame.preview = nil
            renderPlan()
        end
    end)
    frame.previewButton = button(frame, "Preview plan", 20, -250, 135, function()
        frame.input:ClearFocus()
        local plan, errorMessage = NS.ParsePlan(frame.input:GetText())
        frame.preview, frame.page = plan, 1
        renderPlan()
        if not plan then frame.status:SetText(errorMessage) end
    end)
    frame.accept = button(frame, "Accept plan", 165, -250, 135, function()
        if not allowed() then return end
        local ok, message = NS.AcceptPlan(frame.preview)
        if not ok then frame.status:SetText(message); return end
        frame.preview = nil
        renderPlan()
    end)
    frame.example = button(frame, "Example", 310, -250, 135, function()
        local level = NS.ReadNumber(NS.SafeCall(UnitLevel, "player")) or 1
        local text = "FCPLAN/1\nTITLE|My next session\nLEVEL|" .. (level + 1) .. "|Gain one level\nMANUAL|Review my next talent point"
        frame.input:SetText(text)
        NS.CharacterState().draftText = text
        frame.preview = nil
        renderPlan()
    end)
    frame.clear = button(frame, "Archive / clear", 455, -250, 135, function()
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
    frame.review = button(frame, "Review with AI", 560, -600, 175, function() frame:Hide(); NS.OpenReport("review") end)
    frame.pages = label(frame, "", 370, -609, 165)
    frame:SetScript("OnHide", function(self) self:SetScript("OnUpdate", nil); self.input:ClearFocus() end)
end

function NS.OpenPlanWindow()
    if not allowed() then return end
    if not planWindow then makePlanWindow() end
    planWindow.preview, planWindow.page = nil, 1
    planWindow.input:SetText(NS.CharacterState().draftText or "")
    planWindow:Show()
    renderPlan()
end

local function candidateName(reference)
    local name = C_Item and NS.SafeCall(C_Item.GetItemInfo, reference)
    return NS.Clean(name, "Item data loads when generating the comparison report.")
end

local function makeComparisonWindow()
    local frame = popup("ForeverContextComparisonWindow", "ForeverContext — Compare items", "Drop two items or paste their full game links. The report includes your current build and equipment.", 380)
    comparisonWindow = frame
    frame.inputs, frame.names = {}, {}
    for index, key in ipairs({"A", "B"}) do
        local slot = key
        local y = -90 - (index-1)*100
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
                frame.names[slot]:SetText(candidateName(reference))
                frame.status:SetText("Candidate " .. slot .. " saved. Add both items, then click Compare with AI.")
            else frame.status:SetText(message) end
            return reference
        end
        local function receive()
            if not allowed() then return end
            local reference, message = NS.CursorItemReference()
            if not reference then frame.status:SetText(message); input:SetFocus(); return end
            if save(reference) and type(ClearCursor) == "function" then ClearCursor() end
        end
        input:SetScript("OnEnterPressed", function(self) save(self:GetText()) end)
        input:SetScript("OnReceiveDrag", receive)
        local drop = button(frame, "Drop item " .. slot, 20, y, 130, receive)
        drop:SetScript("OnReceiveDrag", receive)
        frame["drop" .. slot] = drop
    end
    frame.status = label(frame, "", 20, -285, 710)
    frame.compare = button(frame, "Compare with AI", 20, -325, 175, function()
        if not allowed() then return end
        local a, messageA = NS.NormalizeItem(frame.inputs.A:GetText())
        local b, messageB = NS.NormalizeItem(frame.inputs.B:GetText())
        if not a or not b then frame.status:SetText("Add both candidates. " .. (messageA or messageB or "")); return end
        NS.SetCandidate("A", a); NS.SetCandidate("B", b)
        frame:Hide()
        NS.OpenReport("compare")
    end)
    frame.clear = button(frame, "Clear candidates", 210, -325, 150, function()
        local state = NS.CharacterState()
        state.candidates = {}
        for _, key in ipairs({"A", "B"}) do frame.inputs[key]:SetText(""); frame.names[key]:SetText("") end
        frame.status:SetText("Candidates cleared.")
    end)
    frame:SetScript("OnHide", function(self) self.inputs.A:ClearFocus(); self.inputs.B:ClearFocus() end)
end

function NS.OpenComparisonWindow()
    if not allowed() then return end
    if not comparisonWindow then makeComparisonWindow() end
    local candidates = NS.CharacterState().candidates
    for _, key in ipairs({"A", "B"}) do
        comparisonWindow.inputs[key]:SetText(candidates[key] or "")
        comparisonWindow.names[key]:SetText(candidates[key] and candidateName(candidates[key]) or "No item selected.")
    end
    comparisonWindow.status:SetText("Drop an item on each button, or paste a game link and press Enter. Full links preserve item variants.")
    comparisonWindow:Show()
end

local events = CreateFrame("Frame")
for _, event in ipairs({"PLAYER_REGEN_DISABLED", "SKILL_LINES_CHANGED", "PLAYER_LEVEL_UP", "PLAYER_EQUIPMENT_CHANGED", "PLAYER_MONEY", "TRAIT_CONFIG_UPDATED"}) do events:RegisterEvent(event) end
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        if planWindow then planWindow:Hide() end
        if comparisonWindow then comparisonWindow:Hide() end
    elseif planWindow and planWindow:IsShown() and not planWindow.preview then
        planWindow:SetScript("OnUpdate", function(self) self:SetScript("OnUpdate", nil); renderPlan() end)
    end
end)
