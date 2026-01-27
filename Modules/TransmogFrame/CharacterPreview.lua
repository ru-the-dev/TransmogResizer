-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.CharacterPreview : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "CharacterPreview", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame 
    }
);

Module.IsResetCameraHooked = false;


--- ======================================================
--- Locals 
--- ====================================================
---@type BetterTransmog.Modules.TransmogFrame
local transmogFrameModule = Core.Modules.TransmogFrame;
local _characterPreviewFrame = nil;

--- =======================================================
--- Module Settings
--- =======================================================

Module.Settings = {
    MinFrameWidth = 450,
    MaxFrameWidth = 900,
    MinCameraZoom = 2.5,
    MaxCameraZoom = 7.5,
    DefaultCameraZoom = 5.0,
    HiddenFrameWidth = 0.1,
    CollapseButton = {
        Size = 30,
        OffsetX = 5,
        OffsetY = -70,
        FrameStrata = "DIALOG",
    }
}

-- =======================================================
-- Module Implementation
-- =======================================================



local function CharacterPreviewFrame_FixCamera()
    local preview = Module:GetFrame()
    local modelScene = preview.ModelScene
    local camera = modelScene:GetActiveCamera();

    if (not camera) then
        Module:DebugLog("No active camera found in CharacterPreview ModelScene.");
        return
    end

    camera:SetMinZoomDistance(Module.Settings.MinCameraZoom); 
    camera:SetMaxZoomDistance(Module.Settings.MaxCameraZoom);

    -- Set the current zoom to a reasonable default
    camera:SetZoomDistance(Module.Settings.DefaultCameraZoom);
end

local function CharacterPreviewFrame_HookReset()
    if Module.IsResetCameraHooked then return end;

    -- Hook the Reset method to reapply camera settings after reset
    local preview = Module:GetFrame()
    local modelScene = preview.ModelScene

    hooksecurefunc(modelScene, "Reset", function()
        CharacterPreviewFrame_FixCamera()
    end)

    Module.IsResetCameraHooked = true;
end

local function CharacterPreviewFrame_UpdateWidth()

    local accountDB = Core.Modules.AccountDB.DB;
    local preview = Module:GetFrame()

    local clampedWidth = math.min(
        math.max(
            accountDB.TransmogFrame.CharacterPreviewFrameWidth,
            Module.Settings.MinFrameWidth
        ),
        Module.Settings.MaxFrameWidth
    )

    Module:DebugLog("Setting CharacterPreview frame width to " .. clampedWidth)

    preview:SetWidth(clampedWidth)
    return clampedWidth
end

local function SetSlotButtonsVisible(visible)
    local preview = Module:GetFrame()
    if preview.BottomSlots then
        if visible then
            preview.BottomSlots:Show()
        else
            preview.BottomSlots:Hide()
        end
    end
    if preview.LeftSlots then
        if visible then
            preview.LeftSlots:Show()
        else
            preview.LeftSlots:Hide()
        end
    end
    if preview.RightSlots then
        if visible then
            preview.RightSlots:Show()
        else
            preview.RightSlots:Hide()
        end
    end
end

local previewCollapseButton = nil

local function GetOutfitCollectionWidth()
    local outfitCollection = transmogFrameModule:GetModule("OutfitCollection")
    if outfitCollection and outfitCollection.GetExpandedWidth then
        return outfitCollection:GetExpandedWidth()
    end

    local outfitCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
        transmogFrameModule:GetFrame(),
        "OutfitCollection"
    )

    return outfitCollectionFrame and outfitCollectionFrame:GetWidth() or 0
end

local function ApplyOutfitSwapResizeBounds(previewWidth)
    local outfitWidth = GetOutfitCollectionWidth()
    local totalWidth = outfitWidth + (previewWidth or 0)

    if totalWidth > 0 then
        transmogFrameModule:SetMinFrameWidth(totalWidth)
        transmogFrameModule:SetMaxFrameWidth(totalWidth)
    end
end

local function SetPreviewCollapsed(collapsed)
    local preview = Module:GetFrame()

    Core.Modules.AccountDB.DB.TransmogFrame.CharacterPreviewCollapsedOutfit = collapsed and true or false

    if collapsed then
        preview:Hide()
        preview:SetWidth(Module.Settings.HiddenFrameWidth)
        ApplyOutfitSwapResizeBounds(0)
        return
    end

    preview:Show()
    local width = CharacterPreviewFrame_UpdateWidth()
    ApplyOutfitSwapResizeBounds(width)
end

