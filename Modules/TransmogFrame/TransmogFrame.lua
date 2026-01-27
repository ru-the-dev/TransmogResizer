-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;


--- @class BetterTransmog.Modules.TransmogFrame : LibRu.Module
---@field Modules {CharacterPreview: BetterTransmog.Modules.TransmogFrame.CharacterPreview, OutfitCollection: BetterTransmog.Modules.TransmogFrame.OutfitCollection, Positioning: BetterTransmog.Modules.TransmogFrame.Positioning, Resizing: BetterTransmog.Modules.TransmogFrame.Resizing, SettingsButton: BetterTransmog.Modules.TransmogFrame.SettingsButton, WardrobeCollection: BetterTransmog.Modules.TransmogFrame.WardrobeCollection}
local Module = Core.Libs.LibRu.Module.New("TransmogFrame", Core, { Core });

--- =======================================================
--- locals
--- ================================================
local _transmogFrame = nil

--- =======================================================
--- Settings
--- =======================================================

Module.Settings = {
    TRANSMOG_FRAME_ID = 24,
    MinHeight = 750,
    MinWidth = 1330,
    MinResizeBounds = {
        Width = 10,
        Height = 10,
    }
}

Module.DisplayMode = nil

Module.Enum = {}
Module.Enum.DISPLAY_MODE = {
    FULL = "full",
    OUTFIT_SWAP = "outfit_swap"
}

Module.IsApplyingMode = false
Module.IsReopeningFrame = false
Module.IsSwitchingModeHidden = false

---@param displayMode string
---@return boolean
function Module:IsValidDisplayMode(displayMode)
    return displayMode == Module.Enum.DISPLAY_MODE.FULL
        or displayMode == Module.Enum.DISPLAY_MODE.OUTFIT_SWAP
end

--- =======================================================
--- Module Implementation
--- =======================================================

function Module:OnInitialize()
    -- Set initial display mode to FULL
    self.DisplayMode = Module.Enum.DISPLAY_MODE.FULL
    Module:DebugLog("Initial display mode set to: " .. self.DisplayMode)
    
    -- Hook TRANSMOGRIFY_OPEN to force FULL mode when transmog NPC opens the frame
    Core.EventFrame:AddEvent("TRANSMOGRIFY_OPEN", function()
        Module:DebugLog("TRANSMOGRIFY_OPEN event fired - switching to FULL mode")
        self:SetDisplayMode(Module.Enum.DISPLAY_MODE.FULL)
    end)
end

--- Sets the display mode and applies all associated configuration
---@param displayMode string
function Module:SetDisplayMode(displayMode)
    if not displayMode then
        Module:DebugLog("ERROR: Invalid display mode - nil provided")
        return
    end
    if self.DisplayMode == displayMode then return end

    local positioning = self:GetModule("Positioning")
    if positioning and positioning.SaveFramePosition then
        positioning:SaveFramePosition(self.DisplayMode)
    end

    local transmogFrame = self:GetFrame()
    if transmogFrame and transmogFrame:IsShown() and not self.IsReopeningFrame and not self.IsSwitchingModeHidden then
        self.IsSwitchingModeHidden = true
        HideUIPanel(transmogFrame)

        self.IsApplyingMode = true
        self.DisplayMode = displayMode
        Core.EventFrame:FireScript("OnTransmogFrameDisplayModeChanged", displayMode)
        self.IsApplyingMode = false

        C_Timer.After(0, function()
            ShowUIPanel(transmogFrame)
            self.IsSwitchingModeHidden = false
        end)
        return
    end

    self.IsApplyingMode = true
    self.DisplayMode = displayMode
    Core.EventFrame:FireScript("OnTransmogFrameDisplayModeChanged", displayMode)
    self.IsApplyingMode = false
end

