-- Initialization and setup logic
--- @type LibRu
local LibRu = LibStub:GetLibrary("LibRu");

if not LibRu then
    error("BetterTransmog dependency missing: LibRu");
end

---@class BetterTransmog : LibRu.Module
---@field Modules {AccountDB: BetterTransmog.Modules.AccountDB, ChangeLog: BetterTransmog.Modules.ChangeLog, MinimapButton: BetterTransmog.Modules.MinimapButton, Settings: BetterTransmog.Modules.Settings, TransmogFrame: BetterTransmog.Modules.TransmogFrame}
local Core = LibRu.Module.New("BetterTransmog", nil, nil, true)

-- Register LibRu in Core for easy access
Core.Libs = {}
Core.Libs.LibRu = LibRu;

-- register default slash command
Core:RegisterSlashCommand("/bettertransmog", {
    ["default"] = function(msg, editbox)
        ---@type BetterTransmog.Modules.Settings
        local settingsModule = Core:GetModule("Settings");
        if settingsModule then
            settingsModule:OpenSettingsFrame();
        end
    end,
    ["settings"] = function(msg, editbox)
        ---@type BetterTransmog.Modules.Settings
        local settingsModule = Core:GetModule("Settings");
        if settingsModule then
            settingsModule:OpenSettingsFrame();
        end
    end,
    ["changelog"] = function(msg, editbox)
        ---@type BetterTransmog.Modules.ChangeLog
        local changeLogModule = Core:GetModule("ChangeLog");
        if changeLogModule then
            changeLogModule:ShowChangeLog();
        end
    end,
})

Core:RegisterSlashCommand("/rl", function (msg, editbox)
    Core:DebugLog("ReloadUI command executed via BetterTransmog.")
    ReloadUI()
end)

-- Create a Global event frame
Core.EventFrame = LibRu.Frames.EventFrame.New(CreateFrame("Frame"));

Core.EventFrame:AddEvent("ADDON_LOADED", function (self, handle, event, addonName)
    if addonName ~= Core:GetFullName() then return end

    --- Initialize the addon (core module and submodules)
    Core:Initialize();

    self:RemoveEvent(handle);
end)

_G.BetterTransmog = Core;

