-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
    return
end

--- @class BetterTransmog.Modules.TransmogFrame.Resizing : LibRu.Module
local Module = Core.LibRu.Module.New("TransmogFrame.Resizing");

Core.Modules = Core.Modules or {};

---@class BetterTransmog.Modules.TransmogFrame: LibRu.Module
local TransmogFrameModule = Core.Modules.TransmogFrame;

if not TransmogFrameModule then
    error(Module.Name .. " module requires TransmogFrame module to be loaded first.")
    return;
end


Module.Settings = {

}


TransmogFrameModule.Resizing = Module;


-- =======================================================
-- Module Implementation
-- =======================================================
local function ApplyChanges()
    Module:DebugLog("Applying changes.")


     local resizeButton = Core.LibRu.Frames.ResizeButton.New(
        _G.TransmogFrame,
        _G.TransmogFrame,
        30
    )

    resizeButton:SetFrameStrata("FULLSCREEN_DIALOG")

    _G.TransmogFrame.ResizeButton = resizeButton

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