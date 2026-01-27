-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.WardrobeCollection : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "WardrobeCollection", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame 
    }
);

--- =======================================================
--- Dependencies
--- ======================================================
local transmogFrameModule = Core.Modules.TransmogFrame;

--- =======================================================
--- Locals
--- =====================================================
local _wardrobeCollectionFrame = nil;

--- =======================================================
-- Module Settings
-- =======================================================
Module.Settings = {
    MinFrameWidth = 450,
    SituationsTabMinWidth = 630,
    TabContentOffsets = {
        Left = 0,
        Top = -35,
        Right = 0,
        Bottom = 0,
    },
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

-- =======================================================
-- Module Implementation
-- =======================================================


---@param eventFrame Frame
---@param handle any
---@param displayMode string
local function ApplyDisplayMode(eventFrame, handle, displayMode)
    if not transmogFrameModule:IsValidDisplayMode(displayMode) then
        Module:DebugLog("UnimplmentedDisplayMode: " .. tostring(displayMode))
        return
    end

    local wardrobeCollectionFrame = Module:GetFrame();
    if not wardrobeCollectionFrame then
        Module:DebugLog("WardrobeCollection frame not found, cannot adjust for display mode change.");
        return
    end

    if displayMode == transmogFrameModule.Enum.DISPLAY_MODE.FULL then
        wardrobeCollectionFrame:Show();

        if wardrobeCollectionFrame.SetToDefaultAvailableTab then
            wardrobeCollectionFrame:SetToDefaultAvailableTab();
        end

        local tabContent = wardrobeCollectionFrame.TabContent
        if tabContent then
            local function RefreshFrame(frame)
                if frame and frame.Refresh then
                    frame:Refresh();
                elseif frame and frame.RefreshCollectionEntries then
                    frame:RefreshCollectionEntries();
                end
            end

            RefreshFrame(tabContent.ItemsFrame)
            RefreshFrame(tabContent.SetsFrame)
            RefreshFrame(tabContent.CustomSetsFrame)

            C_Timer.After(0, function()
                RefreshFrame(tabContent.ItemsFrame)
                RefreshFrame(tabContent.SetsFrame)
                RefreshFrame(tabContent.CustomSetsFrame)
            end)
        end

        if _G.TransmogFrame and _G.TransmogFrame.CharacterPreview and wardrobeCollectionFrame.UpdateSlot then
            C_Timer.After(0, function()
                local preview = _G.TransmogFrame.CharacterPreview
                if preview.RefreshSlots then
                    preview:RefreshSlots()
                end

                local selectedSlotData = preview.GetSelectedSlotData and preview:GetSelectedSlotData() or nil
                if selectedSlotData then
                    wardrobeCollectionFrame:UpdateSlot(selectedSlotData, true)
                end
            end)

            C_Timer.After(0, function()
                local preview = _G.TransmogFrame.CharacterPreview
                if preview and preview.RefreshSlots then
                    preview:RefreshSlots()
                end

                local selectedSlotData = preview and preview.GetSelectedSlotData and preview:GetSelectedSlotData() or nil
                if selectedSlotData then
                    wardrobeCollectionFrame:UpdateSlot(selectedSlotData, true)
                end
            end)
        end
    elseif displayMode == transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        Module:DebugLog("Hiding WardrobeCollection frame for OUTFIT_SWAP display mode.");
        wardrobeCollectionFrame:Hide();
    end
end

function Module:OnInitialize()
    Module:DebugLog("Applying changes to WardrobeCollection module.")
    
    -- initial frame setup
    Module:FixAnchors();
    Module:SetCollectionFrameMinWidth();

    Module:GetFrame().TabContent.SituationsFrame:HookScript("OnShow", function()
        Module:UpdateSituationTabMinWidth();
    end)

    Module:GetFrame().TabContent.SituationsFrame:HookScript("OnHide", function()
        transmogFrameModule:SetDefaultResizeBounds();
    end)

    Core.EventFrame:AddScript("OnTransmogFrameDisplayModeChanged", ApplyDisplayMode)
end


function Module:UpdateSituationTabMinWidth()
    local situationsFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(self:GetFrame(), "TabContent.SituationsFrame");
    
    if (situationsFrame == nil) then
        Module:DebugLog("Situations frame not found, cannot update min width.")
        return
    end
    
    self:SetCollectionFrameMinWidth(Module.Settings.SituationsTabMinWidth)
end


--- Adjusts the width of the TransmogFrame to set the collection frame to the desired width.
---@param collectionFrameWidth? number The desired width of the collection frame if nil, resets to default min width
function Module:SetCollectionFrameMinWidth(collectionFrameWidth)
    collectionFrameWidth = collectionFrameWidth or Module.Settings.MinFrameWidth;

    Module:DebugLog("Setting TransmogFrame collection frame width to " .. tostring(collectionFrameWidth))

    transmogFrameModule:SetMinFrameWidth(transmogFrameModule:GetStaticSizedChildrenWidth() + collectionFrameWidth);
end


function Module:FixAnchors()
    local characterPreviewModule = transmogFrameModule:GetModule("CharacterPreview");

    local wardrobeCollectionFrame = self:GetFrame();
    local transmogFrame = transmogFrameModule:GetFrame();
    local characterPreviewFrame = nil;

    if characterPreviewModule then
        characterPreviewFrame = characterPreviewModule:GetFrame();
    else
        characterPreviewFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrame, "CharacterPreview");
    end


    wardrobeCollectionFrame:ClearAllPoints()
    wardrobeCollectionFrame:SetPoint("TOPLEFT", characterPreviewFrame, "TOPRIGHT")
    wardrobeCollectionFrame:SetPoint("BOTTOMLEFT", characterPreviewFrame, "BOTTOMRIGHT")
    wardrobeCollectionFrame:SetPoint("TOPRIGHT", transmogFrame, "TOPRIGHT", 0, 0) -- -Module.Settings.OutfitCollectionFrame.AnchorOffset.Top
    wardrobeCollectionFrame:SetPoint("BOTTOMRIGHT", transmogFrame, "BOTTOMRIGHT")

    local tabContent = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(wardrobeCollectionFrame, "TabContent");
    if tabContent then 
        local offsets = Module.Settings.TabContentOffsets
        tabContent:ClearAllPoints()
        tabContent:SetPoint("TOPLEFT", self:GetFrame(), "TOPLEFT", offsets.Left, offsets.Top)
        tabContent:SetPoint("BOTTOMRIGHT", self:GetFrame(), "BOTTOMRIGHT", offsets.Right, offsets.Bottom)

        local background = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
            tabContent,
            "Background"
        );

        if background then
            local backgroundPadding = Module.Settings.TabContentFrame.BackgroundPadding
            background:SetPoint("TOPLEFT", tabContent, backgroundPadding.Left, -backgroundPadding.Top)
            background:SetPoint("BOTTOMRIGHT", tabContent, -backgroundPadding.Right, backgroundPadding.Bottom)
        end

        local border = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
            tabContent,
            "Border"
        );
        if border then
            local borderPadding = Module.Settings.TabContentFrame.BorderPadding
            border:SetPoint("TOPLEFT", tabContent, borderPadding.Left, -borderPadding.Top)
            border:SetPoint("BOTTOMRIGHT", tabContent, -borderPadding.Right, borderPadding.Bottom)
        end
        
    end
end

function Module:GetFrame()
    if _wardrobeCollectionFrame then return _wardrobeCollectionFrame end;

    _wardrobeCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrameModule:GetFrame(), "WardrobeCollection");
    
    if not _wardrobeCollectionFrame then
        error("WardrobeCollection frame is not found. Is the frame available yet?")
    end

    return _wardrobeCollectionFrame
end

