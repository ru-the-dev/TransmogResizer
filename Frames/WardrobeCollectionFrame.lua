if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before WardrobeCollectionFrame.lua. Please ensure Initialize.lua is loaded first.")
end

local LibRu = _G["LibRu"]
if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end

-- Configuration constants
local GRID_CONFIG = {
    modelSpacingX = 16,
    modelSpacingY = 24,
    paddingX = 50,
    paddingY = 200,
    xOffset = 40,
    yOffset = -92
}

-- Override SetContainer to adjust layout based on parent frame
function WardrobeCollectionFrame:SetContainer(parent)
    self:SetParent(parent)
    self:ClearAllPoints()
    
    if parent == CollectionsJournal then
        WardrobeFrame:ClearAllPoints()
        
        self:SetPoint("TOPLEFT", CollectionsJournal)
        self:SetPoint("BOTTOMRIGHT", CollectionsJournal)
        self.ItemsCollectionFrame.ModelR1C1:SetPoint("TOP", -238, -94)
        self.ItemsCollectionFrame.PagingFrame:SetPoint("BOTTOM", 22, 29)
        self.ItemsCollectionFrame.SlotsFrame:Show()
        self.ItemsCollectionFrame.BGCornerTopLeft:Hide()
        self.ItemsCollectionFrame.BGCornerTopRight:Hide()
        self.ItemsCollectionFrame.WeaponDropdown:SetPoint("TOPRIGHT", -25, -58)
        self.ClassDropdown:Show()
        self.ItemsCollectionFrame.NoValidItemsLabel:Hide()
        self.ItemsTab:SetPoint("TOPLEFT", 58, -28)
        self:SetTab(self.selectedCollectionTab)
    elseif parent == WardrobeFrame then
        self:SetPoint("TOPLEFT", WardrobeTransmogFrame, "TOPRIGHT", -5, 60)
        self:SetPoint("BOTTOMRIGHT", WardrobeFrame, "BOTTOMRIGHT", 0, 0)
        self.ItemsCollectionFrame.ModelR1C1:SetPoint("TOP", -235, -71)
        self.ItemsCollectionFrame.PagingFrame:SetPoint("BOTTOM", 22, 38)
        self.ItemsCollectionFrame.SlotsFrame:Hide()
        self.ItemsCollectionFrame.BGCornerTopLeft:Show()
        self.ItemsCollectionFrame.BGCornerTopRight:Show()
        self.ItemsCollectionFrame.WeaponDropdown:SetPoint("TOPRIGHT", -48, -26)
        self.ClassDropdown:Hide()
        self.ItemsTab:SetPoint("TOPLEFT", 8, -28)
        self:SetTab(self.selectedTransmogTab)
    end
    
    self:Show()
end

local function CreateAdditionalModels()
    local frame = WardrobeCollectionFrame.ItemsCollectionFrame
    if not frame or not frame.Models then
        return
    end
    
    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.CollectionFrameModels
    local currentModels = #frame.Models
    
    for i = currentModels + 1, maxModels do
        local model = CreateFrame("DressUpModel", "$parentCustomModel" .. i, frame, "WardrobeItemsModelTemplate")
        frame.Models[i] = model
        Mixin(model, WardrobeItemsModelMixin)
        model:OnLoad()
        model:Hide()
    end
end

local function CalculateGridLayout()
    local frame = WardrobeCollectionFrame.ItemsCollectionFrame
    if not frame or not frame.Models[1] then
        return 3, 6
    end
    
    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.CollectionFrameModels
    local modelWidth = frame.Models[1]:GetWidth()
    local modelHeight = frame.Models[1]:GetHeight()
    
    local availableWidth = frame:GetWidth() - GRID_CONFIG.paddingX
    local availableHeight = frame:GetHeight() - GRID_CONFIG.paddingY
    
    local maxCols = math.floor((availableWidth + GRID_CONFIG.modelSpacingX) / (modelWidth + GRID_CONFIG.modelSpacingX))
    local maxRows = math.floor((availableHeight + GRID_CONFIG.modelSpacingY) / (modelHeight + GRID_CONFIG.modelSpacingY))
    
    -- Clamp to at least 1
    maxCols = math.max(maxCols, 1)
    maxRows = math.max(maxRows, 1)
    
    -- Calculate actual cols/rows based on maxModels
    local cols = math.min(maxCols, maxModels)
    local rows = math.min(maxRows, math.ceil(maxModels / cols))
    
    return rows, cols
