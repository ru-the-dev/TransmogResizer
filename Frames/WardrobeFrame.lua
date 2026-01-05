if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
end

--- @class LibRu
local LibRu = _G.LibRu

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end

-- convert wardrobe frame to a eventframe
WardrobeFrame = LibRu.Frames.EventFrame.New(WardrobeFrame);

-- enable resizing
WardrobeFrame.ResizeButton = LibRu.Frames.ResizeButton.New(WardrobeFrame, WardrobeFrame, 32);

WardrobeFrame:SetResizeBounds(885, 525);

WardrobeFrame:AddScript("OnSizeChanged", function(self, handle, width, height)
   _G.BetterTransmog.DebugLog("WardrobeFrame size changed: " .. width .. "x" .. height);
    WardrobeFrame:SetAttribute("UIPanelLayout-width", width);
end)

-- TODO: Set minimum and maximum size constraints