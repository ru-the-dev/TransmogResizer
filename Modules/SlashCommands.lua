-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.SlashCommands : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "SlashCommands",
    Core,
    {
        Core
    }
)

function Module:OnInitialize()
    local router = Core.Libs.LibRu.CommandRouter.New("BetterTransmog", { baseCommands = { "/bettertransmog", "/bt" } })

    local function OpenSettings()
        ---@type BetterTransmog.Modules.Settings
        local settingsModule = Core:GetModule("Settings");
        if settingsModule then
            settingsModule:OpenSettingsFrame();
        end
    end

    local function OpenChangeLog()
        ---@type BetterTransmog.Modules.ChangeLog
        local changeLogModule = Core:GetModule("ChangeLog");
        if changeLogModule then
            changeLogModule:ShowChangeLog();
        end
    end

    local function OpenOutfitMode()
        ---@type BetterTransmog.Modules.TransmogFrame
        local transmogFrameModule = Core:GetModule("TransmogFrame")
        if transmogFrameModule then
            transmogFrameModule:ToggleFrameInMode(transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP)
        end
    end

    local function PrintHelp()
        print("|cff00ccffBetterTransmog|r commands:")
        print("  /bt outfits | outfit | fits  - Open outfit swap mode")
        print("  /bt settings | options         - Open settings")
        print("  /bt changelog | changes         - Show changelog")
        print("  /bt help                       - Show this help")
    end

    router:SetDefault(function()
        OpenSettings()
    end)

    router:SetUnknown(function()
        PrintHelp()
    end)

    router:RegisterSubcommand("outfits", function()
        OpenOutfitMode()
    end, { aliases = { "outfit", "fits" } })

    router:RegisterSubcommand("settings", function()
        OpenSettings()
    end, { aliases = { "options" } })

    router:RegisterSubcommand("changelog", function()
        OpenChangeLog()
    end, { aliases = { "changes" } })

    router:RegisterSubcommand("help", function()
        PrintHelp()
    end)

    router:RegisterRootCommand("/rl", function()
        Core:DebugLog("ReloadUI command executed via BetterTransmog.")
        ReloadUI()
    end, { always = true })
end

return Module
