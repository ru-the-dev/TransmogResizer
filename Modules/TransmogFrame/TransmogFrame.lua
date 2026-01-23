-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized. Please ensure Core.lua is loaded first.")
    return
end

Core.Modules = Core.Modules or {};

--- @class BetterTransmog.Modules.TransmogFrame : LibRu.Module
---@field Modules {Anchor: BetterTransmog.Modules.TransmogFrame.Anchor, CharacterPreview: BetterTransmog.Modules.TransmogFrame.CharacterPreview, CollectionLayout: BetterTransmog.Modules.TransmogFrame.CollectionLayout, OutfitCollection: BetterTransmog.Modules.TransmogFrame.OutfitCollection, Positioning: BetterTransmog.Modules.TransmogFrame.Positioning, Resizing: BetterTransmog.Modules.TransmogFrame.Resizing, SettingsButton: BetterTransmog.Modules.TransmogFrame.SettingsButton}
local Module = Core.Libs.LibRu.Module.New("TransmogFrame", Core, { Core });

Module.Settings = {
    TRANSMOG_FRAME_ID = 24
}

-- =======================================================
-- Module Implementation
-- =======================================================

-- function Module:OnInitialize()
--     -- initialize sub-modules
--     Module.Anchor:Initialize();
--     Module.Positioning:Initialize();
--     Module.CharacterPreview:Initialize();
--     Module.CollectionLayout:Initialize();
--     Module.OutfitCollection:Initialize();
--     Module.Resizing:Initialize();
--     Module.SettingsButton:Initialize();
-- end
