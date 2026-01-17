-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
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

}

TransmogFrameModule.OutfitCollection = Module;

-- =======================================================
-- Module Implementation
-- =======================================================

-- Toggle function
local function TogglePanel()
    -- button.isCollapsed = not button.isCollapsed
    -- if button.isCollapsed then
    --     panelFrame:SetHeight(30)  -- Collapsed height (e.g., header only)
    --     button.texture:SetTexCoord(0, 0.5, 0, 1)  -- Rotate or change texture for expand state
    -- else
    --     panelFrame:SetHeight(200)  -- Expanded height
    --     button.texture:SetTexCoord(0.5, 1, 0, 1)  -- Original texture for collapse state
    -- end
end

local function AddCollapseButton()

    

    local collapseButton = Core.LibRu.Frames.CollapseExtendCheckButton.New(
        _G.TransmogFrame.CharacterPreview, 
        "OutfitCollectionCollapseExtendButton", 
        "bag-arrow", 
        30,
        true
    );

    _G.TransmogFrame.CharacterPreview.OutfitCollectionCollapseButton = collapseButton;

    collapseButton:SetPoint("TOPLEFT", collapseButton:GetParent(), "TOPLEFT", 5, -80)
    collapseButton:SetFrameStrata("DIALOG")

    collapseButton:AddScript("OnClick", function (self)
        local checked = self:GetChecked();
        local outfitCollectionFrame = _G.TransmogFrame.OutfitCollection;
        
        if (checked) then
            outfitCollectionFrame:SetWidth(0.1);      
            outfitCollectionFrame:Hide();
        else
            outfitCollectionFrame:SetWidth(312);
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