end

local function UpdatePaging(frame, totalVisible)
    if not frame.PagingFrame then
        return
    end
    
    local totalItems = (frame.filteredVisualsList and #frame.filteredVisualsList) or 0
    frame.PagingFrame.maxPages = math.max(1, math.ceil(totalItems / totalVisible))
    frame.PagingFrame:Update()
end

local function PositionModels()
    local frame = WardrobeCollectionFrame.ItemsCollectionFrame
    if not frame or not frame.Models then
        return
    end
    
    local rows, cols = CalculateGridLayout()
    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.CollectionFrameModels
    local totalVisible = math.min(rows * cols, maxModels)
    
    local modelWidth = frame.Models[1]:GetWidth()
    local modelHeight = frame.Models[1]:GetHeight()
    
    -- Hide all models first
    for i = 1, #frame.Models do
        frame.Models[i]:Hide()
    end
    
    -- Position and show only the models we need
    local modelIndex = 1
    for row = 1, rows do
        for col = 1, cols do
            if modelIndex > totalVisible then break end
            
            local model = frame.Models[modelIndex]
            if model then
                model:Show()
                model:ClearAllPoints()
                
                local xOffset = GRID_CONFIG.xOffset + (col - 1) * (modelWidth + GRID_CONFIG.modelSpacingX)
                local yOffset = GRID_CONFIG.yOffset - (row - 1) * (modelHeight + GRID_CONFIG.modelSpacingY)
                
                model:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)
            end
            
            modelIndex = modelIndex + 1
        end
    end
    
    -- Update frame properties
    frame.PAGE_SIZE = totalVisible
    frame.NUM_ROWS = rows
    frame.NUM_COLS = cols
    
    -- Update paging frame
    if frame.PagingFrame then
        local totalItems = (frame.filteredVisualsList and #frame.filteredVisualsList) or 0
        frame.PagingFrame.maxPages = math.max(1, math.ceil(totalItems / totalVisible))
        frame.PagingFrame:Update()
        
        -- Force reload current page
        local currentPage = frame.PagingFrame.currentPage or 1
        if frame.GoToPage then
            frame:GoToPage(currentPage)
        end
    end
    
    -- Refresh display
    if frame.RefreshVisuals then
        frame:RefreshVisuals()
    end
    
    -- Force model reloads
    C_Timer.After(0.1, function()
        if frame.UpdateItems then
            frame:UpdateItems()
        end
        
        for i = 1, totalVisible do
            if frame.Models[i] and frame.Models[i]:IsShown() then
                local visualIndex = frame.PagingFrame.currentPage and 
                    ((frame.PagingFrame.currentPage - 1) * totalVisible + i) or i
                if frame.filteredVisualsList and frame.filteredVisualsList[visualIndex] then
                    if frame.Models[i].Reload then
                        frame.Models[i]:Reload()
                    end
                end
            end
        end
    end)
end

_G.BetterTransmog.EventFrame:AddScript("OnAccountDBInitialized", function(self, handle)
    CreateAdditionalModels()
    
    local frame = WardrobeCollectionFrame.ItemsCollectionFrame
    if not frame then return end
    
    frame:HookScript("OnSizeChanged", PositionModels)
    frame:HookScript("OnShow", PositionModels)
    
    if frame:IsVisible() then
        C_Timer.After(0.5, PositionModels)
    end

    self:RemoveScript(handle);
end)