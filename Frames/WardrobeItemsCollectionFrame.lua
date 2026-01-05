if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before WardrobeItemsCollectionFrame.lua. Please ensure Initialize.lua is loaded first.")
end

--[[
    WardrobeItemsCollectionFrame Module
    
    This module handles the dynamic grid layout and model management for the
    ItemsCollectionFrame within the Wardrobe/Collections UI.
    
    Key responsibilities:
    - Creating additional transmog models beyond Blizzard's default 18
    - Calculating optimal grid layout based on frame size and max models setting
    - Positioning models in a responsive grid
    - Updating pagination to reflect the new model count
--]]

-- Grid layout configuration
local GRID_CONFIG = {
    modelSpacingX = 16,  -- Horizontal spacing between models (pixels)
    modelSpacingY = 24,  -- Vertical spacing between models (pixels)
    paddingX = 50,       -- Total horizontal padding to account for frame chrome
    paddingY = 125,      -- Total vertical padding for UI elements (slots, paging, etc.)
    xOffset = 40,        -- Starting X position from frame left edge
    yOffset = -50        -- Starting Y position from frame top edge
}

--- Creates additional transmog model frames beyond Blizzard's default 18.
--- Models are created using the same template as Blizzard's models and hidden by default.
--- @param itemsFrame Frame The ItemsCollectionFrame to add models to
local function CreateAdditionalModels(itemsFrame)
    if not itemsFrame or not itemsFrame.Models then return end

    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.CollectionFrameModels
    local currentModels = #itemsFrame.Models

    -- Only create models we don't already have
    for i = currentModels + 1, maxModels do
        local model = CreateFrame("DressUpModel", "$parentCustomModel" .. i, itemsFrame, "WardrobeItemsModelTemplate")
        itemsFrame.Models[i] = model
        Mixin(model, WardrobeItemsModelMixin)  -- Give it the same behavior as Blizzard's models
        model:OnLoad()
        model:Hide()  -- Start hidden, will be shown/positioned by PositionModels
    end
end

--- Calculates the optimal grid layout (rows x cols) based on available space.
--- Takes into account model size, spacing, padding, and the max models setting.
--- @param itemsFrame Frame The ItemsCollectionFrame to calculate layout for
--- @return number rows The number of rows that fit
--- @return number cols The number of columns that fit
local function CalculateGridLayout(itemsFrame)
    if not itemsFrame or not itemsFrame.Models or not itemsFrame.Models[1] then
        return 3, 6  -- Default to Blizzard's 3x6 grid if we can't calculate
    end

    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.CollectionFrameModels
    local modelWidth = itemsFrame.Models[1]:GetWidth()
    local modelHeight = itemsFrame.Models[1]:GetHeight()

    -- Calculate available space after accounting for padding
    local availableWidth = itemsFrame:GetWidth() - GRID_CONFIG.paddingX
    local availableHeight = itemsFrame:GetHeight() - GRID_CONFIG.paddingY

    -- Calculate how many models fit in available space
    local maxCols = math.floor((availableWidth + GRID_CONFIG.modelSpacingX) / (modelWidth + GRID_CONFIG.modelSpacingX))
    local maxRows = math.floor((availableHeight + GRID_CONFIG.modelSpacingY) / (modelHeight + GRID_CONFIG.modelSpacingY))

    -- Ensure at least 1 row and 1 column
    maxCols = math.max(maxCols, 1)
    maxRows = math.max(maxRows, 1)

    -- Limit to the user's max models setting
    local cols = math.min(maxCols, maxModels)
    local rows = math.min(maxRows, math.ceil(maxModels / cols))

    return rows, cols
end

