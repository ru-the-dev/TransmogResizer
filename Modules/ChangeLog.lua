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

local ChangeLogMixin = Core.Libs.LibRu.Frames.Mixins.ChangeLogFrameMixin;

--- ======================================================
--- Module Data
--- ======================================================

local CURRENT_VERSION = C_AddOns.GetAddOnMetadata(Core.Name, "Version")

CHANGELOG_ELEMENTS = {
    ['Version 2.0.4'] = {
        {type = 'heading', text = [[Version 2.0.4]], level = 1, indent_level = 0},
        {type = 'text', text = [[Quite a major update containing many requested features and improvements! As usual, thank you for your feedback and support and bug reports, if you have any, don't hesitate to open a issue on the github page!]], indent_level = 1},
        {type = 'heading', text = [[Added outfit swapping mode]], level = 2, indent_level = 1},
        {type = 'text', text = [[Added outfit swapping mode with expandible outfit prieview that you can open anywhere, anytime to change in between of, or look at - your saved outfits! ]], indent_level = 2},
        {type = 'image', path = [[Interface/AddOns/BetterTransmog/Assets/Screenshots/2.0.4_ChangeLog_OutfitSwapMode.png]], indent_level = 2},
        {type = 'text', text = [[You can access it with the new minimap button, or by using |cff0080ff/bt outfits|r|n|nSpecial thanks to: Smashbru, No-Geologist3092 and Bodehn for requesting this freature!]], indent_level = 2},
        {type = 'heading', text = [[Added BetterTransmog Minimap button]], level = 2, indent_level = 1},
        {type = 'text', text = [[Added a better transmog minimap button that lets:|n|n- [Left-Click] Open Outfit swapping panel |n|n- [Right-Click] Open BetterTransmog Settings Panel]], indent_level = 2},
        {type = 'image', path = [[Interface/AddOns/BetterTransmog/Assets/Screenshots/2.0.4_ChangeLog_MinimapButtonExample.png]], indent_level = 2},
        {type = 'heading', text = [[Added new /slashcommands and massively improved the /slashcommand system]], level = 2, indent_level = 1},
        {type = 'text', text = [[The new /slashcommand system supports aliasing, so you can write the same command in different ways. For example, you can use either |cff0080ff/bettertransmog|r or |cff0080ff/bt|r|n|nHere are the new /slashcommands:|n|n- |cff0080ff/bt|r or |cff0080ff/bt settings | options|r (opens settings panel)|n|n- |cff0080ff/bt outfits | outfit | fits|r (Opens the outfit swapping panel)|n|n- |cff0080ff/bt changelog | changes|r (Opens the changelog panel)|n|n- |cff0080ff/bt help|r (shows a list of the available commands)]], indent_level = 2},
        {type = 'text', text = [[a "|" means "OR", so for example |cff0080ff/bt settings|r and |cff0080ff/bt options|r both are the same command. ]], indent_level = 2},
        {type = 'heading', text = [[Improved frame position + size saving & restoring]], level = 2, indent_level = 1},
        {type = 'text', text = [[The transmog frame has 2 modes now.|n|n- Outfit swap |n|n- Regular|n|nPositions and sizes for these 2 modes are saved and restored seperately for your convenience!]], indent_level = 2},
        {type = 'heading', text = [[Improved changelog frame and system]], level = 2, indent_level = 1},
        {type = 'text', text = [[Made the changelog frame more user-friendly with better readability and smoother interactions, so you can enjoy reading about updates without any hassle!]], indent_level = 2},
        {type = 'heading', text = [[Added new buttons in the settings]], level = 2, indent_level = 1},
        {type = 'text', text = [[The bug/feedback button allows for copying a URL to the github issues page, which is the preferred place to give me feedback!]], indent_level = 2},
        {type = 'image', path = [[Interface/AddOns/BetterTransmog/Assets/Screenshots/2.0.4_SettingsButtons.png]], indent_level = 2},
        {type = 'heading', text = [[Codebase upgrades]], level = 2, indent_level = 1},
        {type = 'text', text = [[I won't bore you with the technical stuff, but under the hood, things are changing and improving! and if you are interested, you can always have a peek at the GitHub repo <3]], indent_level = 2},
    },
    ['Version 2.0.3'] = {
        {type = 'heading', text = [[Version 2.0.3]], level = 1, indent_level = 0},
        {type = 'heading', text = [[Fixed a bug causing a lua error in the Resizing Module]], level = 2, indent_level = 1},
        {type = 'text', text = [[Yep, gotta make sure we keep it clean and lua error free! 07]], indent_level = 2},
    },
    ['Version 2.0.2'] = {
        {type = 'heading', text = [[Version 2.0.2]], level = 1, indent_level = 0},
        {type = 'heading', text = [[Upgraded Module System]], level = 2, indent_level = 1},
        {type = 'text', text = [[Implemented a new module system supporting dependencies and submodules and slashcommands for better code organization and maintainability.]], indent_level = 2},
        {type = 'heading', text = [[Added ChangeLog Module]], level = 2, indent_level = 1},
        {type = 'text', text = [[Introduced a new ChangeLog module that displays version updates to users upon addon load.|r]], indent_level = 2},
        {type = 'heading', text = [[Added a /rl command. |r]], level = 2, indent_level = 1},
        {type = 'text', text = [[Added a shorthand way to /reload the ui with /rl (Request by F0ki & Jimbo) |r]], indent_level = 2},
    },
}

-- Group elements by version
local changelogData = CHANGELOG_ELEMENTS
local changeLogFrame = nil;



--- ======================================================
--- Module Functions
--- ======================================================

function Module:OnInitialize()
    local accountDB = accountDBModule.DB
    if accountDB.LastChangeLogVersion ~= CURRENT_VERSION then
        self:ShowChangeLog();
        accountDB.LastChangeLogVersion = CURRENT_VERSION
    end
end

---@param version string? Optional version to show changelog for, defaults to latest
function Module:ShowChangeLog(version)
    if not changeLogFrame then
        --- @type LibRu.Frames.Mixin.ChangeLogFrameMixin|Frame
        changeLogFrame = CreateFrame("Frame", "BetterTransmogChangeLogFrame", UIParent, "LibRu_ChangeLogFrameTemplate")
        changeLogFrame:Initialize(Core.Name, "Interface/AddOns/" .. Core.Name .. "/Assets/logo")

        -- Set changelog data
        changeLogFrame:SetChangeLogData(changelogData)
    end
    
    changeLogFrame:ShowVersion(version)
end
