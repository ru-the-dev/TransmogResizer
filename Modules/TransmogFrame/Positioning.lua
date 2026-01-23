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
        Core.Modules.TransmogFrame 
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
Module.Settings = {

}


-- =======================================================
-- Module Implementation
-- =======================================================


local function RestoreSavedPosition()
    Module:DebugLog("Restoring TransmogFrame position from AccountDB.");
    -- restore position from account DB
    local savedPosition = Core.Modules.AccountDB.DB.TransmogFrame.FramePosition;

    _G.TransmogFrame:ClearAllPoints()
    _G.TransmogFrame:SetPoint(savedPosition.Point, _G[savedPosition.RelativeTo], savedPosition.RelativePoint, savedPosition.OffsetX, savedPosition.OffsetY)
end

local function SaveFramePosition()
    Module:DebugLog("Saving TransmogFrame position to AccountDB.");
    local point, relativeTo, relativePoint, offsetX, offsetY = _G.TransmogFrame:GetPoint()

    -- save position to account DB
    local savedPosition = Core.Modules.AccountDB.DB.TransmogFrame.FramePosition

    savedPosition.Point = point
    savedPosition.RelativeTo = relativeTo and relativeTo:GetName() or "UIParent"
    savedPosition.RelativePoint = relativePoint
    savedPosition.OffsetX = offsetX
    savedPosition.OffsetY = offsetY
end

local function ApplyChanges()
    Module:DebugLog("Applying changes.")

    RestoreSavedPosition();

    Core.Libs.LibRu.Utils.Frame.MakeDraggable(
        _G.TransmogFrame.TitleContainer,
        _G.TransmogFrame,
        true
    )

    -- set transmog frame to be user placed
    _G.TransmogFrame:SetUserPlaced(true);

    -- hook show/hide to save/restore position
    _G.TransmogFrame:HookScript("OnHide", function(self)
        SaveFramePosition();
    end)

    _G.TransmogFrame:HookScript("OnShow", function(self)
        RestoreSavedPosition();
    end)
end

function Module:OnInitialize()
    Core.EventFrame:AddEvent(
        "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
        function(self, handle, _, frameId)
            if frameId ~= transmogFrameModule.Settings.TRANSMOG_FRAME_ID then return end
            ApplyChanges()
            self:RemoveEvent(handle)
        end
    )
end