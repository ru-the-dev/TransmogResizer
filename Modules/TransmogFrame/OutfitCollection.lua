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
--- Locals
--- =======================================================
---@type BetterTransmog.Modules.TransmogFrame
local transmogFrameModule = Core.Modules.TransmogFrame;

local _outfitCollectionFrame = nil;


--- =======================================================
-- Module Settings
-- =======================================================
Module.Settings = {
    ExpandedWidth = 312,
    AnchorOffset = {
        Top = 21,
        Bottom = 2,
        Left = 2
    }
}

-- =======================================================
-- Module Implementation
-- =======================================================

local outfitCollectionCollapseButton = nil;

local function AddCollapseButton()
    local transmogFrame = transmogFrameModule:GetFrame();

    ---@class CharacterPreviewFrame : Frame
    local characterPreviewFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrame, "CharacterPreview");

    if (not transmogFrame or not characterPreviewFrame) then
        Module:DebugLog("TransmogFrame not found, cannot add OutfitCollection collapse button.");
        return
    end

    outfitCollectionCollapseButton = Core.Libs.LibRu.Frames.CollapseExtendCheckButton.New(
        characterPreviewFrame, 
        "OutfitCollectionCollapseExtendButton", 
        "bag-arrow", 
        30,
        true
    );

    
    characterPreviewFrame.OutfitCollectionCollapseButton = outfitCollectionCollapseButton;

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


---@param displayMode BetterTransmog.Modules.TransmogFrame.DisplayMode
local function OnTransmogFrameDisplayModeChanged(eventFrame, handle, displayMode)
    local transmogFrame = transmogFrameModule:GetFrame();
    local outfitCollectionFrame = Module:GetFrame();

    ---@type LibRu.Frames.CollapseExtendCheckButton
    local collapseButton = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrame, "CharacterPreview.OutfitCollectionCollapseButton");

    -- handle display mode change
    if displayMode == transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        --- disable collapse button
        collapseButton:SetCollapsed(false);
        collapseButton:Hide();
        collapseButton:Disable();

        -- hide purchase outfit button
        if outfitCollectionFrame.PurchaseOutfitButton then
            outfitCollectionFrame.PurchaseOutfitButton:Hide();
        end
        
        --- hide money frame
        if outfitCollectionFrame.MoneyFrame then
            outfitCollectionFrame.MoneyFrame:Hide();
        end

        -- hide save outfit button
        if outfitCollectionFrame.SaveOutfitButton then
            outfitCollectionFrame.SaveOutfitButton:Hide();
        end

        -- update anchors
        local outfitList = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(outfitCollectionFrame, "OutfitList")
        if outfitList then
            outfitList:SetPoint("BOTTOMLEFT", outfitCollectionFrame, "BOTTOMLEFT", 5, 10)
            outfitList:SetPoint("BOTTOMRIGHT", outfitCollectionFrame, "BOTTOMRIGHT", -5, 10)
        end

    elseif displayMode == transmogFrameModule.Enum.DISPLAY_MODE.FULL then
        collapseButton:Enable();
        collapseButton:Show();

        -- show purchase outfit button
        if outfitCollectionFrame.PurchaseOutfitButton then
            outfitCollectionFrame.PurchaseOutfitButton:Show();
        end

        --- show money frame
        if outfitCollectionFrame.MoneyFrame then
            outfitCollectionFrame.MoneyFrame:Show();
        end

        -- show save outfit button
        if outfitCollectionFrame.SaveOutfitButton then
            outfitCollectionFrame.SaveOutfitButton:Show();
        end

        -- update anchors
        local outfitList = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(outfitCollectionFrame, "OutfitList")
        if outfitList then
            outfitList:SetPoint("BOTTOMLEFT", outfitCollectionFrame, "BOTTOMLEFT", 5, 120)
            outfitList:SetPoint("BOTTOMRIGHT", outfitCollectionFrame, "BOTTOMRIGHT", -5, 120)
        end

        
    end
end 

function Module:OnInitialize()
    Module:DebugLog("Applying changes.")

    Module:FixAnchors();

    AddCollapseButton();
    
    Core.EventFrame:AddScript("OnTransmogFrameDisplayModeChanged", OnTransmogFrameDisplayModeChanged);
end

function Module:GetExpandedWidth()
    return Module.Settings.ExpandedWidth;
end

function Module:FixAnchors()
    local anchorOffset = self.Settings.AnchorOffset

    local outfitCollectionFrame = self:GetFrame();

    outfitCollectionFrame:ClearAllPoints()
    outfitCollectionFrame:SetPoint("TOPLEFT", transmogFrameModule:GetFrame(), "TOPLEFT", anchorOffset.Left, -anchorOffset.Top)
    outfitCollectionFrame:SetPoint("BOTTOMLEFT", transmogFrameModule:GetFrame(), "BOTTOMLEFT", anchorOffset.Left, anchorOffset.Bottom)

    local divider = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(outfitCollectionFrame, "DividerBar")
    if divider then
        divider:ClearAllPoints()
        divider:SetPoint("TOPRIGHT", 2, 0)
        divider:SetPoint("BOTTOMRIGHT", 2, 0)
    end

    local outfitList = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(outfitCollectionFrame, "OutfitList")
    if outfitList then
        outfitList:ClearAllPoints()
        outfitList:SetPoint("TOPLEFT", outfitCollectionFrame, "TOPLEFT", 5, -102)
        outfitList:SetPoint("BOTTOMLEFT", outfitCollectionFrame, "BOTTOMLEFT", 5, 120)
        outfitList:SetPoint("TOPRIGHT", outfitCollectionFrame, "TOPRIGHT", -5, -102)
        outfitList:SetPoint("BOTTOMRIGHT", outfitCollectionFrame, "BOTTOMRIGHT", -5, 120)
    end
end

function Module:GetFrame()
    if _outfitCollectionFrame then return _outfitCollectionFrame end;

    _outfitCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrameModule:GetFrame(), "OutfitCollection");
    
    if not _outfitCollectionFrame then
        error("OutfitCollection frame is not found. Is the frame available yet?")
    end

    return _outfitCollectionFrame
end