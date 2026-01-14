-- SavedVariables: BetterTransmogAccountDB

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
    return
end

Core.Modules = Core.Modules or {}


local Module = {}

Core.Modules.AccountDBModule = Module;

local DEFAULTS = {
    TransmogFrame = {
        Size = {
            Width  = 965,
            Height = 606,
        },
        CharacterModelWidthPercent = 40,
        CollectionFrameModels      = 30,
        SetFrameModels             = 12,
    }
}

function Module:Initialize()
    local AccountDB = Core.LibRu.Utils.DB.CreateDatabase("BetterTransmogAccountDB", DEFAULTS)
    AccountDB:Init();

    Core.DB = Core.DB or {}
    Core.DB.Account = AccountDB  -- API methods (Init/Get/ResetAll/ResetSection/ResetValue)
end
