local _, NS = ...
local windows, returnToReport, switching = {}, false, false

function NS.ToolsAllowed()
    if InCombatLockdown and InCombatLockdown() then
        if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(NS.L("ForeverContext: leave combat to use these tools.")) end
        return false
    end
    return true
end

function NS.CloseAuxiliaryWindows()
    returnToReport = false
    for _, frame in ipairs(windows) do if frame:IsShown() then frame:Hide() end end
end

function NS.ShowToolWindow(frame)
    if not NS.ToolsAllowed() then return end
    returnToReport = NS.SuspendReportWindow() or returnToReport
    switching = true
    for _, other in ipairs(windows) do if other ~= frame and other:IsShown() then other:Hide() end end
    switching = false
    frame:Show()
end

function NS.ToolLabel(parent, text, x, y, width)
    local font = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    font:SetPoint("TOPLEFT", x, y)
    font:SetWidth(width or 700)
    font:SetJustifyH("LEFT")
    NS.SetText(font,text)
    return font
end

function NS.ToolButton(parent, text, x, y, width, action)
    local widget = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    widget:SetPoint("TOPLEFT", x, y)
    widget:SetSize(width, 26)
    NS.SetText(widget,text)
    widget:SetScript("OnClick", action)
    return widget
end

function NS.ToolEdit(parent, name, x, y, width, maxLetters)
    local edit = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    edit:SetPoint("TOPLEFT", x, y)
    edit:SetSize(width, 25)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(maxLetters or 240)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    parent:HookScript("OnHide", function() edit:ClearFocus() end)
    return edit
end

function NS.ToolCheck(parent, text, x, y, checked, action)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", x, y)
    check:SetChecked(checked == true)
    check.Text:SetWidth(math.max(80,parent:GetWidth()-x-65))
    NS.SetText(check.Text,text)
    check:SetScript("OnClick", function(self) action(self:GetChecked() and true or false) end)
    return check
end

function NS.ToolTextArea(parent, name, x, y, width, height, maxLetters)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetPoint("TOPLEFT", x-6, y+6)
    panel:SetSize(width+32, height+12)
    panel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
    panel:SetBackdropColor(0.015,0.02,0.03,1)
    local scroll = CreateFrame("ScrollFrame", name .. "Scroll", parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", x, y)
    scroll:SetSize(width, height)
    local edit = CreateFrame("EditBox", name, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(width-10)
    edit:SetHeight(height)
    edit:SetMaxLetters(maxLetters or 40000)
    scroll:SetScrollChild(edit)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnCursorChanged", function(_,_,y,_,h)
        local top, cursor = scroll:GetVerticalScroll(), -y
        if cursor < top then scroll:SetVerticalScroll(math.max(0,cursor))
        elseif cursor+h > top+scroll:GetHeight() then scroll:SetVerticalScroll(math.max(0,cursor+h-scroll:GetHeight())) end
    end)
    parent:HookScript("OnHide", function() edit:ClearFocus() end)
    return edit, scroll
end

function NS.ScaleToolWindow(frame)
    frame:SetScale(math.min(1,(UIParent:GetWidth()-40)/frame:GetWidth(),(UIParent:GetHeight()-40)/frame:GetHeight()))
end

function NS.ResizeToolWindow(frame,height)
    frame:SetHeight(height)
    if frame:IsShown() then NS.ScaleToolWindow(frame) end
end

function NS.CreateToolWindow(name, title, subtitle, height)
    local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(760, height)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=16,
        insets={left=4,right=4,top=4,bottom=4}})
    frame:SetBackdropColor(0.035,0.05,0.075,1)
    frame:SetBackdropBorderColor(0.3,0.65,0.8,1)
    frame.title=NS.ToolLabel(frame, "|cffffd46a" .. title .. "|r", 20,-20)
    frame.subtitle=NS.ToolLabel(frame, subtitle, 20,-45)
    frame.close=CreateFrame("Button",nil,frame,"UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT",-5,-5)
    frame:SetScript("OnShow",NS.ScaleToolWindow)
    frame:SetScript("OnHide",function(self)
        self:SetScript("OnUpdate",nil)
        if returnToReport and not switching then returnToReport=false; NS.RestoreReportWindow() end
    end)
    windows[#windows+1]=frame
    UISpecialFrames=UISpecialFrames or {}
    table.insert(UISpecialFrames,name)
    return frame
end

local toolsWindow
function NS.OpenToolsWindow()
    if not NS.ToolsAllowed() then return end
    if not toolsWindow then
        local frame=NS.CreateToolWindow("ForeverContextToolsWindow", "ForeverContext — More tools",
            "These tools are optional. To ask for advice, you only need to prepare and copy your report.", 640)
        toolsWindow=frame
        frame.actions,frame.descriptions={},{}
        local choices={
            {"compare", "Compare two items", "Drag in two items. Prepare a report so your AI can help you choose one.", "OpenComparisonWindow"},
            {"plan", "Use an AI plan", "Paste a plan from your AI, check its tasks and track them as you play.", "OpenPlanWindow"},
            {"bags", "See items in my bags", "Look through your carried items. Choose items to compare or tell the AI which ones to keep.", "OpenBagWindow"},
            {"keep", "Tell the AI what to keep", "List items you want to keep and why. This guides the AI; it does not lock items in game.", "OpenKeepWindow"},
            {"sources", "Note an item's origin", "Optional notes: record where an item comes from. This is not a search for all possible drops.", "OpenSourcesWindow"},
            {"loadouts", "Save a talent build", "Save your current talents for an activity and ask the AI to compare builds. Nothing is applied automatically.", "OpenLoadoutsWindow"},
        }
        for index,row in ipairs(choices) do
            local action=row[4]
            local y=-95-(index-1)*76
            frame.actions[row[1]]=NS.ToolButton(frame,row[2],20,y,245,function() NS[action]() end)
            frame.descriptions[row[1]]=NS.ToolLabel(frame,row[3],285,y,440)
        end
        frame.done=NS.ToolButton(frame,"Back",20,-580,200,function() frame:Hide() end)
    end
    NS.ShowToolWindow(toolsWindow)
end

local events=CreateFrame("Frame")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:SetScript("OnEvent",function() NS.CloseAuxiliaryWindows() end)
