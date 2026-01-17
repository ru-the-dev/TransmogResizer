-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
    return
end

--- @class BetterTransmog.Modules.TransmogFrame.CharacterPreview : LibRu.Module
local Module = Core.LibRu.Module.New("TransmogFrame.CharacterPreview");

Core.Modules = Core.Modules or {};

---@class BetterTransmog.Modules.TransmogFrame: LibRu.Module
local TransmogFrameModule = Core.Modules.TransmogFrame;

if not TransmogFrameModule then
    error(Module.Name .. " module requires TransmogFrame module to be loaded first.")
    return;
end


Module.Settings = {
    MinFrameWidth = 450,
    MaxFrameWidth = 900,
    MinCameraZoom = 2.5,
    MaxCameraZoom = 7.5,
}

TransmogFrameModule.CharacterPreview = Module;


-- =======================================================
-- Module Implementation
-- =======================================================

local function CharacterPreviewFrame_FixCamera()
    local preview = _G.TransmogFrame.CharacterPreview
    local modelScene = preview.ModelScene
    local camera = modelScene:GetActiveCamera();

    camera:SetMinZoomDistance(Module.Settings.MinCameraZoom); 
    camera:SetMaxZoomDistance(Module.Settings.MaxCameraZoom);
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


    CharacterPreviewFrame_FixCamera();
    CharacterPreviewFrame_UpdateWidth();

end

function Module:OnInitialize()
    Core.EventFrame:AddEvent(
        "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
        function(self, handle, _, frameId)
            if frameId ~= TransmogFrameModule.Settings.TRANSMOG_FRAME_ID then return end
            ApplyChanges()
            self:RemoveEvent(handle)
        end
    )
end