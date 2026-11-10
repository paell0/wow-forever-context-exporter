local _, NS = ...
local minimapButton

local function preferences()
    if type(ForeverContextDB) ~= "table" then ForeverContextDB = {} end
    if type(ForeverContextDB.minimap) ~= "table" then ForeverContextDB.minimap = {} end
    local db = ForeverContextDB.minimap
    if type(db.angle) ~= "number" or db.angle ~= db.angle or db.angle == math.huge or db.angle == -math.huge then
        db.angle = 225
    end
    db.angle = db.angle % 360
    db.hide = db.hide == true
    return db
end

local function inCombat()
    return type(InCombatLockdown) == "function" and InCombatLockdown()
end

local function updatePosition()
    if not minimapButton or not Minimap then return end
    local angle = math.rad(preferences().angle)
    local x, y = math.cos(angle), math.sin(angle)
    -- Honor square minimaps supplied by common UI replacements.
    if type(GetMinimapShape) == "function" and GetMinimapShape() == "SQUARE" then
        local extent = math.max(math.abs(x), math.abs(y))
        x, y = x / extent, y / extent
    end
    local radiusX = Minimap:GetWidth() / 2 + 8
    local radiusY = Minimap:GetHeight() / 2 + 8
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x * radiusX, y * radiusY)
end

local function stopDragging(self)
    self:SetScript("OnUpdate", nil)
    self.dragging = false
end

local function dragPosition(self)
    if inCombat() then stopDragging(self); return end
    local x, y = GetCursorPosition()
    local centerX, centerY = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    if not centerX or not centerY or not scale or scale <= 0 then return end
    x, y = x / scale - centerX, y / scale - centerY
    if x == 0 and y == 0 then return end
    preferences().angle = math.deg(math.atan2(y, x)) % 360
    updatePosition()
end

local function createButton()
    if minimapButton or not Minimap then return end
    local button = CreateFrame("Button", "ForeverContextMinimapButton", Minimap)
    minimapButton = button
    button:SetSize(32, 32)
    button:EnableMouse(true)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetSize(20, 20)
    button.icon:SetPoint("TOPLEFT", 7, -5)
    button.icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetSize(54, 54)
    button.border:SetPoint("TOPLEFT")
    button.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    button:SetScript("OnClick", function(self)
        if not self.dragging then NS.ToggleWindow() end
    end)
    button:SetScript("OnEnter", function(self)
        if self.dragging or not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("ForeverContext", 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: open or close character export.", 1, 1, 1)
        GameTooltip:AddLine("Drag: move around the minimap.", 1, 1, 1)
        GameTooltip:AddLine("Hide/show: /fcontext minimap", 0.6, 0.8, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    button:SetScript("OnDragStart", function(self)
        if inCombat() then return end
        self.dragging = true
        if GameTooltip then GameTooltip:Hide() end
        self:SetScript("OnUpdate", dragPosition)
        dragPosition(self)
    end)
    button:SetScript("OnDragStop", stopDragging)
    button:SetScript("OnHide", stopDragging)
    Minimap:HookScript("OnSizeChanged", updatePosition)
    updatePosition()
    if preferences().hide then button:Hide() else button:Show() end
end

function NS.ToggleMinimap()
    local db = preferences()
    db.hide = not db.hide
    createButton()
    if minimapButton then
        updatePosition()
        if db.hide then minimapButton:Hide() else minimapButton:Show() end
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        createButton()
    elseif minimapButton then
        stopDragging(minimapButton)
    end
end)
