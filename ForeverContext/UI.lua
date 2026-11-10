local _, NS = ...
local window, elapsed, tries, lastPending, lastWarnings
local MAX_TRIES, RETRY_SECONDS = 8, 0.5

local function say(text)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff65d9ffForeverContext:|r " .. text) end
end

local function inCombat()
    return type(InCombatLockdown) == "function" and InCombatLockdown()
end

local function settings()
    return NS.CharacterSettings()
end

local function saveOptions()
    local db = settings()
    db.goal = window.goal:GetText()
    db.includeName = window.nameCheck:GetChecked() and true or false
    db.extended = window.extraCheck:GetChecked() and true or false
end

local function planChanged()
    return window.progressVersion ~= NS.ProgressVersion()
end

local function showStaleReportStatus()
    window.text:ClearFocus()
    window.select:Disable()
    window.status:SetText("Plan changed. Click Generate / refresh before copying updated progress.")
end

local function selectReport()
    if not window or not window.report or window.report == "" then return end
    if planChanged() then showStaleReportStatus(); return end
    window.text:SetFocus()
    window.text:HighlightText(0, -1)
    window.scroll:SetVerticalScroll(0)
    window.status:SetText("All selected. Press Ctrl+C, then paste into your AI with Ctrl+V.")
end

local function finish()
    window.loading = false
    window:SetScript("OnUpdate", nil)
    window.generate:Enable()
    window.select:Enable()
    NS.CommitExport(window.snapshot)
    if lastPending and lastPending > 0 then
        window.status:SetText("Report ready with pending data. Check the warnings and generate again.")
    elseif lastWarnings and lastWarnings > 0 then
        window.status:SetText("Report ready with warnings. Click Select all, then Ctrl+C.")
    else
        selectReport()
    end
end

