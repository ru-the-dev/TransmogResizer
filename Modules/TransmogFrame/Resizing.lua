-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.Resizing : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "Resizing", 
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
}



-- =======================================================
-- Module Implementation
-- =======================================================

--- gets the combined width of the expanded outfit collection frame, and character preview frame
--- @return number|nil The combined width, or nil if outfit collection module is not loaded
local function GetOutfitCollectionAndCharacterPreviewWidth()
    local outfitCollectionFrameModule = transmogFrameModule.Modules.OutfitCollection;

    if outfitCollectionFrameModule == nil then return nil end

    return outfitCollectionFrameModule.Settings.ExpandedWidth + transmogFrameModule:GetFrame().CharacterPreview:GetWidth()
end



local function SetResizeBounds()
    Module:DebugLog("Setting TransmogFrame resize bounds.");

    local transmogFrame = transmogFrameModule:GetFrame();

    if not transmogFrame then
        Module:DebugLog("TransmogFrame is nil, cannot set resize bounds.");
        return
    end

    local isSituationsTabVisible = transmogFrame.WardrobeCollection.TabContent.SituationsFrame:IsShown();
    
    ---@type BetterTransmog.Modules.TransmogFrame.WardrobeCollection.Layout|nil
    local wardrobeCollectionLayoutModule = transmogFrameModule:GetModule("WardrobeCollection.CollectionLayout")
    local outfitCollectionAndCharacterPreviewWidth = GetOutfitCollectionAndCharacterPreviewWidth();

    local minWidth = 0;

    if wardrobeCollectionLayoutModule and outfitCollectionAndCharacterPreviewWidth then
        if isSituationsTabVisible then
            minWidth = outfitCollectionAndCharacterPreviewWidth + Module.Settings.SituationsTabMinWidth
            Module:DebugLog("Situations tab is visible, setting min width to " .. tostring(minWidth))
        else
            -- calculate min width based on situations tab min width + outfit collection + character preview
            minWidth = outfitCollectionAndCharacterPreviewWidth + wardrobeCollectionLayoutModule.Settings.MinFrameWidth
            Module:DebugLog("Situations tab is not visible, setting min width to " .. tostring(minWidth))
        end
       
    else 
        -- fallback to our default
        minWidth = transmogFrameModule.Settings.MinWidth
    end

    transmogFrame:SetResizeBounds(minWidth, transmogFrameModule.Settings.MinHeight)
end

local function RestoreSavedSize()
    Module:DebugLog("Restoring TransmogFrame size from AccountDB.");
    -- restore posizesition from account DB
    local savedSize = Core.Modules.AccountDB.DB.TransmogFrame.FrameSize;

    transmogFrameModule:GetFrame():SetSize(savedSize.Width, savedSize.Height)
    
end

local function SaveFrameSize()
    Module:DebugLog("Saving TransmogFrame size to AccountDB.");
    
    local width, height = transmogFrameModule:GetFrame():GetSize()


    -- save size to account DB
    local savedSize = Core.Modules.AccountDB.DB.TransmogFrame.FrameSize

    savedSize.Width = width
    savedSize.Height = height
end


local function ApplyChanges()
    Module:DebugLog("Applying changes.")

    -- set transmog frame's resize bounds
    SetResizeBounds();

    -- restore size for the first time opening
    RestoreSavedSize();

    -- note: we don't have to restore size on show, as the frame retains its size while hidden

    -- hook hide to save size
    transmogFrameModule:GetFrame():HookScript("OnHide", function(self)
        SaveFrameSize();
    end)

    -- add resize button
    Module:AddResizeButton();

    -- hook on situations show to adjust width if needed
    transmogFrameModule:GetFrame().WardrobeCollection.TabContent.SituationsFrame:HookScript("OnShow", function(self)
        Module:DebugLog("Situations tab shown, adjusting width if needed.")

        ---@type BetterTransmog.Modules.TransmogFrame.WardrobeCollection|nil
        local wardrobeCollectionModule = transmogFrameModule:GetModule("WardrobeCollection")

        if wardrobeCollectionModule then
            wardrobeCollectionModule:UpdateSituationTabMinWidth()
        end
    end)

    -- hook on situations show to adjust width if needed
    transmogFrameModule:GetFrame().WardrobeCollection.TabContent.SituationsFrame:HookScript("OnHide", function(self)
        Module:DebugLog("Situations tab shown, adjusting width if needed.")
        SetResizeBounds()
    end)
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

function Module:AddResizeButton()
    if transmogFrameModule:GetFrame().BT_ResizeButton then
        Module:DebugLog("Resize button already exists, skipping creation.")
        return
    end

    local resizeButton = Core.Libs.LibRu.Frames.ResizeButton.New(
        transmogFrameModule:GetFrame(),
        transmogFrameModule:GetFrame(),
        30
    )

    resizeButton:SetFrameStrata("FULLSCREEN_DIALOG")
    transmogFrameModule:GetFrame().BT_ResizeButton = resizeButton
end