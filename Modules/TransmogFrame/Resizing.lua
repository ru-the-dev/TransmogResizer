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
    TransmogFrame = {
        MinHeight = 750,
        MinWidth = 1330,
    },
    SituationsTabMinWidth = 630
}



-- =======================================================
-- Module Implementation
-- =======================================================

--- gets the combined width of the expanded outfit collection frame, and character preview frame
--- @return number|nil The combined width, or nil if outfit collection module is not loaded
local function GetOutfitCollectionAndCharacterPreviewWidth()
    local outfitCollectionFrameModule = transmogFrameModule.OutfitCollection;

    if outfitCollectionFrameModule == nil then return nil end

    return outfitCollectionFrameModule.Settings.ExpandedWidth + _G.TransmogFrame.CharacterPreview:GetWidth()
end

local function SetCollectionFrameWidth(collectionFrameWidth)
    Module:DebugLog("Setting TransmogFrame collection frame width to " .. tostring(collectionFrameWidth))

    local outfitCollectionAndCharacterPreviewWidth = GetOutfitCollectionAndCharacterPreviewWidth();

    if outfitCollectionAndCharacterPreviewWidth == nil then
        error("OutfitCollection module not loaded, cannot set collection frame width.");
        return;
    end

    ---@type Frame
    local transmogFrame = _G.TransmogFrame;
    transmogFrame:SetWidth(collectionFrameWidth + outfitCollectionAndCharacterPreviewWidth);
end


local function SetResizeBounds()
    Module:DebugLog("Setting TransmogFrame resize bounds.");

    ---@type Frame
    local transmogFrame = _G.TransmogFrame;

    local isSituationsTabVisible = _G.TransmogFrame.WardrobeCollection.TabContent.SituationsFrame:IsShown();
    local CollectionLayoutModule = transmogFrameModule.CollectionLayout;
    local outfitCollectionAndCharacterPreviewWidth = GetOutfitCollectionAndCharacterPreviewWidth();

    local minWidth = 0;

    if CollectionLayoutModule and outfitCollectionAndCharacterPreviewWidth then
        if isSituationsTabVisible then
            minWidth = outfitCollectionAndCharacterPreviewWidth + Module.Settings.SituationsTabMinWidth
            Module:DebugLog("Situations tab is visible, setting min width to " .. tostring(minWidth))
        else
            -- calculate min width based on situations tab min width + outfit collection + character preview
            minWidth = outfitCollectionAndCharacterPreviewWidth + CollectionLayoutModule.Settings.MinFrameWidth
            Module:DebugLog("Situations tab is not visible, setting min width to " .. tostring(minWidth))
        end
       
    else 
        -- fallback to our default
        minWidth = Module.Settings.TransmogFrame.MinWidth;
    end

    transmogFrame:SetResizeBounds(minWidth, Module.Settings.TransmogFrame.MinHeight)
end

local function RestoreSavedSize()
    Module:DebugLog("Restoring TransmogFrame size from AccountDB.");
    -- restore posizesition from account DB
    local savedSize = Core.Modules.AccountDB.DB.TransmogFrame.FrameSize;

    _G.TransmogFrame:SetSize(savedSize.Width, savedSize.Height)
    
end

local function SaveFrameSize()
    Module:DebugLog("Saving TransmogFrame size to AccountDB.");
    
    local width, height = _G.TransmogFrame:GetSize()


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
    _G.TransmogFrame:HookScript("OnHide", function(self)
        SaveFrameSize();
    end)

    local resizeButton = Core.Libs.LibRu.Frames.ResizeButton.New(
        _G.TransmogFrame,
        _G.TransmogFrame,
        30
    )

    resizeButton:SetFrameStrata("FULLSCREEN_DIALOG")

    _G.TransmogFrame.ResizeButton = resizeButton


    -- hook on situations show to adjust width if needed
    _G.TransmogFrame.WardrobeCollection.TabContent.SituationsFrame:HookScript("OnShow", function(self)
        Module:DebugLog("Situations tab shown, adjusting width if needed.")
        
        Module:UpdateSituationTabMinWidth();
    end)

    -- hook on situations show to adjust width if needed
    _G.TransmogFrame.WardrobeCollection.TabContent.SituationsFrame:HookScript("OnHide", function(self)
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

function Module:UpdateSituationTabMinWidth()
    local situationsFrame = _G.TransmogFrame.WardrobeCollection.TabContent.SituationsFrame
    
    if (situationsFrame:GetWidth() < Module.Settings.SituationsTabMinWidth) then
        Module:DebugLog("Situations tab width is less than minimum, adjusting collection frame width.")
        SetCollectionFrameWidth(Module.Settings.SituationsTabMinWidth)
    end
    SetResizeBounds()
end