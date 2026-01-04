if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
end

--- @type LibRu
local LibRu = _G["LibRu"]

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end



-- override SetContainer to adjust layout based on parent frame


function WardrobeCollectionFrame:SetContainer(parent)
    _G.BetterTransmog.DebugLog("WardrobeCollectionFrame:SetContainer called with parent: " .. tostring(parent));

    self:SetParent(parent);
    self:ClearAllPoints();
    
    if parent == CollectionsJournal then
        -- Clear any custom anchoring from WardrobeFrame to prevent conflicts
        WardrobeFrame:ClearAllPoints();
        
        self:SetPoint("TOPLEFT", CollectionsJournal);
        self:SetPoint("BOTTOMRIGHT", CollectionsJournal);
        self.ItemsCollectionFrame.ModelR1C1:SetPoint("TOP", -238, -94);
        self.ItemsCollectionFrame.PagingFrame:SetPoint("BOTTOM", 22, 29);
        self.ItemsCollectionFrame.SlotsFrame:Show();
        self.ItemsCollectionFrame.BGCornerTopLeft:Hide();
        self.ItemsCollectionFrame.BGCornerTopRight:Hide();
        self.ItemsCollectionFrame.WeaponDropdown:SetPoint("TOPRIGHT", -25, -58);
        self.ClassDropdown:Show();
        self.ItemsCollectionFrame.NoValidItemsLabel:Hide();
        self.ItemsTab:SetPoint("TOPLEFT", 58, -28);
        self:SetTab(self.selectedCollectionTab);
    elseif parent == WardrobeFrame then
        self:SetPoint("TOPLEFT", WardrobeTransmogFrame, "TOPRIGHT", -5, 60);
        self:SetPoint("BOTTOMRIGHT", WardrobeFrame, "BOTTOMRIGHT", 0, 0);
        self.ItemsCollectionFrame.ModelR1C1:SetPoint("TOP", -235, -71);
        self.ItemsCollectionFrame.PagingFrame:SetPoint("BOTTOM", 22, 38);
        self.ItemsCollectionFrame.SlotsFrame:Hide();
        self.ItemsCollectionFrame.BGCornerTopLeft:Show();
        self.ItemsCollectionFrame.BGCornerTopRight:Show();
        self.ItemsCollectionFrame.WeaponDropdown:SetPoint("TOPRIGHT", -48, -26);
        self.ClassDropdown:Hide();
        self.ItemsTab:SetPoint("TOPLEFT", 8, -28);
        self:SetTab(self.selectedTransmogTab);
    end
    self:Show();
end