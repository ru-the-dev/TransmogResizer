-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized. Please ensure Core.lua is loaded first.")
    return
end

--- @class BetterTransmog.Modules.TransmogFrame.SettingsButton : LibRu.Module
local Module = Core.LibRu.Module.New("TransmogFrame.SettingsButton");

Core.Modules = Core.Modules or {};

---@class BetterTransmog.Modules.TransmogFrame: LibRu.Module
local TransmogFrameModule = Core.Modules.TransmogFrame;

if not TransmogFrameModule then
    error(Module.Name .. " module requires TransmogFrame module to be loaded first.")
    return;
end


Module.Settings = {

}


TransmogFrameModule.SettingsButton = Module;


-- =======================================================
-- Module Implementation
-- =======================================================

local function ApplyChanges()
    Module:DebugLog("Applying changes.")

    local settingsButton = CreateFrame("Button", "BetterTransmog_TransmogFrame_SettingsButton", _G.TransmogFrame, "UIPanelButtonTemplate");
    settingsButton:SetPoint("RIGHT", _G.TransmogFrame.CloseButton, "LEFT", -2, 0);
    settingsButton:SetText("BT Settings");
    settingsButton:SetFrameStrata("HIGH");
    settingsButton:SetHeight(24);
    settingsButton:SetWidth(settingsButton:GetTextWidth() + 10)

    settingsButton:SetScript("OnClick", function()
        Core.Modules.Settings:OpenSettingsFrame()
    end)

    _G.TransmogFrame.BetterTransmogSettingsButton = settingsButton;

end

function Module:OnInitialize()
    Core.EventFrame:AddEvent(
        "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
        function(self, handle, _, frameId)
            if frameId ~= TransmogFrameModule.Settings.TRANSMOG_FRAME_ID then return end
            ApplyChanges()
            self:RemoveEvent(handle)
        end
    )
end