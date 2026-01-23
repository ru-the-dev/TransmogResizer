-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.OutfitCollection : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "OutfitCollection", 
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
    ExpandedWidth = 312,
}

-- =======================================================
-- Module Implementation
-- =======================================================

local outfitCollectionCollapseButton = nil;

local function AddCollapseButton()
    outfitCollectionCollapseButton = Core.Libs.LibRu.Frames.CollapseExtendCheckButton.New(
        _G.TransmogFrame.CharacterPreview, 
        "OutfitCollectionCollapseExtendButton", 
        "bag-arrow", 
        30,
        true
    );

    _G.TransmogFrame.CharacterPreview.OutfitCollectionCollapseButton = outfitCollectionCollapseButton;

    outfitCollectionCollapseButton:SetPoint("TOPLEFT", outfitCollectionCollapseButton:GetParent(), "TOPLEFT", 5, -70)
    outfitCollectionCollapseButton:SetFrameStrata("DIALOG")

    outfitCollectionCollapseButton:AddScript("OnClick", function (self)
        local checked = self:GetChecked();
        local outfitCollectionFrame = _G.TransmogFrame.OutfitCollection;
        
        if (checked) then
            outfitCollectionFrame:Hide();
            outfitCollectionFrame:SetWidth(0.1);      
        else
            outfitCollectionFrame:SetWidth(Module.Settings.ExpandedWidth);
            outfitCollectionFrame:Show();
        end        
    end)
end

local function ApplyChanges()
    Module:DebugLog("Applying changes.")

    AddCollapseButton();
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