---@class BetterTransmog
local Core = _G.BetterTransmog;

---@class BetterTransmog.Modules.ChangeLog : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "ChangeLog", 
    Core, 
    { 
        Core.Modules.AccountDB
    } 
)

--- ======================================================
--- Dependencies
--- ======================================================
---@type BetterTransmog.Modules.AccountDB
local accountDBModule = Core.Modules.AccountDB;

--- ======================================================
--- Module Data
--- ======================================================

local CURRENT_VERSION = C_AddOns.GetAddOnMetadata(Core.Name, "Version")

local CHANGELOG_TEXT = [[
|cffffd100Version 2.0.3|r

|cffffff00Fixed a bug causing a lua error in the Resizing Module|r

|cffffd100--------------------------|r

|cffffd100Version 2.0.2|r

|cffffff00Upgraded Module System|r
|cff888888Implemented a new module system supporting dependencies and submodules and slashcommands for better code organization and maintainability.|r

|cffffff00Added ChangeLog Module|r
|cff888888Introduced a new ChangeLog module that displays version updates to users upon addon load.|r

|cffffff00Added a /rl command. |r
|cff888888Added a shorthand way to /reload the ui with /rl (Request by F0ki & Jimbo) |r


|cffe34275Thank you so much for the positive reception to this new addon. Your feedback and feature requests are heard and expect these requested features soon! <3|r
]]

--- ======================================================
--- Module Functions
--- ======================================================

local function CreateChangeLogFrame()
    local frame = CreateFrame("Frame", "BetterTransmogChangeLogFrame", UIParent, "PortraitFrameTemplate")
    frame:SetSize(550, 450)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")

    -- Set portrait
    frame.PortraitContainer.portrait:SetTexture("Interface\\Icons\\INV_Enchant_Disenchant")

    -- Set title
    frame.TitleContainer.TitleText:SetText("BetterTransmog Changelog")

    -- Create scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -80)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -40, 50)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(480, 1000)
    scrollFrame:SetScrollChild(scrollChild)

    -- Create text
    local text = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("TOPLEFT", 10, -10)
    text:SetWidth(460)
    text:SetJustifyH("LEFT")
    text:SetText(CHANGELOG_TEXT)
    text:SetFont(STANDARD_TEXT_FONT, 12)

    -- Add a close button if not present
    if not frame.CloseButton then
        local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    end

    frame:Hide()
    return frame
end

local changeLogFrame

local function ShowChangeLog()
    if not changeLogFrame then
        changeLogFrame = CreateChangeLogFrame()
    end
    changeLogFrame:Show()
    local accountDB = accountDBModule.DB
    accountDB.LastChangeLogVersion = CURRENT_VERSION
end

function Module:OnInitialize()
    local accountDB = accountDBModule.DB
    if accountDB.LastChangeLogVersion ~= CURRENT_VERSION then
        ShowChangeLog()
    end
end

