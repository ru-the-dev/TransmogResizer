-- SavedVariables: BetterTransmogAccountDB

if not _G.BetterTransmog then error("Initialize first") end
if not _G.BetterTransmog.EventFrame then error("Initialize EventFrame first") end


local DEFAULTS = {
    TransmogFrame = {
        CharacterModelWidthPercent = 40,
        CollectionFrameModels      = 30,
        SetFrameModels             = 12,
    }
}

local AccountDB = NewDatabase("BetterTransmogAccountDB", DEFAULTS)

-- Ensure DB is populated with all needed fields on ADDON_LOADED
_G.BetterTransmog.EventFrame:AddEvent("ADDON_LOADED", function(handle, event, name)
    if name == "BetterTransmog" then
        -- Initialize the AccountDB
        local db = AccountDB:Init()
        _G.BetterTransmog.DebugLog("AccountDB initialized.")

        _G.BetterTransmog.EventFrame:FireScript("OnAccountDBInitialized");

        -- Remove this event handler after initialization
        _G.BetterTransmog.EventFrame:RemoveEvent(handle)
    end
end)


_G.BetterTransmog.DB = _G.BetterTransmog.DB or {}
_G.BetterTransmog.DB.Account = AccountDB  -- API methods (Init/Get/ResetAll/ResetSection/ResetValue)
_G.BetterTransmog.DB.Data = _G.BetterTransmogAccountDB  -- Direct access to saved variable data

