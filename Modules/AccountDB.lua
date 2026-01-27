-- SavedVariables: BetterTransmogAccountDB

---@class BetterTransmog
local Core = _G.BetterTransmog;


---@class BetterTransmog.Modules.AccountDB : LibRu.Module
local Module = Core.Libs.LibRu.Module.New("AccountDB", Core, { Core });

local DEFAULTS = {
    LastChangeLogVersion = "",
    MinimapButton = { -- for LibDbIcon
        hide = false
    },
    TransmogFrame = {
        CharacterPreviewFrameWidth = 450,
        CharacterPreviewCollapsedOutfit = false,
        FramePositionFull = {
            Point = "CENTER",
            RelativeTo = "UIParent",
            RelativePoint = "CENTER",
            OffsetX = 0,
            OffsetY = 0,
        },
        FramePositionOutfit = {
            Point = "CENTER",
            RelativeTo = "UIParent",
            RelativePoint = "CENTER",
            OffsetX = 0,
            OffsetY = 0,
        },
          FrameSizeFull = {
              Width = 1330,
              Height = 750,
          },
          FrameSizeOutfit = {
              Width = 762,
              Height = 750,
          }
    }
}

function Module:OnInitialize()
    local AccountDB = Core.Libs.LibRu.Utils.DB.CreateDatabase("BetterTransmogAccountDB", DEFAULTS)
    AccountDB:Init();

    Module.DB = AccountDB;

    self:DebugLog("AccountDB initialized.");
end
