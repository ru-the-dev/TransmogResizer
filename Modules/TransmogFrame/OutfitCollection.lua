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
    HiddenFrameWidth = 0.1,
    OutfitListOffsets = {
        Compact = 10,
        Full = 120,
    },
    OutfitListInsets = {
        Left = 5,
        Right = 5,
    },
    OutfitListTopOffset = -102,
    CollapseButton = {
        Size = 30,
        OffsetX = 5,
        OffsetY = -70,
        FrameStrata = "DIALOG",
    },
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
        Module.Settings.CollapseButton.Size,
        true
    );

    
    characterPreviewFrame.OutfitCollectionCollapseButton = outfitCollectionCollapseButton;

    outfitCollectionCollapseButton:SetPoint(
        "TOPLEFT",
        outfitCollectionCollapseButton:GetParent(),
        "TOPLEFT",
        Module.Settings.CollapseButton.OffsetX,
        Module.Settings.CollapseButton.OffsetY
    )
    outfitCollectionCollapseButton:SetFrameStrata(Module.Settings.CollapseButton.FrameStrata)

    outfitCollectionCollapseButton:AddScript("OnClick", function (self)
        local checked = self:GetChecked();
        local outfitCollectionFrame = _G.TransmogFrame.OutfitCollection;
        
        if (checked) then
            outfitCollectionFrame:Hide();
            outfitCollectionFrame:SetWidth(Module.Settings.HiddenFrameWidth);
        else
            outfitCollectionFrame:SetWidth(Module.Settings.ExpandedWidth);
            outfitCollectionFrame:Show();
        end        
    end)
end


---@param eventFrame Frame
---@param handle any
---@param displayMode string
local function ApplyDisplayMode(eventFrame, handle, displayMode)
    if not transmogFrameModule:IsValidDisplayMode(displayMode) then
        Module:DebugLog("UnimplmentedDisplayMode: " .. tostring(displayMode))
        return
    end

    local transmogFrame = transmogFrameModule:GetFrame();
    local outfitCollectionFrame = Module:GetFrame();

    ---@type LibRu.Frames.CollapseExtendCheckButton
    local collapseButton = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrame, "CharacterPreview.OutfitCollectionCollapseButton");

    if displayMode == transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        if collapseButton then
            collapseButton:SetCollapsed(false);
            collapseButton:Hide();
            collapseButton:Disable();
        end

        if outfitCollectionFrame.PurchaseOutfitButton then
            outfitCollectionFrame.PurchaseOutfitButton:Hide();
        end
        
        if outfitCollectionFrame.MoneyFrame then
            outfitCollectionFrame.MoneyFrame:Hide();
        end

        if outfitCollectionFrame.SaveOutfitButton then
            outfitCollectionFrame.SaveOutfitButton:Hide();
        end

        local outfitList = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(outfitCollectionFrame, "OutfitList")
        if outfitList then
            local offset = Module.Settings.OutfitListOffsets.Compact
            local insetLeft = Module.Settings.OutfitListInsets.Left
            local insetRight = Module.Settings.OutfitListInsets.Right
            outfitList:SetPoint("BOTTOMLEFT", outfitCollectionFrame, "BOTTOMLEFT", insetLeft, offset)
            outfitList:SetPoint("BOTTOMRIGHT", outfitCollectionFrame, "BOTTOMRIGHT", -insetRight, offset)
        end

    elseif displayMode == transmogFrameModule.Enum.DISPLAY_MODE.FULL then
        if collapseButton then
            collapseButton:Enable();
            collapseButton:Show();
        end

        if outfitCollectionFrame.PurchaseOutfitButton then
            outfitCollectionFrame.PurchaseOutfitButton:Show();
        end

        if outfitCollectionFrame.MoneyFrame then
            outfitCollectionFrame.MoneyFrame:Show();
        end

        if outfitCollectionFrame.SaveOutfitButton then
            outfitCollectionFrame.SaveOutfitButton:Show();
        end

        local outfitList = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(outfitCollectionFrame, "OutfitList")
        if outfitList then
            local offset = Module.Settings.OutfitListOffsets.Full
            local insetLeft = Module.Settings.OutfitListInsets.Left
            local insetRight = Module.Settings.OutfitListInsets.Right
            outfitList:SetPoint("BOTTOMLEFT", outfitCollectionFrame, "BOTTOMLEFT", insetLeft, offset)
            outfitList:SetPoint("BOTTOMRIGHT", outfitCollectionFrame, "BOTTOMRIGHT", -insetRight, offset)
        end
    end
end

function Module:OnInitialize()
    Module:DebugLog("Applying changes.")

    Module:FixAnchors();

    AddCollapseButton();

    Core.EventFrame:AddScript("OnTransmogFrameDisplayModeChanged", ApplyDisplayMode)
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
        local insetLeft = Module.Settings.OutfitListInsets.Left
        local insetRight = Module.Settings.OutfitListInsets.Right
        local topOffset = Module.Settings.OutfitListTopOffset
        local bottomOffset = Module.Settings.OutfitListOffsets.Full
        outfitList:ClearAllPoints()
        outfitList:SetPoint("TOPLEFT", outfitCollectionFrame, "TOPLEFT", insetLeft, topOffset)
        outfitList:SetPoint("BOTTOMLEFT", outfitCollectionFrame, "BOTTOMLEFT", insetLeft, bottomOffset)
        outfitList:SetPoint("TOPRIGHT", outfitCollectionFrame, "TOPRIGHT", -insetRight, topOffset)
        outfitList:SetPoint("BOTTOMRIGHT", outfitCollectionFrame, "BOTTOMRIGHT", -insetRight, bottomOffset)
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