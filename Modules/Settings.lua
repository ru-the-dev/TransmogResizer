---@class BetterTransmog
local Core = _G.BetterTransmog;

---@class BetterTransmog.Modules.Settings : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "Settings", 
    Core, 
    { 
        Core.Modules.AccountDB, 
        Core.Modules.TransmogFrame.CharacterPreview 
    } 
)

--- ======================================================
--- Dependencies
--- ======================================================
---@type BetterTransmog.Modules.AccountDB
local accountDBModule = Core.Modules.AccountDB;

---@type BetterTransmog.Modules.TransmogFrame.CharacterPreview
local characterPreviewModule = Core.Modules.TransmogFrame.Modules.CharacterPreview;

--- =======================================================
--- Module Settings
--- =======================================================;



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
    local accountDB = accountDBModule.DB;

    local panel = CreateFrame("Frame", "BetterTransmogOptionsPanel", UIParent)

    panel.name = Core.Name

    local verticalSpacing = 40;

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("BetterTransmog Settings")

    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Adjust layout and behavior settings for BetterTransmog.")

    local previewFrameWidthSlider = Core.Libs.LibRu.Frames.ValueSlider.New(panel, "BetterTransmog_Slider_PreviewFrameWidth", "Preview Frame Width:", characterPreviewModule.Settings.MinFrameWidth, characterPreviewModule.Settings.MaxFrameWidth, 10, accountDB.TransmogFrame, "CharacterPreviewFrameWidth", function(v) return v .. "px" end)
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

    local footer = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    footer:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
    footer:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)
    footer:SetJustifyH("LEFT")
    footer:SetJustifyV("BOTTOM")
    footer:SetWordWrap(true)
    footer:SetNonSpaceWrap(true)
    -- Provide a reasonable default width; it'll be adjusted when the panel is sized
    footer:SetWidth(400)
    -- Set a pleasant base color for the footer text
    footer:SetTextColor(0.78, 0.85, 0.95)
    -- Increase font size for better readability
    footer:SetFont(STANDARD_TEXT_FONT, 13)
    -- Highlight the author name in a contrasting color using WoW color escape codes
    local authorName = "|cff00ffd0ru_the_dev|r"
    footer:SetText("Made with love by " .. authorName .. " (Pookie). Any feedback, feature suggestions, addon compatibility reports and donations are welcome <3")

    -- Update the footer width whenever the panel size changes so wrapping works correctly
    panel:HookScript("OnSizeChanged", function(self, width, height)
        footer:SetWidth(math.max(100, width - 32))
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