--- Opens the transmog frame in a specific display mode
---@param displayMode string
function Module:OpenFrameInMode(displayMode)
    local transmogFrame = self:GetFrame()
    if self.DisplayMode == displayMode and transmogFrame and transmogFrame:IsShown() then
        return
    end

    if transmogFrame and transmogFrame:IsShown() then
        HideUIPanel(transmogFrame)
        self:SetDisplayMode(displayMode)
        C_Timer.After(0, function()
            ShowUIPanel(transmogFrame)
        end)
        return
    end

    self.IsReopeningFrame = true
    self:SetDisplayMode(displayMode)

    if transmogFrame then
        HideUIPanel(transmogFrame)
        ShowUIPanel(transmogFrame)

        self.IsReopeningFrame = false
        -- re-emit after show so handlers can apply to a fully loaded frame
        Core.EventFrame:FireScript("OnTransmogFrameDisplayModeChanged", self.DisplayMode)
        return
    end

    self.IsReopeningFrame = false
end


function Module:GetStaticSizedChildrenWidth()
    local outfitCollectionModule = self.Modules.OutfitCollection;

    local outfitCollectionFrameWidth = 0;
    if outfitCollectionModule then
        outfitCollectionFrameWidth = outfitCollectionModule:GetExpandedWidth();
    else
        local outfitCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(self:GetFrame(), "OutfitCollection");
        if outfitCollectionFrame then
            outfitCollectionFrameWidth = outfitCollectionFrame:GetWidth();
        end
    end

    local characterPreviewFrameWidth = 0;
    local characterPreviewFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(self:GetFrame(), "CharacterPreview");

    if characterPreviewFrame then
        characterPreviewFrameWidth = characterPreviewFrame:GetWidth();
    end

    return outfitCollectionFrameWidth + characterPreviewFrameWidth;
end

--- sets the minimum width of the TransmogFrame and optionally auto-adjusts the frame width
--- @param minWidth number The minimum width to set for the TransmogFrame
--- @param autoAdjust? boolean If true, the frame will automatically adjust to meet the minimum width if it's currently smaller (default: true)
function Module:SetMinFrameWidth(minWidth, autoAdjust)
    autoAdjust = autoAdjust or true;

    ---@type Frame
    local transmogFrame = self:GetFrame();
    local _, currentMinHeight, currentMaxWidth, currentMaxHeight = transmogFrame:GetResizeBounds()   

    Module:DebugLog("Setting TransmogFrame minimum frame width to " .. tostring(minWidth))
    transmogFrame:SetResizeBounds(minWidth, currentMinHeight, currentMaxWidth, currentMaxHeight)

    if autoAdjust and transmogFrame:GetWidth() < minWidth then
        Module:DebugLog("Current frame width is less than minimum, re-adjusting frame width.");
        transmogFrame:SetWidth(minWidth);
    end     
end

--- sets the minimum height of the TransmogFrame and optionally auto-adjusts the frame height
---@param minHeight number The minimum height to set for the TransmogFrame
---@param autoAdjust? boolean If true, the frame will automatically adjust to meet the minimum height if it's currently smaller (default: true)
function Module:SetMinFrameHeight(minHeight, autoAdjust)
    autoAdjust = autoAdjust or true;

    ---@type Frame
    local transmogFrame = self:GetFrame();
    local currentMinWidth, _, currentMaxWidth, currentMaxHeight = transmogFrame:GetResizeBounds()   

    Module:DebugLog("Setting TransmogFrame minimum frame height to " .. tostring(minHeight))
    transmogFrame:SetResizeBounds(currentMinWidth, minHeight, currentMaxWidth, currentMaxHeight)

    if autoAdjust and transmogFrame:GetHeight() < minHeight then
        Module:DebugLog("Current frame height is less than minimum, re-adjusting frame height.");
        transmogFrame:SetHeight(minHeight);
    end
end

--- sets the maximum width of the TransmogFrame and optionally auto-adjusts the frame width
---@param maxWidth? number The maximum width to set for the TransmogFrame (default: infinite)
---@param autoAdjust? boolean If true, the frame will automatically adjust to meet the maximum width if it's currently bigger (default: true)
function Module:SetMaxFrameWidth(maxWidth, autoAdjust)
    autoAdjust = autoAdjust or true;

    ---@type Frame
    local transmogFrame = self:GetFrame();
    local currentMinWidth, currentMinHeight, _, currentMaxHeight = transmogFrame:GetResizeBounds()   

    Module:DebugLog("Setting TransmogFrame maximum frame width to " .. tostring(maxWidth))
    transmogFrame:SetResizeBounds(currentMinWidth, currentMinHeight, maxWidth, currentMaxHeight)

    if autoAdjust and maxWidth and transmogFrame:GetWidth() > maxWidth then
        Module:DebugLog("Current frame width is higher than maximum, re-adjusting frame width.");
        transmogFrame:SetWidth(maxWidth);
    end
