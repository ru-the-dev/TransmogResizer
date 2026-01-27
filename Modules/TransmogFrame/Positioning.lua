-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.Positioning : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "Positioning", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame,
        Core.Modules.AccountDB
    }
);

--- =======================================================
--- Dependencies
--- ======================================================
---@type BetterTransmog.Modules.TransmogFrame
local transmogFrameModule = Core.Modules.TransmogFrame;


--- =======================================================
-- Module Settings
-- =======================================================
Module.Settings = {}

-- =======================================================
-- Module Implementation
-- =======================================================


local function GetSavedPosition(displayMode)
    local transmogFrameDB = Core.Modules.AccountDB.DB.TransmogFrame

    if displayMode == transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        return transmogFrameDB.FramePositionOutfit
    end

    return transmogFrameDB.FramePositionFull
end


function Module:OnInitialize()
    Module:DebugLog("Applying changes.")

    self:RestoreSavedPosition();

    local transmogFrame = transmogFrameModule:GetFrame();

    Core.Libs.LibRu.Utils.Frame.MakeDraggable(
        transmogFrame.TitleContainer,
        transmogFrame,
        true
    )

    -- set transmog frame to be user placed
    transmogFrame:SetUserPlaced(true);

    transmogFrame.TitleContainer:HookScript("OnDragStop", function(self)
        Module:SaveFramePosition();
    end)

    transmogFrame:HookScript("OnShow", function(self)
        Module:RestoreSavedPosition();
    end)
end

---@param displayMode? string display mode to restore for, if nil, will take the current transmogFrameModule displaymode
function Module:RestoreSavedPosition(displayMode)

    --- set default to be the current display mode
    displayMode = displayMode or transmogFrameModule.DisplayMode;

    Module:DebugLog("Restoring TransmogFrame position from AccountDB for display mode: " .. displayMode);
    -- restore position from account DB
    local savedPosition = GetSavedPosition(displayMode);
    local transmogFrame = transmogFrameModule:GetFrame();

    if savedPosition.CenterX and savedPosition.CenterY then
        transmogFrame:ClearAllPoints()
        transmogFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", savedPosition.CenterX, savedPosition.CenterY)
        return
    end

    transmogFrame:ClearAllPoints()
    transmogFrame:SetPoint(savedPosition.Point, _G[savedPosition.RelativeTo], savedPosition.RelativePoint, savedPosition.OffsetX, savedPosition.OffsetY)
end

---@param displayMode? string display mode to restore for, if nil, will take the current transmogFrameModule displaymode
function Module:SaveFramePosition(displayMode)
    --- set default to be the current display mode
    displayMode = displayMode or transmogFrameModule.DisplayMode;

    
    --- skip saving if we're in the middle of applying a mode change
    if transmogFrameModule.IsApplyingMode then
        Module:DebugLog("Skipping Saving TransmogFrame position to AccountDB for display mode: " .. displayMode);
        return 
    end;

    local transmogFrame = transmogFrameModule:GetFrame();
    local centerX, centerY = transmogFrame:GetCenter()
    if not centerX or not centerY then return end

    Module:DebugLog("Saving TransmogFrame position to AccountDB for display mode: " .. displayMode);


    local frameScale = transmogFrame:GetEffectiveScale()
    local parentScale = UIParent:GetEffectiveScale()
    centerX = centerX * frameScale / parentScale
    centerY = centerY * frameScale / parentScale

    -- save position to account DB
    local savedPosition = GetSavedPosition(displayMode)

    savedPosition.CenterX = centerX
    savedPosition.CenterY = centerY
end