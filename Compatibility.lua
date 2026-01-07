if not _G.BetterTransmog then
    error("Addon must be initialized before loading compatibility checks.")
end

local function IsBetterWardrobeLoaded()
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded("BetterWardrobe")
    end

    if IsAddOnLoaded then
        return IsAddOnLoaded("BetterWardrobe")
    end

    return false
end

local function DisableBetterWardrobeAndReload()
    if C_AddOns and C_AddOns.DisableAddOn then
        C_AddOns.DisableAddOn("BetterWardrobe")
    elseif DisableAddOn then
        DisableAddOn("BetterWardrobe")
    end

    ReloadUI()
end

local incompatFrame
local function ShowBetterWardrobeIncompatFrame()
    if incompatFrame then
        incompatFrame:Show()
        return
    end

    incompatFrame = CreateFrame("Frame", "BetterTransmogIncompatFrame", UIParent, "BasicFrameTemplateWithInset")
    incompatFrame:SetSize(420, 180)
    incompatFrame:SetPoint("CENTER")
    incompatFrame:EnableMouse(true)
    incompatFrame:SetFrameStrata("DIALOG")

    if incompatFrame.TitleText then
        incompatFrame.TitleText:SetText("BetterTransmog Incompatible")
    end

    local message = incompatFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    message:SetPoint("TOP", 0, -40)
    message:SetWidth(380)
    message:SetJustifyH("CENTER")
    message:SetText("BetterTransmog is not compatible with BetterWardrobe. You can disable BetterWardrobe now to avoid conflicts.")

    local disableButton = CreateFrame("Button", nil, incompatFrame, "GameMenuButtonTemplate")
    disableButton:SetSize(140, 26)
    disableButton:SetPoint("BOTTOMLEFT", 20, 16)
    disableButton:SetText("Disable BetterWardrobe")
    disableButton:SetScript("OnClick", DisableBetterWardrobeAndReload)

    local cancelButton = CreateFrame("Button", nil, incompatFrame, "GameMenuButtonTemplate")
    cancelButton:SetSize(140, 26)
    cancelButton:SetPoint("BOTTOMRIGHT", -20, 16)
    cancelButton:SetText("Cancel")
    cancelButton:SetScript("OnClick", function()
        incompatFrame:Hide()
    end)
end

local function CheckCompatibility()
    if IsBetterWardrobeLoaded() then
        _G.BetterTransmog.DebugLog("BetterWardrobe detected; showing incompatibility dialog.")
        ShowBetterWardrobeIncompatFrame()
    end
end

CheckCompatibility()