--- Positions all models in a responsive grid layout and updates frame properties.
--- This function:
--- 1. Calculates the optimal grid layout
--- 2. Hides all models, then shows and positions only those that fit
--- 3. Updates frame properties (PAGE_SIZE, NUM_ROWS, NUM_COLS)
--- 4. Updates pagination to reflect the new layout
--- 5. Triggers visual refresh and model reloads
--- @param itemsFrame Frame The ItemsCollectionFrame to reposition models in
local function PositionModels(itemsFrame)
    if not itemsFrame or not itemsFrame.Models then return end

    local rows, cols = CalculateGridLayout(itemsFrame)
    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.CollectionFrameModels
    local totalVisible = math.min(rows * cols, maxModels)

    local modelWidth = itemsFrame.Models[1]:GetWidth()
    local modelHeight = itemsFrame.Models[1]:GetHeight()

    -- Hide all models first (we'll show only the ones we need)
    for i = 1, #itemsFrame.Models do
        itemsFrame.Models[i]:Hide()
    end

    -- Position models in a grid pattern
    local modelIndex = 1
    for row = 1, rows do
        for col = 1, cols do
            if modelIndex > totalVisible then break end

            local model = itemsFrame.Models[modelIndex]
            if model then
                model:Show()
                model:ClearAllPoints()

                -- Calculate position for this grid cell
                local xOffset = GRID_CONFIG.xOffset + (col - 1) * (modelWidth + GRID_CONFIG.modelSpacingX)
                local yOffset = GRID_CONFIG.yOffset - (row - 1) * (modelHeight + GRID_CONFIG.modelSpacingY)

                model:SetPoint("TOPLEFT", itemsFrame, "TOPLEFT", xOffset, yOffset)
            end

            modelIndex = modelIndex + 1
        end
    end

    -- Update frame properties that Blizzard code relies on
    itemsFrame.PAGE_SIZE = totalVisible
    itemsFrame.NUM_ROWS = rows
    itemsFrame.NUM_COLS = cols

    -- Update pagination to reflect new page size
    if itemsFrame.PagingFrame then
        local totalItems = (itemsFrame.filteredVisualsList and #itemsFrame.filteredVisualsList) or 0
        itemsFrame.PagingFrame.maxPages = math.max(1, math.ceil(totalItems / totalVisible))
        itemsFrame.PagingFrame:Update()

        -- Refresh the current page with new layout
        local currentPage = itemsFrame.PagingFrame.currentPage or 1
        if itemsFrame.GoToPage then
            itemsFrame:GoToPage(currentPage)
        end
    end

    -- Trigger Blizzard's visual refresh if available
    if itemsFrame.RefreshVisuals then
        itemsFrame:RefreshVisuals()
    end

    -- Defer model reloads slightly to ensure everything is positioned first
    C_Timer.After(0.1, function()
        if not itemsFrame or not itemsFrame.Models then return end

        -- Force update items to refresh the display
        if itemsFrame.UpdateItems then
            itemsFrame:UpdateItems()
        end

        -- Reload each visible model to ensure transmog renders correctly
        for i = 1, totalVisible do
            if itemsFrame.Models[i] and itemsFrame.Models[i]:IsShown() then
                local visualIndex = itemsFrame.PagingFrame.currentPage and ((itemsFrame.PagingFrame.currentPage - 1) * totalVisible + i) or i
                if itemsFrame.filteredVisualsList and itemsFrame.filteredVisualsList[visualIndex] then
                    if itemsFrame.Models[i].Reload then
                        itemsFrame.Models[i]:Reload()
                    end
                end
            end
        end
    end)
end

-- Initialize module when account database is ready
local eventFrame = _G.BetterTransmog.EventFrame
if not eventFrame then return end

-- Register for the custom OnAccountDBInitialized event
-- This fires after BetterTransmog has loaded saved variables and is ready
eventFrame:AddScript("OnAccountDBInitialized", function(self, handle)
    local itemsFrame = WardrobeCollectionFrame.ItemsCollectionFrame
    if not itemsFrame then return end

    -- Create any additional models needed based on user settings
    CreateAdditionalModels(itemsFrame)

    -- Hook into frame resize to dynamically adjust layout
    itemsFrame:HookScript("OnSizeChanged", function()
        PositionModels(itemsFrame)
    end)
    
    -- Reposition models when frame becomes visible
    itemsFrame:HookScript("OnShow", function()
        PositionModels(itemsFrame)
    end)

    -- If frame is already visible, trigger initial positioning
    if itemsFrame:IsVisible() then
        C_Timer.After(0.5, function()
            PositionModels(itemsFrame)
        end)
    end

    -- Clean up: remove this handler since initialization only happens once
    self:RemoveScript(handle)
end)
