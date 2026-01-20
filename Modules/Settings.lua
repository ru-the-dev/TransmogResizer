---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
    return
end

Core.Modules = Core.Modules or {};

if not Core.Modules.AccountDB then
    error("Settings module requires AccountDB module to be loaded first.")
    return
end

---@class BetterTransmog.Modules.Settings : LibRu.Module
local Module = Core.LibRu.Module.New("Settings");

Core.Modules.Settings = Module;



-- Track if a reload dialog is already shown
local reloadDialogShown = false

--- Shows a dialog prompting the user to reload the UI
local function ShowReloadDialog()
    if reloadDialogShown then return end
    reloadDialogShown = true
    
    StaticPopup_Show("BETTERTRANSMOG_RELOAD_UI")
end

--- Register the reload UI popup
StaticPopupDialogs["BETTERTRANSMOG_RELOAD_UI"] = {
    text = "BetterTransmog settings have been changed. Reload the UI now to apply your changes?",
    button1 = "Reload",
    button2 = "Later",
    OnAccept = function()
        ReloadUI()
    end,
    OnCancel = function()
        reloadDialogShown = false
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}


local function BuildPanel()
    local accountDB = Core.Modules.AccountDB.DB;
    local characterPreviewModule = Core.Modules.TransmogFrame.CharacterPreview;

    local panel = CreateFrame("Frame", "BetterTransmogOptionsPanel", UIParent)

    panel.name = Core.ADDON_NAME

    local verticalSpacing = 40;

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("BetterTransmog Settings")

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Adjust layout and item grid sizes.")

    local previewFrameWidthSlider = Core.LibRu.Frames.ValueSlider.New(panel, "BetterTransmog_Slider_PreviewFrameWidth", "Preview Frame Width:", characterPreviewModule.Settings.MinFrameWidth, characterPreviewModule.Settings.MaxFrameWidth, 10, accountDB.TransmogFrame, "CharacterPreviewFrameWidth", function(v) return v .. "px" end)
    previewFrameWidthSlider:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -verticalSpacing)
    previewFrameWidthSlider:AddScript("OnValueChanged", function(self, handle, newValue)
        ShowReloadDialog()
    end)


    local resetButton = CreateFrame("Button", "BetterTransmog_ResetButton", panel, "GameMenuButtonTemplate")
    resetButton:SetPoint("TOPLEFT", previewFrameWidthSlider, "BOTTOMLEFT", 0, -verticalSpacing)
    resetButton:SetSize(100, 25)
    resetButton:SetText("Reset Settings")
    resetButton:SetScript("OnClick", function()
        accountDB:ResetSection({ "TransmogFrame" })
        ReloadUI()
    end)

    
    Module.SettingsCategory = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(Module.SettingsCategory)
end


function Module:OpenSettingsFrame()
    Settings.OpenToCategory(Module.SettingsCategory:GetID())
end

function Module:OnInitialize()
    BuildPanel()
end

