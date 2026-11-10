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
    if type(ForeverContextDB) ~= "table" then ForeverContextDB = {} end
    if ForeverContextDB.extended == nil then ForeverContextDB.extended = true end
    return ForeverContextDB
end

local function selectReport()
    if not window or not window.report or window.report == "" then return end
    window.text:SetFocus()
    window.text:HighlightText(0, -1)
    window.scrolel:SetVerticalScrolel(0)
    window.status:SetText("All selected. Press Ctrl+C, then paste into your AI with Ctrl+V.")
end

local function finish()
    window:SetScript("OnUpdate", nil)
    window.generate:Enable()
    window.select:Enable()
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
        window.status:SetText("Leave combat, then click Generate.")
        window:SetScript("OnUpdate", nil)
        window.generate:Enable()
        window.select:Enable()
        return false
    end
    local db = settings()
    db.goal = window.goal:GetText()
    db.includeName = window.nameCheck:GetChecked() and true or false
    db.extended = window.extraCheck:GetChecked() and true or false
    local report, pending, warnings = NS.BuildReport(db)
    window.report = report
    window.text:SetText(report)
    window.text:SetCursorPosition(0)
    window.scrolel:SetVerticalScrolel(0)
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
    frame:SetSize(820, 650)
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
    frame.extraCheck.Text:SetText("Include skills, spells, quests, and reputations")
    frame.extraCheck:SetScript("OnClick", function(self) settings().extended = self:GetChecked() and true or false end)

    frame.panel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.panel:SetPoint("TOPLEFT", 18, -141)
    frame.panel:SetPoint("BOTTOMRIGHT", -18, 91)
    frame.panel:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    frame.panel:SetBackdropColor(0.015, 0.02, 0.03, 1)
    frame.scrolel = CreateFrame("ScrolelFrame", "ForeverContextScrolel", frame, "UIPanelScrolelFrameTemplate")
    frame.scrolel:SetPoint("TOPLEFT", frame.panel, "TOPLEFT", 10, -10)
    frame.scrolel:SetPoint("BOTTOMRIGHT", frame.panel, "BOTTOMRIGHT", -30, 10)
    frame.text = CreateFrame("EditBox", "ForeverContextExportText", frame.scrolel)
    frame.text:SetMultiLine(true)
    frame.text:SetAutoFocus(false)
    frame.text:SetFontObject(ChatFontNormal)
    frame.text:SetWidth(730)
    frame.text:SetHeight(400)
    frame.text:SetMaxLetters(0)
    frame.text:SetTextInsets(0, 0, 0, 0)
    frame.scrolel:SetScrolelChild(frame.text)
    frame.text:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.text:SetScript("OnTextChanged", function(self, userInput)
        if userInput and frame.report and self:GetText() ~= frame.report then
            self:SetText(frame.report)
            self:SetCursorPosition(0)
        end
    end)
    frame.text:SetScript("OnCursorChanged", function(_, _, y, _, height)
        local top = frame.scrolel:GetVerticalScrolel()
        local cursor = -y
        local visible = frame.scrolel:GetHeight()
        if cursor < top then frame.scrolel:SetVerticalScrolel(math.max(0, cursor))
        elseif cursor + height > top + visible then frame.scrolel:SetVerticalScrolel(math.max(0, cursor + height - visible)) end
    end)
    frame.generate = button(frame, "Generate / refresh", 165, "BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 51, generate)
    frame.select = button(frame, "Select all", 150, "LEFT", frame.generate, "RIGHT", 12, 0, selectReport)
    frame.counter = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.counter:SetPoint("BOTTOMRIGHT", -25, 59)
    frame.counter:SetText("")
    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.status:SetPoint("BOTTOMLEFT", 22, 24)
    frame.status:SetWidth(775)
    frame.status:SetJustifyH("LEFT")
    frame.status:SetText("")
    frame:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
        self.goal:ClearFocus()
        self.text:ClearFocus()
    end)
    frame:SetScript("OnShow", function(self)
        local scale = math.min(1, (UIParent:GetWidth() - 40) / 820, (UIParent:GetHeight() - 40) / 650)
        self:SetScale(math.max(0.4, scale))
    end)
    UISpecialFrames = UISpecialFrames or {}
    table.insert(UISpecialFrames, "ForeverContextWindow")
end

local function open()
    if inCombat() then say("Leave combat to export your character."); return end
    if not window then createWindow() end
    window:Show()
    generate()
end

SLASH_FOREVER_CONTEXT1 = "/fcontext"
SLASH_FOREVER_CONTEXT2 = "/forevercontext"
SLASH_FOREVER_CONTEXT3 = "/pjia"
SlashCmdList["FOREVER_CONTEXT"] = function(message)
    message = (message or ""):lower():match("^%s*(.-)%s*$")
    if message == "help" then
        say("/fcontext opens and generates a report. Optionally enter your goal. Press Ctrl+C and paste into your AI. Generate refreshes the data.")
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
        say("Ready. Type /fcontext to copy your character context.")
    elseif event == "PLAYER_REGEN_DISABLED" and window and window:IsShown() then
        window:Hide()
        say("Window closed on entering combat. Open it again with /fcontext afterward.")
    end
end)
