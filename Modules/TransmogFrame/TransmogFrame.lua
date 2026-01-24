-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;


--- @class BetterTransmog.Modules.TransmogFrame : LibRu.Module
---@field Modules {Anchor: BetterTransmog.Modules.TransmogFrame.Anchor, CharacterPreview: BetterTransmog.Modules.TransmogFrame.CharacterPreview, OutfitCollection: BetterTransmog.Modules.TransmogFrame.OutfitCollection, Positioning: BetterTransmog.Modules.TransmogFrame.Positioning, Resizing: BetterTransmog.Modules.TransmogFrame.Resizing, SettingsButton: BetterTransmog.Modules.TransmogFrame.SettingsButton, WardrobeCollection: BetterTransmog.Modules.TransmogFrame.WardrobeCollection}
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



-- =======================================================
-- Module Implementation
-- =======================================================

function Module:OnInitialize()
    Core.EventFrame:AddEvent(
        "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
        function(self, handle, _, frameId)
            if frameId ~= Module.Settings.TRANSMOG_FRAME_ID then return end
            

            self:RemoveEvent(handle)
        end
    )
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
    local _, currentMinHeight, _, _ = transmogFrame:GetResizeBounds()   

    Module:DebugLog("Setting TransmogFrame minimum frame width to " .. tostring(minWidth))
    transmogFrame:SetResizeBounds(minWidth, currentMinHeight)

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
    local currentMinWidth, _, _, _ = transmogFrame:GetResizeBounds()   

    Module:DebugLog("Setting TransmogFrame minimum frame height to " .. tostring(minHeight))
    transmogFrame:SetResizeBounds(currentMinWidth, minHeight)


    if autoAdjust and transmogFrame:GetHeight() < minHeight then
        Module:DebugLog("Current frame height is less than minimum, re-adjusting frame height.");
        transmogFrame:SetHeight(minHeight);
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

function Module:GetFrame()
    if _transmogFrame then return _transmogFrame end;

    if _G.TransmogFrame == nil then
        error("TransmogFrame is not loaded yet, make sure to call GetFrame only after the frame is shown.")
    end

    _transmogFrame = _G.TransmogFrame;

    return _transmogFrame;
end


