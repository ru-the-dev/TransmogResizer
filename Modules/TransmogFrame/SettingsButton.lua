-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;
--- @class BetterTransmog.Modules.TransmogFrame.SettingsButton : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "SettingsButton", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame 
    }
);

--- =======================================================
--- Dependencies
--- ======================================================
---@type BetterTransmog.Modules.TransmogFrame
local transmogFrameModule = Core.Modules.TransmogFrame;


--- =======================================================
-- Module Settings
-- =======================================================

Module.Settings = {

}


-- =======================================================
-- Module Implementation
-- =======================================================
function Module:OnInitialize()
    Module:DebugLog("Applying changes.")

    local transmogFrame = transmogFrameModule:GetFrame();

    local settingsButton = CreateFrame("Button", "BetterTransmog_TransmogFrame_SettingsButton", transmogFrame, "UIPanelButtonTemplate");
    settingsButton:SetPoint("RIGHT", transmogFrame.CloseButton, "LEFT", -2, 0);
    settingsButton:SetText("BT Settings");
    settingsButton:SetFrameStrata("HIGH");
    settingsButton:SetHeight(24);
    settingsButton:SetWidth(settingsButton:GetTextWidth() + 10)

    settingsButton:SetScript("OnClick", function()
        Core.Modules.Settings:OpenSettingsFrame()
    end)

    transmogFrame.BT_SettingsButton = settingsButton;
end