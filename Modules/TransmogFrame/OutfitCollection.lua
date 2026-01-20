-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized. Please ensure Core.lua is loaded first.")
    return
end

--- @class BetterTransmog.Modules.TransmogFrame.OutfitCollection : LibRu.Module
local Module = Core.LibRu.Module.New("TransmogFrame.OutfitCollection");

Core.Modules = Core.Modules or {};

---@class BetterTransmog.Modules.TransmogFrame: LibRu.Module
local TransmogFrameModule = Core.Modules.TransmogFrame;

if not TransmogFrameModule then
    error(Module.Name .. " module requires TransmogFrame module to be loaded first.")
    return;
end



Module.Settings = {
    ExpandedWidth = 312,
}

TransmogFrameModule.OutfitCollection = Module;

-- =======================================================
-- Module Implementation
-- =======================================================

local outfitCollectionCollapseButton = nil;

local function AddCollapseButton()
    outfitCollectionCollapseButton = Core.LibRu.Frames.CollapseExtendCheckButton.New(
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
            if frameId ~= TransmogFrameModule.Settings.TRANSMOG_FRAME_ID then return end
            ApplyChanges()
            self:RemoveEvent(handle)
        end
    )
end