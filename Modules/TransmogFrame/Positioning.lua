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
Module.PendingRestoreToken = 0


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

local function RestoreSavedPosition(displayMode)
    Module:DebugLog("Restoring TransmogFrame position from AccountDB.");
    -- restore position from account DB
    local savedPosition = GetSavedPosition(displayMode or transmogFrameModule.DisplayMode);
    local transmogFrame = transmogFrameModule:GetFrame();

    if savedPosition.CenterX and savedPosition.CenterY then
        transmogFrame:ClearAllPoints()
        transmogFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", savedPosition.CenterX, savedPosition.CenterY)
        return
    end

    transmogFrame:ClearAllPoints()
    transmogFrame:SetPoint(savedPosition.Point, _G[savedPosition.RelativeTo], savedPosition.RelativePoint, savedPosition.OffsetX, savedPosition.OffsetY)
end

local function SaveFramePosition(displayMode)
    Module:DebugLog("Saving TransmogFrame position to AccountDB.");
    if transmogFrameModule.IsReopeningFrame then return end
    local transmogFrame = transmogFrameModule:GetFrame();
    local centerX, centerY = transmogFrame:GetCenter()
    if not centerX or not centerY then return end

    local frameScale = transmogFrame:GetEffectiveScale()
    local parentScale = UIParent:GetEffectiveScale()
    centerX = centerX * frameScale / parentScale
    centerY = centerY * frameScale / parentScale

    -- save position to account DB
    local savedPosition = GetSavedPosition(displayMode or transmogFrameModule.DisplayMode)

    savedPosition.CenterX = centerX
    savedPosition.CenterY = centerY
end

function Module:OnInitialize()
    Module:DebugLog("Applying changes.")

    RestoreSavedPosition();

    local transmogFrame = transmogFrameModule:GetFrame();

    Core.Libs.LibRu.Utils.Frame.MakeDraggable(
        transmogFrame.TitleContainer,
        transmogFrame,
        true
    )

    -- set transmog frame to be user placed
    transmogFrame:SetUserPlaced(true);

    -- hook show/hide to save/restore position
    transmogFrame:HookScript("OnHide", function(self)
        SaveFramePosition();
    end)

    transmogFrame:HookScript("OnShow", function(self)
        RestoreSavedPosition();
    end)

    transmogFrame.TitleContainer:HookScript("OnDragStop", function(self)
        SaveFramePosition();
    end)
end

function Module:RestoreSavedPosition(displayMode)
    RestoreSavedPosition(displayMode)
end

function Module:SaveFramePosition(displayMode)
    SaveFramePosition(displayMode)
end

function Module:RestoreSavedPositionDeferred(displayMode, delay)
    Module.PendingRestoreToken = Module.PendingRestoreToken + 1
    local token = Module.PendingRestoreToken
    local wait = delay or 0

    C_Timer.After(wait, function()
        if token ~= Module.PendingRestoreToken then
            return
        end

        RestoreSavedPosition(displayMode)
    end)
end