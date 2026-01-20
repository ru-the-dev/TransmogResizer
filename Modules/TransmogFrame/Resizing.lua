-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized. Please ensure Core.lua is loaded first.")
    return
end

--- @class BetterTransmog.Modules.TransmogFrame.Resizing : LibRu.Module
local Module = Core.LibRu.Module.New("TransmogFrame.Resizing");

Core.Modules = Core.Modules or {};

---@class BetterTransmog.Modules.TransmogFrame: LibRu.Module
local TransmogFrameModule = Core.Modules.TransmogFrame;

if not TransmogFrameModule then
    error(Module.Name .. " module requires TransmogFrame module to be loaded first.")
    return;
end


Module.Settings = {
    TransmogFrame = {
        MinHeight = 667,
        MinWidth = 1330,
    }
   
}


TransmogFrameModule.Resizing = Module;


-- =======================================================
-- Module Implementation
-- =======================================================

local function SetResizeBounds()
    Module:DebugLog("Setting TransmogFrame resize bounds.");

    ---@type Frame
    local transmogFrame = _G.TransmogFrame;


    local CollectionLayoutModule = TransmogFrameModule.CollectionLayout;
    local OutfitCollectionFrameModule = TransmogFrameModule.OutfitCollection;
    
    local minWidth;
    
    if CollectionLayoutModule and OutfitCollectionFrameModule then
        local charPreviewWidth = transmogFrame.CharacterPreview:GetWidth();
        -- calculate min width based on other modules' settings outfit collection + character preview + collection layout (min width)
        minWidth = OutfitCollectionFrameModule.Settings.ExpandedWidth + charPreviewWidth + CollectionLayoutModule.Settings.MinFrameWidth
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

    local resizeButton = Core.LibRu.Frames.ResizeButton.New(
        _G.TransmogFrame,
        _G.TransmogFrame,
        30
    )

    resizeButton:SetFrameStrata("FULLSCREEN_DIALOG")

    _G.TransmogFrame.ResizeButton = resizeButton

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