---@type LibRu
local LibRu = _G["LibRu"]

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end

local MAX_ROWS = 5
local MAX_COLS = 9

local function CreateAllModels()
    local frame = WardrobeCollectionFrame.ItemsCollectionFrame
    if not frame or not frame.Models then
        return
    end
    
    -- Create additional models beyond the original 18 (3x6) to reach 28 (7x4)
    local totalModels = MAX_COLS * MAX_ROWS  -- 7 * 4 = 28
    
    for i = 19, totalModels do
        if not frame.Models[i] then
            local model = CreateFrame("DressUpModel", "$parentCustomModel" .. i, frame, "WardrobeItemsModelTemplate")
            frame.Models[i] = model
            Mixin(model, WardrobeItemsModelMixin)
            model:OnLoad()
            model:Hide()
        end
    end
end

local function CalculateGridSize()
    local frame = WardrobeCollectionFrame.ItemsCollectionFrame
    if not frame then
        return 3, 6  -- Default fallback
    end
    
    local modelWidth = WardrobeCollectionFrame.ItemsCollectionFrame.Models[1]:GetWidth()
    local modelHeight = WardrobeCollectionFrame.ItemsCollectionFrame.Models[1]:GetHeight()
    local spacingX = 16
    local spacingY = 24
    local paddingX = 50  -- Increased for left/right padding to prevent cutoff
    local paddingY = 200 -- Increased for top/bottom padding (accounting for UI elements)
    
    local availableWidth = frame:GetWidth() - paddingX
    local availableHeight = frame:GetHeight() - paddingY
    
    local cols = math.floor((availableWidth + spacingX) / (modelWidth + spacingX))
    local rows = math.floor((availableHeight + spacingY) / (modelHeight + spacingY))
    
    -- Clamp to maximum and minimum
    cols = math.min(math.max(cols, 1), MAX_COLS)
    rows = math.min(math.max(rows, 1), MAX_ROWS)
    
    return rows, cols
end

local function ResizeWardrobeGrid(rows, cols)
    local frame = WardrobeCollectionFrame.ItemsCollectionFrame
    if not frame or not frame.Models then
        return
    end
    
    -- Clamp to maximum
    rows = math.min(rows, MAX_ROWS)
    cols = math.min(cols, MAX_COLS)
    
    -- Get actual model dimensions
    local modelWidth = frame.Models[1]:GetWidth()
    local modelHeight = frame.Models[1]:GetHeight()
    local spacingX = 16
    local spacingY = 24
    
    -- Store grid dimensions
    frame.GridRows = rows
    frame.GridCols = cols
    local itemsPerPage = rows * cols
    
    -- Hide all models first
    local totalModels = MAX_COLS * MAX_ROWS
    for i = 1, totalModels do
        if frame.Models[i] then
            frame.Models[i]:Hide()
        end
    end
    
    -- Show and position only the models we need
    local modelIndex = 1
    for row = 1, rows do
        for col = 1, cols do
            local model = frame.Models[modelIndex]
            
            if model then
                model:Show()
                model:ClearAllPoints()
                
                -- Calculate absolute position
                local xOffset = 40 + (col - 1) * (modelWidth + spacingX)
                local yOffset = -92 - (row - 1) * (modelHeight + spacingY)
                
                model:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)
                
                modelIndex = modelIndex + 1
            end
        end
    end
    
    -- Update frame properties
    frame.PAGE_SIZE = itemsPerPage
    frame.NUM_ROWS = rows
    frame.NUM_COLS = cols
    
    -- Update paging frame
    if frame.PagingFrame then
        local totalItems = (frame.filteredVisualsList and #frame.filteredVisualsList) or 0
        frame.PagingFrame.maxPages = math.max(1, math.ceil(totalItems / itemsPerPage))
        frame.PagingFrame:Update()
        
        -- Force reload current page to populate newly visible models
        local currentPage = frame.PagingFrame.currentPage or 1
        if frame.GoToPage then
            frame:GoToPage(currentPage)
        end
    end
    
    -- Refresh the display - this populates models with items
    if frame.RefreshVisuals then
        frame:RefreshVisuals()
    end
    
    -- Force update each visible model to ensure they display items
    C_Timer.After(0.1, function()
        if frame.UpdateItems then
            frame:UpdateItems()
        end
        -- Manually trigger model updates for each visible model
        for i = 1, itemsPerPage do
            if frame.Models[i] and frame.Models[i]:IsShown() then
                local visualIndex = frame.PagingFrame.currentPage and 
                    ((frame.PagingFrame.currentPage - 1) * itemsPerPage + i) or i
                if frame.filteredVisualsList and frame.filteredVisualsList[visualIndex] then
                    local model = frame.Models[i]
                    if model.Reload then
                        model:Reload()
                    end
                end
            end
        end
    end)
end

local function OnFrameResized()
    local rows, cols = CalculateGridSize()
    ResizeWardrobeGrid(rows, cols)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        C_Timer.After(2, function()
            CreateAllModels()
            
            local frame = WardrobeCollectionFrame.ItemsCollectionFrame
            if frame then
                -- Hook into frame resize
                frame:HookScript("OnSizeChanged", OnFrameResized)
                
                -- Hook into frame show to recalculate when opened
                frame:HookScript("OnShow", OnFrameResized)
                
                -- Initial resize if frame is already visible
                if frame:IsVisible() then
                    OnFrameResized()
                end
            end
        end)
    end
end)