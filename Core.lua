-- Initialization and setup logic

---@class BetterTransmog
_G.BetterTransmog = {
    ADDON_NAME = "BetterTransmog"
}

---@class BetterTransmog
local Core = _G.BetterTransmog

--- @type LibRu
local LibRu = _G["LibRu"]

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end
Core.LibRu = LibRu;

-- Debug logging system
Core.Debug = true; -- Toggle this to enable/disable debug messages


function Core.DebugLog(message)
    print("|cff9f7fffBetterTransmog [DEBUG]:|r " .. tostring(message))
end

-- If not in debug mode, replace with empty function
if not Core.Debug then
    Core.DebugLog = function() end
end

-- Create a Global event frame
Core.EventFrame = LibRu.Frames.EventFrame.New(CreateFrame("Frame"));

Core.EventFrame:AddEvent("ADDON_LOADED", function (self, handle, event, addonName)
    if addonName ~= Core.ADDON_NAME then return end

    local modules = Core.Modules;

    if modules == nil then
        error("BetterTransmog initialization error: Core.Modules is nil — ensure all modules are registered and loaded before ADDON_LOADED")
    end

    modules.AccountDBModule:Initialize()
    modules.SettingsModule:Initialize();
    modules.TransmogFrameModule:Initialize();
end)