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
    MinWidth = 1330
}



Module.Enum = {};
---@enum BetterTransmog.Modules.TransmogFrame.DisplayMode
Module.Enum.DISPLAY_MODE = {
    FULL = 1,
    OUTFIT_SWAP = 2
}
Module.DisplayMode = Module.Enum.DISPLAY_MODE.FULL; -- default display mode


-- =======================================================
-- Module Implementation
-- =======================================================
function Module:OnInitialize()
    Core.EventFrame:AddEvent("TRANSMOGRIFY_OPEN", function()
        self:SetDisplayMode(Module.Enum.DISPLAY_MODE.FULL);
    end);
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

    Module:DebugLog("Setting TransmogFrame maximum frame width to " .. tostring(maxHeight))
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
    self:GetFrame():SetResizeBounds(10,10);
    self:SetMinFrameSize(Module.Settings.MinWidth, Module.Settings.MinHeight, true);
    

    --- check if size module is loaded, and adjust accordingly
    --- @type BetterTransmog.Modules.TransmogFrame.WardrobeCollection|nil
    local wardrobeCollectionModule = self:GetModule("WardrobeCollection");
    if wardrobeCollectionModule then
        wardrobeCollectionModule:SetCollectionFrameMinWidth();
    end
end

---@param displayMode BetterTransmog.Modules.TransmogFrame.DisplayMode
function Module:SetDisplayMode(displayMode)
    Module:DebugLog("Setting TransmogFrame display mode to " .. tostring(displayMode))

    if self.DisplayMode == displayMode then
        Module:DebugLog("Display mode is already set to " .. tostring(displayMode) .. ", no changes needed.")
        return
    end

    self.DisplayMode = displayMode;
    Core.EventFrame:FireScript("OnTransmogFrameDisplayModeChanged", displayMode);
end

---@param displayMode BetterTransmog.Modules.TransmogFrame.DisplayMode
function Module:OpenTransmogFrame(displayMode)
    
    self:SetDisplayMode(displayMode);
    
    if displayMode == Module.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        
        local transmogFrame = self:GetFrame();
        if transmogFrame then
            -- ensure frame is hidden first to stop interaction with transmog npc
            HideUIPanel(transmogFrame);

            ShowUIPanel(transmogFrame); -- important else we taint the frame.
        end
    end
end