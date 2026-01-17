-- Initialization and setup logic
--- @type LibRu
local LibRu = _G["LibRu"]

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end

---@class BetterTransmog : LibRu.Module
local Core = {
    ADDON_NAME = "BetterTransmog",
    LibRu = LibRu,
    Debug = true
}

-- Create a Global event frame
Core.EventFrame = LibRu.Frames.EventFrame.New(CreateFrame("Frame"));

if Core.Debug then
    Core.LibRu.Module.DebugFunc = function (message)
        print("|cff9f7fff" .. Core.ADDON_NAME .. " [DEBUG]:|r " .. tostring(message))
    end
end

Core.EventFrame:AddEvent("ADDON_LOADED", function (self, handle, event, addonName)
    if addonName ~= Core.ADDON_NAME then return end

    Core.Modules.AccountDB:Initialize();
    Core.Modules.Settings:Initialize();
    Core.Modules.TransmogFrame:Initialize();

    self:RemoveEvent(handle);
end)

_G.BetterTransmog = Core;