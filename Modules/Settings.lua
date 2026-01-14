---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
    return
end

Core.Modules = Core.Modules or {}


local Module = {}
Core.Modules.SettingsModule = Module;

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
    local panel = CreateFrame("Frame", "BetterTransmogOptionsPanel", UIParent)
    local accountDB = Core.DB.Account;

    panel.name = Core.ADDON_NAME

    local verticalSpacing = 40;

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("BetterTransmog Settings")

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Adjust layout and item grid sizes.")

    local s1 = Core.LibRu.Frames.ValueSlider.New(panel, "BetterTransmog_Slider_ModelWidth", "Model Width (% of frame):", 30, 50, 1, accountDB.TransmogFrame, "CharacterModelWidthPercent", function(v) return v .. "%" end)
    s1:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -verticalSpacing)
    s1:AddScript("OnValueChanged", function(self, handle, newValue)
        ShowReloadDialog()
    end)

    local s2 = Core.LibRu.Frames.ValueSlider.New(panel, "BetterTransmog_Slider_CollectionGrid", "Collection Grid Models:", 18, 50, 1, accountDB.TransmogFrame, "CollectionFrameModels")
    s2:SetPoint("TOPLEFT", s1, "BOTTOMLEFT", 0, -verticalSpacing)
    s2:AddScript("OnValueChanged", function(self, handle, newValue)
        ShowReloadDialog()
    end)

    local s3 = Core.LibRu.Frames.ValueSlider.New(panel, "BetterTransmog_Slider_SetGrid", "Set Grid Models:", 8, 18, 1, accountDB.TransmogFrame, "SetFrameModels")
    s3:SetPoint("TOPLEFT", s2, "BOTTOMLEFT", 0, -verticalSpacing)
    s3:AddScript("OnValueChanged", function(self, handle, newValue)
        ShowReloadDialog()
    end)

    local resetButton = CreateFrame("Button", "BetterTransmog_ResetButton", panel, "GameMenuButtonTemplate")
    resetButton:SetPoint("TOPLEFT", s3, "BOTTOMLEFT", 0, -verticalSpacing)
    resetButton:SetSize(100, 25)
    resetButton:SetText("Reset Settings")
    resetButton:SetScript("OnClick", function()
        accountDB:ResetSection({ "TransmogFrame" })
        ReloadUI()
    end)


    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
end


function Module:Initialize()
    _G.BetterTransmog.DebugLog("BetterTransmog settings panel initialized.")
    BuildPanel()
end