end

--- sets the maximum height of the TransmogFrame and optionally auto-adjusts the frame height
---@param maxHeight? number The maximum width to set for the TransmogFrame (default: infinite)
---@param autoAdjust? boolean If true, the frame will automatically adjust to meet the maximum width if it's currently bigger (default: true)
function Module:SetMaxFrameHeight(maxHeight, autoAdjust)
    autoAdjust = autoAdjust or true;

    ---@type Frame
    local transmogFrame = self:GetFrame();
    local currentMinWidth, currentMinHeight, currentMaxWidth, _ = transmogFrame:GetResizeBounds()   

    Module:DebugLog("Setting TransmogFrame maximum frame height to " .. tostring(maxHeight))
    transmogFrame:SetResizeBounds(currentMinWidth, currentMinHeight, currentMaxWidth, maxHeight)

    if autoAdjust and maxHeight and transmogFrame:GetHeight() > maxHeight then
        Module:DebugLog("Current frame height is higher than maximum, re-adjusting frame height.");
        transmogFrame:SetHeight(maxHeight);
    end
end

--- sets the minimum size of the transmogFrame and optionally auto-adjusts the frame to that size if it's currently smaller.
---@param minWidth number The minimum width to set for the TransmogFrame
---@param minHeight number The minimum height to set for the TransmogFrame
---@param autoAdjust? boolean If true, the frame will automatically adjust to meet the minimum height if it's currently smaller (default: true)
function Module:SetMinFrameSize(minWidth, minHeight, autoAdjust)
    self:SetMinFrameWidth(minWidth, autoAdjust);
    self:SetMinFrameHeight(minHeight, autoAdjust);
end

--- sets the minimum size of the transmogFrame and optionally auto-adjusts the frame to that size if it's currently smaller.
---@param maxWidth? number The minimum width to set for the TransmogFrame (default: infinite) 
---@param maxHeight? number The minimum height to set for the TransmogFrame (default: infinite)
---@param autoAdjust? boolean If true, the frame will automatically adjust to meet the minimum height if it's currently smaller (default: true)
function Module:SetMaxFrameSize(maxWidth, maxHeight, autoAdjust)
    self:SetMaxFrameWidth(maxWidth, autoAdjust);
    self:SetMaxFrameHeight(maxHeight, autoAdjust);
end

---@return Frame
function Module:GetFrame()
    if _transmogFrame then return _transmogFrame end;

    if _G.TransmogFrame == nil then
        error("TransmogFrame is not loaded yet, make sure to call GetFrame only after the frame is shown.")
    end

    _transmogFrame = _G.TransmogFrame;

    -- set initial resize bounds (will be overrriden later by other modules if needed)
    Module:SetDefaultResizeBounds();

    return _transmogFrame;
end

function Module:SetDefaultResizeBounds()
    -- set default
    self:GetFrame():SetResizeBounds(Module.Settings.MinResizeBounds.Width, Module.Settings.MinResizeBounds.Height);
    self:SetMinFrameSize(Module.Settings.MinWidth, Module.Settings.MinHeight, true);
    
    --- check if size module is loaded, and adjust accordingly
    --- @type BetterTransmog.Modules.TransmogFrame.WardrobeCollection|nil
    local wardrobeCollectionModule = self:GetModule("WardrobeCollection");
    if wardrobeCollectionModule then
        wardrobeCollectionModule:SetCollectionFrameMinWidth();
    end
end

--- Pins the frame so width changes expand to the right
function Module:PinToLeft()
    local frame = self:GetFrame()
    local left = frame:GetLeft()
    local top = frame:GetTop()
    if not left or not top then return end

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
end
