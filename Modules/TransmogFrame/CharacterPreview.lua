-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.CharacterPreview : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "CharacterPreview", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame 
    }
);

--- ======================================================
--- Dependencies
--- ======================================================
---@type BetterTransmog.Modules.TransmogFrame
local transmogFrameModule = Core.Modules.TransmogFrame;

--- =======================================================
--- Module Settings
--- =======================================================

Module.Settings = {
    MinFrameWidth = 450,
    MaxFrameWidth = 900,
    MinCameraZoom = 2.5,
    MaxCameraZoom = 7.5,
    DefaultCameraZoom = 5.0,
}

Module.IsResetCameraHooked = false;

-- =======================================================
-- Module Implementation
-- =======================================================

local function CharacterPreviewFrame_FixCamera()
    local preview = _G.TransmogFrame.CharacterPreview
    local modelScene = preview.ModelScene
    local camera = modelScene:GetActiveCamera();


    camera:SetMinZoomDistance(Module.Settings.MinCameraZoom); 
    camera:SetMaxZoomDistance(Module.Settings.MaxCameraZoom);

    -- Set the current zoom to a reasonable default
    camera:SetZoomDistance(Module.Settings.DefaultCameraZoom);
end

local function CharacterPreviewFrame_HookReset()
    if Module.IsResetCameraHooked then return end;

    -- Hook the Reset method to reapply camera settings after reset
    local preview = _G.TransmogFrame.CharacterPreview
    local modelScene = preview.ModelScene

    hooksecurefunc(modelScene, "Reset", function()
        CharacterPreviewFrame_FixCamera()
    end)

    Module.IsResetCameraHooked = true;
end

local function CharacterPreviewFrame_UpdateWidth()
    local accountDB = Core.Modules.AccountDB.DB;
    local preview = _G.TransmogFrame.CharacterPreview

    local clampedWidth = math.min(
        math.max(
            accountDB.TransmogFrame.CharacterPreviewFrameWidth,
            Module.Settings.MinFrameWidth
        ),
        Module.Settings.MaxFrameWidth
    )

    preview:SetWidth(clampedWidth)
end



local function ApplyChanges()
    Module:DebugLog("Applying changes.")

    CharacterPreviewFrame_HookReset();
    CharacterPreviewFrame_FixCamera();
    CharacterPreviewFrame_UpdateWidth();


    -- hook on show, fix camera every time, show resets the camera settings
    _G.TransmogFrame:HookScript("OnShow", function(self)
        CharacterPreviewFrame_FixCamera();
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