local function collect()
    if inCombat() then
        window.loading = false
        window.status:SetText("Leave combat, then click Generate.")
        window:SetScript("OnUpdate", nil)
        window.generate:Enable()
        window.select:Enable()
        return false
    end
    saveOptions()
    local db = settings()
    local report, pending, warnings, snapshot = NS.BuildExport(db)
    window.progressVersion = NS.ProgressVersion()
    window.snapshot = snapshot
    window.report = report
    window.text:SetText(report)
    window.text:SetCursorPosition(0)
    window.scroll:SetVerticalScroll(0)
    lastPending, lastWarnings = pending, warnings
    window.counter:SetText(string.format("%d bytes of text", #report))
    return true
end

local function generate()
    if inCombat() then say("Leave combat to generate the report."); return end
    window.goal:ClearFocus()
    window.text:ClearFocus()
    window.generate:Disable()
    window.select:Disable()
    window.loading = true
    tries, elapsed = 1, 0
    if not collect() then return end
    if lastPending == 0 then finish(); return end
    window.status:SetText("Loading item and talent data…")
    window:SetScript("OnUpdate", function(self, delta)
        elapsed = elapsed + delta
        if elapsed < RETRY_SECONDS then return end
        elapsed = 0
        tries = tries + 1
        if not collect() then return end
        if lastPending == 0 or tries >= MAX_TRIES then finish() end
    end)
end

local function button(parent, label, width, point, relative, relativePoint, x, y, click)
    local widget = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    widget:SetSize(width, 26)
    widget:SetPoint(point, relative, relativePoint, x, y)
    widget:SetText(label)
    widget:SetScript("OnClick", click)
    return widget
end

local function createWindow()
    local db = settings()
    local frame = CreateFrame("Frame", "ForeverContextWindow", UIParent, "BackdropTemplate")
    window = frame
    frame:Hide()
    frame:SetSize(820, 720)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.035, 0.05, 0.075, 0.98)
    frame:SetBackdropBorderColor(0.3, 0.65, 0.8, 1)
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 20, -17)
    frame.title:SetText("ForeverContext |cff65d9ff— WoW Forever|r")
    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.subtitle:SetPoint("TOPLEFT", 20, -43)
    frame.subtitle:SetText("Generate the report, select the text, and press Ctrl+C to copy it to your AI.")
    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", -5, -5)

    frame.goalLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.goalLabel:SetPoint("TOPLEFT", 20, -74)
    frame.goalLabel:SetText("Your goal (optional):")
    frame.goal = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    frame.goal:SetSize(610, 24)
    frame.goal:SetPoint("TOPLEFT", 175, -68)
    frame.goal:SetAutoFocus(false)
    frame.goal:SetMaxLetters(500)
    frame.goal:SetText(type(db.goal) == "string" and db.goal or "")
    frame.goal:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    frame.goal:SetScript("OnEnterPressed", generate)
    frame.goal:SetScript("OnEditFocusLost", function(self) settings().goal = self:GetText() end)

    frame.nameCheck = CreateFrame("CheckButton", "ForeverContextNameCheck", frame, "UICheckButtonTemplate")
    frame.nameCheck:SetPoint("TOPLEFT", 16, -100)
    frame.nameCheck:SetChecked(db.includeName and true or false)
    frame.nameCheck.Text:SetText("Include character name")
    frame.nameCheck:SetScript("OnClick", function(self) settings().includeName = self:GetChecked() and true or false end)
    frame.extraCheck = CreateFrame("CheckButton", "ForeverContextExtraCheck", frame, "UICheckButtonTemplate")
    frame.extraCheck:SetPoint("TOPLEFT", 310, -100)
    frame.extraCheck:SetChecked(db.extended)
    frame.extraCheck.Text:SetText("Include extra details for this question")
    frame.extraCheck:SetScript("OnClick", function(self) settings().extended = self:GetChecked() and true or false end)

    frame.panel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.panel:SetPoint("TOPLEFT", 18, -181)
    frame.panel:SetPoint("BOTTOMRIGHT", -18, 91)
    frame.panel:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    frame.panel:SetBackdropColor(0.015, 0.02, 0.03, 1)
    -- Keep client frame, template, and method identifiers unchanged when translating labels.
    frame.scroll = CreateFrame("ScrollFrame", "ForeverContextScroll", frame, "UIPanelScrollFrameTemplate")
    frame.scroll:SetPoint("TOPLEFT", frame.panel, "TOPLEFT", 10, -10)
    frame.scroll:SetPoint("BOTTOMRIGHT", frame.panel, "BOTTOMRIGHT", -30, 10)
    frame.text = CreateFrame("EditBox", "ForeverContextExportText", frame.scroll)
    frame.text:SetMultiLine(true)
    frame.text:SetAutoFocus(false)
    frame.text:SetFontObject(ChatFontNormal)
    frame.text:SetWidth(730)
    frame.text:SetHeight(400)
    frame.text:SetMaxLetters(0)
    frame.text:SetTextInsets(0, 0, 0, 0)
    frame.scroll:SetScrollChild(frame.text)
    frame.text:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.text:SetScript("OnTextChanged", function(self, userInput)
        if userInput and frame.report and self:GetText() ~= frame.report then
            self:SetText(frame.report)
            self:SetCursorPosition(0)
        end
    end)
    frame.text:SetScript("OnCursorChanged", function(_, _, y, _, height)
        local top = frame.scroll:GetVerticalScroll()
        local cursor = -y
        local visible = frame.scroll:GetHeight()
        if cursor < top then frame.scroll:SetVerticalScroll(math.max(0, cursor))
        elseif cursor + height > top + visible then frame.scroll:SetVerticalScroll(math.max(0, cursor + height - visible)) end
    end)
    frame.generate = button(frame, "Generate / refresh", 165, "BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 51, generate)
    frame.select = button(frame, "Select all", 150, "LEFT", frame.generate, "RIGHT", 12, 0, selectReport)
    frame.plan = button(frame, "Progress plan", 135, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 51, function() NS.OpenPlanWindow() end)
    frame.compare = button(frame, "Compare items", 135, "RIGHT", frame.plan, "LEFT", -10, 0, function() NS.OpenComparisonWindow() end)
    frame.modes = {}
    for index, key in ipairs({"overview", "talents", "gear", "session", "review"}) do
        local modeKey = key
        frame.modes[key] = button(frame, NS.ModeLabels[key], 145, "TOPLEFT", frame, "TOPLEFT", 20 + (index - 1) * 155, -142, function()
            NS.OpenReport(modeKey)
        end)
    end
    frame.counter = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.counter:SetPoint("BOTTOMRIGHT", -25, 24)
    frame.counter:SetText("")
    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.status:SetPoint("BOTTOMLEFT", 22, 24)
    frame.status:SetWidth(590)
    frame.status:SetJustifyH("LEFT")
    frame.status:SetText("")
    frame:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
        if self.loading then
            self.loading = false
            self.generate:Enable()
            self.select:Enable()
            self.status:SetText("Loading paused. Click Generate / refresh to finish loading missing data.")
        end
        self.goal:ClearFocus()
        self.text:ClearFocus()
    end)
    frame:SetScript("OnShow", function(self)
        local scale = math.min(1, (UIParent:GetWidth() - 40) / 820, (UIParent:GetHeight() - 40) / 720)
        self:SetScale(math.max(0.4, scale))
    end)
    UISpecialFrames = UISpecialFrames or {}
    table.insert(UISpecialFrames, "ForeverContextWindow")
