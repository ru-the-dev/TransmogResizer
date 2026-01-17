-- SavedVariables: BetterTransmogAccountDB

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
    return
end

Core.Modules = Core.Modules or {};


---@class BetterTransmog.Modules.AccountDB : LibRu.Module
local Module = Core.LibRu.Module.New("AccountDB");
Core.Modules.AccountDB = Module;

local DEFAULTS = {
    TransmogFrame = {
        CharacterPreviewFrameWidth = 658,
        FramePosition = {
            Point = "CENTER",
            RelativeTo = "UIParent",
            RelativePoint = "CENTER",
            OffsetX = 0,
            OffsetY = 0,
        }
    }
}

function Module:OnInitialize()
    local AccountDB = Core.LibRu.Utils.DB.CreateDatabase("BetterTransmogAccountDB", DEFAULTS)
    AccountDB:Init();

    Module.DB = AccountDB;

    self:DebugLog("AccountDB initialized.");
end
