-- Initialization and setup logic

_G.BetterTransmog = {};

--- @class LibRu
local LibRu = _G["LibRu"]

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end



-- Debug logging system
_G.BetterTransmog.Debug = true; -- Toggle this to enable/disable debug messages


function _G.BetterTransmog.DebugLog(message)
    if _G.BetterTransmog.Debug then
        print("|cff9f7fffBetterTransmog [DEBUG]:|r " .. tostring(message));
    end
end



-- Create a Global event frame
_G.BetterTransmog.EventFrame = LibRu.EventFrame.New(CreateFrame("Frame"));

-- _G.BetterTransmog.EventFrame:AddEvent("ADDON_LOADED", function (handle, event, addonName)
--     if addonName ~= "BetterTransmog" then return end;

--     _G.BetterTransmog.DebugLog("BetterTransmog initialized.");


--     -- Remove this event handler after initialization
--     _G.BetterTransmog.EventFrame:RemoveEvent(handle)
-- end)