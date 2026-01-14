---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
    return
end

Core.Modules = Core.Modules or {}


local Module = {
    -- ID of transmog frame used in PLAYER_INTERACTION_MANAGER_FRAME_SHOW event
    TRANSMOG_FRAME_ID = 24;    
    EnableAnchors = true;
    EnableDragFrame = true;
    EnableResizeButton = true;
}

Core.Modules.TransmogFrameModule = Module;


local function ApplyChanges()
    Core.DebugLog("Transmog Frame first open detected, initializing BetterXmog modifications.")
    
    -- convert wardrobe frame to a eventframe
    ---@class LibRu.Frames.EventFrame
    _G.TransmogFrame = Core.LibRu.Frames.EventFrame.New(TransmogFrame);    
    
    if Module.EnableDragFrame == true then
        Core.LibRu.Utils.Frame.MakeDraggable(_G.TransmogFrame, nil, true)
    end

    if Module.EnableResizeButton == true then
        -- add resize button
        _G.TransmogFrame.ResizeButton = Core.LibRu.Frames.ResizeButton.New(_G.TransmogFrame, _G.TransmogFrame) 
    end
end



function Module:Initialize()
    Core.EventFrame:AddEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", function(self, handle, event, frameId) 
        ApplyChanges()
        
        self:RemoveEvent(handle);
    end)
end



