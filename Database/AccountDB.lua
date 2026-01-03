-- SavedVariables: TransmogResizerAccountDB

if not _G.TransmogResize then error("Initialize first") end
if not _G.TransmogResize.EventFrame then error("Initialize EventFrame first") end


local DEFAULTS = {
    TransmogFrame = {
        CharacterModelWidthPercent = 40,
        CollectionFrameModels      = 30,
        SetFrameModels             = 12,
    },
}

local AccountDB = NewDatabase("TransmogResizerAccountDB", DEFAULTS)

-- Ensure DB is populated with all needed fields on ADDON_LOADED
_G.TransmogResize.EventFrame:AddEvent("ADDON_LOADED", function(handle, event, name)
    if name == "TransmogResizer" then
        -- Initialize the AccountDB
        AccountDB:Init()

        -- Remove this event handler after initialization
        _G.TransmogResize.EventFrame:RemoveEvent(handle)
    end
end)

_G.TransmogResize.DB = _G.TransmogResize.DB or {}
_G.TransmogResize.DB.Account = AccountDB  -- data + methods (Init/Get/ResetAll/ResetSection/ResetValue)