end

local function open()
    if inCombat() then say("Leave combat to export your character."); return end
    if NS.CloseAuxiliaryWindows then NS.CloseAuxiliaryWindows() end
    if not window then createWindow() end
    local db = settings()
    window.goal:SetText(type(db.goal) == "string" and db.goal or "")
    window.nameCheck:SetChecked(db.includeName == true)
    window.extraCheck:SetChecked(db.extended ~= false)
    for key, widget in pairs(window.modes) do
        widget:SetText((db.mode == key or not db.mode and key == "overview") and "|cffffd46a" .. NS.ModeLabels[key] .. "|r" or NS.ModeLabels[key])
    end
    window:Show()
    generate()
end

function NS.OpenReport(mode)
    if window and window:IsShown() then
        saveOptions()
    end
    if mode and NS.ModeLabels[mode] then settings().mode = mode end
    open()
end

-- Auxiliary windows temporarily replace the report. Returning must not generate
-- a new snapshot or let an item-cache retry steal focus from the active editor.
function NS.SuspendReportWindow()
    if not window or not window:IsShown() then return false end
    saveOptions()
    window:Hide()
    return true
end

function NS.RestoreReportWindow()
    if window and not inCombat() then
        window:Show()
        if planChanged() then showStaleReportStatus() end
    end
end

function NS.ToggleWindow()
    if window and window:IsShown() then window:Hide() else open() end
end

SLASH_FOREVER_CONTEXT1 = "/fcontext"
SLASH_FOREVER_CONTEXT2 = "/forevercontext"
SLASH_FOREVER_CONTEXT3 = "/pjia"
SlashCmdList["FOREVER_CONTEXT"] = function(message)
    message = (message or ""):lower():match("^%s*(.-)%s*$")
    if message == "help" then
        say("/fcontext opens the report. Use /fcontext plan, compare, talents, gear, session, review, or minimap. Copy reports with Ctrl+C.")
    elseif message == "minimap" then
        NS.ToggleMinimap()
    elseif message == "plan" then
        NS.OpenPlanWindow()
    elseif message == "compare" then
        NS.OpenComparisonWindow()
    elseif NS.ModeLabels[message] then
        NS.OpenReport(message)
    else
        open()
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        settings()
        say("Ready. Click the minimap button or type /fcontext to export your character.")
    elseif event == "PLAYER_REGEN_DISABLED" and window and window:IsShown() then
        window:Hide()
        say("Window closed on entering combat. Open it again with /fcontext afterward.")
    end
end)