local function AddCollapseButton()
    local transmogFrame = transmogFrameModule:GetFrame();
    local characterPreviewFrame = Module:GetFrame();
    local outfitCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
        transmogFrame,
        "OutfitCollection"
    )

    if (not transmogFrame or not characterPreviewFrame or not outfitCollectionFrame) then
        Module:DebugLog("TransmogFrame not found, cannot add CharacterPreview collapse button.")
        return
    end

    previewCollapseButton = Core.Libs.LibRu.Frames.CollapseExtendCheckButton.New(
        outfitCollectionFrame,
        "CharacterPreviewCollapseExtendButton",
        "bag-arrow",
        Module.Settings.CollapseButton.Size,
        true
    )

    characterPreviewFrame.CharacterPreviewCollapseButton = previewCollapseButton
    outfitCollectionFrame.CharacterPreviewCollapseButton = previewCollapseButton

        previewCollapseButton:SetPoint(
            "TOPRIGHT",
            previewCollapseButton:GetParent(),
            "TOPRIGHT",
            -Module.Settings.CollapseButton.OffsetX,
            Module.Settings.CollapseButton.OffsetY
        )
    previewCollapseButton:SetFrameStrata(Module.Settings.CollapseButton.FrameStrata)

    previewCollapseButton:AddScript("OnClick", function(self)
        local checked = self:GetChecked();

        SetPreviewCollapsed(checked)
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

    local characterPreviewFrame = Module:GetFrame();
    if not characterPreviewFrame then
        Module:DebugLog("characterPreviewFrame frame not found, cannot adjust for display mode change.");
        return
    end

    if displayMode == transmogFrameModule.Enum.DISPLAY_MODE.FULL then
        characterPreviewFrame:Show();
        CharacterPreviewFrame_UpdateWidth();
        SetSlotButtonsVisible(true)

        if characterPreviewFrame.HideIgnoredToggle then
            characterPreviewFrame.HideIgnoredToggle:Show()
        end

        if characterPreviewFrame.CharacterPreviewCollapseButton then
            characterPreviewFrame.CharacterPreviewCollapseButton:Hide();
            characterPreviewFrame.CharacterPreviewCollapseButton:Disable();
        end
    elseif displayMode == transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        Module:DebugLog("Showing characterPreviewFrame frame for OUTFIT_SWAP display mode.");
        characterPreviewFrame:Show();
        SetSlotButtonsVisible(false)

        if characterPreviewFrame.HideIgnoredToggle then
            characterPreviewFrame.HideIgnoredToggle:Hide()
        end

        if characterPreviewFrame.CharacterPreviewCollapseButton then
                local collapsed = Core.Modules.AccountDB.DB.TransmogFrame.CharacterPreviewCollapsedOutfit
                characterPreviewFrame.CharacterPreviewCollapseButton:SetCollapsed(collapsed)
            characterPreviewFrame.CharacterPreviewCollapseButton:Show();
            characterPreviewFrame.CharacterPreviewCollapseButton:Enable();
        end

        local collapsed = Core.Modules.AccountDB.DB.TransmogFrame.CharacterPreviewCollapsedOutfit
        SetPreviewCollapsed(collapsed)
    end
end

function Module:OnInitialize()
    Module:DebugLog("Applying changes.")

    Module:FixAnchors();
    
    CharacterPreviewFrame_HookReset();
    CharacterPreviewFrame_UpdateWidth();

    AddCollapseButton();

    -- hook on show, fix camera every time, show resets the camera settings
    transmogFrameModule:GetFrame():HookScript("OnShow", function(self)
        CharacterPreviewFrame_FixCamera();
    end)

    Core.EventFrame:AddScript("OnTransmogFrameDisplayModeChanged", ApplyDisplayMode)
end


function Module:FixAnchors()
    local outfitCollectionModule = transmogFrameModule:GetModule("OutfitCollection");
    local outfitCollectionFrame = nil;

    if outfitCollectionModule then
        outfitCollectionFrame = outfitCollectionModule:GetFrame();
    else
        outfitCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
            transmogFrameModule:GetFrame(),
            "OutfitCollection"
        );
    end

    local characterPreviewFrame = Module:GetFrame();

    Module:DebugLog(outfitCollectionFrame)
    characterPreviewFrame:ClearAllPoints()
    characterPreviewFrame:SetPoint("TOPLEFT", outfitCollectionFrame, "TOPRIGHT")
    characterPreviewFrame:SetPoint("BOTTOMLEFT", outfitCollectionFrame, "BOTTOMRIGHT")

    local bg = characterPreviewFrame.Background
    bg:SetAllPoints(characterPreviewFrame)

    characterPreviewFrame.Gradients.GradientLeft:SetPoint("TOPLEFT", characterPreviewFrame)
    characterPreviewFrame.Gradients.GradientLeft:SetPoint("BOTTOMLEFT", characterPreviewFrame)

    characterPreviewFrame.Gradients.GradientRight:SetPoint("TOPRIGHT", characterPreviewFrame)
    characterPreviewFrame.Gradients.GradientRight:SetPoint("BOTTOMRIGHT", characterPreviewFrame)
end

function Module:GetFrame()
    if _characterPreviewFrame then return _characterPreviewFrame end;

    _characterPreviewFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrameModule:GetFrame(), "CharacterPreview");
    
    if not _characterPreviewFrame then
        error("CharacterPreview frame is not found. Is the frame available yet?")
    end

    return _characterPreviewFrame
end