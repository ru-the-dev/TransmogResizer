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
            if frameId ~= transmogFrameModule.Settings.TRANSMOG_FRAME_ID then return end
            ApplyChanges()
            self:RemoveEvent(handle)
        end
    )
end