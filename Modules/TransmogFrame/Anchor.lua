-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.Anchor : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "Anchor", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame 
    }
);
--- ======================================================
--- Dependencies
--- ======================================================
---@type BetterTransmog.Modules.TransmogFrame
local transmogFrameModule = Core.Modules.TransmogFrame;

--- =======================================================
--- Module Settings
--- =======================================================
Module.Settings = {
    OutfitCollectionFrame = {
        AnchorOffset = {
            Top = 21,
            Bottom = 2,
            Left = 2
        }
    },
    WardrobeCollectionFrame = {
        TabContentFrame = {
            BackgroundPadding = {
                Top = 0,
                Bottom = 10,
                Left = 0,
                Right = 10,
            },
            BorderPadding = {
                Top = -14,
                Bottom = -5,
                Left = -12,
                Right = -3,
            }
        }
    }
}




-- =======================================================
-- Module Implementation
-- =======================================================

local function OutfitCollectionFrame_FixAnchors()
    local frame = _G.TransmogFrame.OutfitCollection
    local s = Module.Settings.OutfitCollectionFrame.AnchorOffset

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", _G.TransmogFrame, "TOPLEFT", s.Left, -s.Top)
    frame:SetPoint("BOTTOMLEFT", _G.TransmogFrame, "BOTTOMLEFT", s.Left, s.Bottom)

    local divider = frame.DividerBar
    divider:ClearAllPoints()
    divider:SetPoint("TOPRIGHT", 2, 0)
    divider:SetPoint("BOTTOMRIGHT", 2, 0)

    local list = frame.OutfitList
    list:ClearAllPoints()
    list:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -102)
    list:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 120)
    list:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -102)
    list:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 120)
end


local function CharacterPreviewFrame_FixAnchors()
    local preview = _G.TransmogFrame.CharacterPreview
    local outfit = _G.TransmogFrame.OutfitCollection

    preview:ClearAllPoints()
    preview:SetPoint("TOPLEFT", outfit, "TOPRIGHT")
    preview:SetPoint("BOTTOMLEFT", outfit, "BOTTOMRIGHT")

    local bg = preview.Background
    bg:SetAllPoints(preview)

    preview.Gradients.GradientLeft:SetPoint("TOPLEFT", preview)
    preview.Gradients.GradientLeft:SetPoint("BOTTOMLEFT", preview)

    preview.Gradients.GradientRight:SetPoint("TOPRIGHT", preview)
    preview.Gradients.GradientRight:SetPoint("BOTTOMRIGHT", preview)
end


local function WardrobeCollectionFrame_FixAnchors()
    local frame = _G.TransmogFrame.WardrobeCollection
    local preview = _G.TransmogFrame.CharacterPreview

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", preview, "TOPRIGHT")
    frame:SetPoint("BOTTOMLEFT", preview, "BOTTOMRIGHT")
    frame:SetPoint("TOPRIGHT", _G.TransmogFrame, "TOPRIGHT", 0, -Module.Settings.OutfitCollectionFrame.AnchorOffset.Top)
    frame:SetPoint("BOTTOMRIGHT", _G.TransmogFrame, "BOTTOMRIGHT")

    local tabContent = frame.TabContent
    tabContent:ClearAllPoints()
    tabContent:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -35)
    tabContent:SetPoint("BOTTOMRIGHT", frame)

    local bg = tabContent.Background
    local bp = Module.Settings.WardrobeCollectionFrame.TabContentFrame.BackgroundPadding
    bg:SetPoint("TOPLEFT", tabContent, bp.Left, -bp.Top)
    bg:SetPoint("BOTTOMRIGHT", tabContent, -bp.Right, bp.Bottom)

    local border = tabContent.Border
    local bp2 = Module.Settings.WardrobeCollectionFrame.TabContentFrame.BorderPadding
    border:SetPoint("TOPLEFT", tabContent, bp2.Left, -bp2.Top)
    border:SetPoint("BOTTOMRIGHT", tabContent, -bp2.Right, bp2.Bottom)
end

local function FixAnchors()
    OutfitCollectionFrame_FixAnchors()
    CharacterPreviewFrame_FixAnchors()
    WardrobeCollectionFrame_FixAnchors()
end



local function ApplyChanges()
    Module:DebugLog("Applying changes.")

    FixAnchors()
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