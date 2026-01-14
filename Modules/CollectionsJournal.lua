if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
end

--- @type LibRu
local LibRu = _G.LibRu

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end



-- -- set the CollectionsJournal to be movable
-- CollectionsJournal:SetMovable(true);
-- CollectionsJournal:EnableMouse(true);
-- CollectionsJournal:SetClampedToScreen(true);
-- CollectionsJournal:SetUserPlaced(true); -- Remember user position
-- CollectionsJournal:SetFrameStrata("HIGH"); -- Always on top of other UI panels

-- -- Update UIPanelWindows width when resized
-- CollectionsJournal:AddScript("OnSizeChanged", function(self, handle, width, height)
--     if UIPanelWindows["CollectionsJournal"] then
--         UIPanelWindows["CollectionsJournal"].width = width
--     end
-- end)

-- CollectionsJournal.TitleContainer:SetScript("OnMouseDown", function()
--     CollectionsJournal:StartMoving();
-- end)

-- CollectionsJournal.TitleContainer:SetScript("OnMouseUp", function()
--     CollectionsJournal:StopMovingOrSizing();
-- end)

-- -- enable resizing
-- LibRu.CreateResizeButton(CollectionsJournal, CollectionsJournal, 16);
-- -- TODO: Set minimum and maximum size constraints

-- _G.BetterTransmog.EventFrame:AddScript("OnAccountDBInitialized", function(self, handle)
--     if name ~= "BetterTransmog" then return end;
    
-- end)