-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
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

}


TransmogFrameModule.Resizing = Module;


-- =======================================================
-- Module Implementation
-- =======================================================

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