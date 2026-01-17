-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
    return
end

Core.Modules = Core.Modules or {};

--- @class BetterTransmog.Modules.TransmogFrame : LibRu.Module
local Module = Core.LibRu.Module.New("TransmogFrame");

Module.Settings = {
    TRANSMOG_FRAME_ID = 24
}

Core.Modules.TransmogFrame = Module;

-- =======================================================
-- Module Implementation
-- =======================================================

function Module:OnInitialize()
    -- initialize sub-modules
    Module.Anchor:Initialize();
    Module.Positioning:Initialize();
    Module.Resizing:Initialize();
    Module.CharacterPreview:Initialize();
    Module.CollectionLayout:Initialize();
end
