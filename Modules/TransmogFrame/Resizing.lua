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

function Module:OnInitialize()
    Module:DebugLog("Applying changes.")

    -- restore size for the first time opening
    RestoreSavedSize();

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