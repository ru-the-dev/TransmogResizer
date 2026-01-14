if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before WardrobeSetsTransmogFrame.lua. Please ensure Initialize.lua is loaded first.")
end

--[[
    WardrobeSetsTransmogFrame Module
    
    This module handles the dynamic grid layout and model management for the
    SetsTransmogFrame within the Wardrobe/Collections UI.
    
    Key responsibilities:
    - Creating additional transmog set frames beyond Blizzard's default 18
    - Calculating optimal grid layout based on frame size and max models setting
    - Positioning set frames in a responsive grid
    - Updating pagination to reflect the new model count
-- ]]

-- Grid layout configuration (matching Blizzard's default SetsTransmogFrame layout)
local GRID_CONFIG = {
    modelSpacingX = 13,  -- Horizontal spacing between set frames (pixels)
    modelSpacingY = 14,  -- Vertical spacing between set frames (pixels)
    paddingX = 50,       -- Total horizontal padding to account for frame chrome
    paddingY = 125,      -- Total vertical padding for UI elements (slots, paging, etc.)
    xOffset = 50,        -- Starting X position from frame left edge
    yOffset = -50        -- Starting Y position from frame top edge
}

--- Creates additional transmog set frames beyond Blizzard's default 18.
--- Frames are created using the same template as Blizzard's models and hidden by default.
--- @param setsFrame Frame The SetsTransmogFrame to add models to
local function CreateAdditionalSets(setsFrame)
    if not setsFrame or not setsFrame.Models then return end

    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.SetFrameModels
    local currentModels = #setsFrame.Models

    -- Only create models we don't already have
    for i = currentModels + 1, maxModels do
        local model = CreateFrame("DressUpModel", "$parentCustomSetModel" .. i, setsFrame, "WardrobeSetsTransmogModelTemplate")
        setsFrame.Models[i] = model
        -- Note: Mixin is applied via the template, no need to manually apply WardrobeSetsTransmogModelMixin
        if model.OnLoad then
            model:OnLoad()
        end
        model:Hide()  -- Start hidden, will be shown/positioned by PositionSets
    end
end

--- Calculates the optimal grid layout (rows x cols) based on available space.
--- Takes into account model size, spacing, padding, and the max models setting.
--- @param setsFrame Frame The SetsTransmogFrame to calculate layout for
--- @return number rows The number of rows that fit
--- @return number cols The number of columns that fit
local function CalculateSetsGridLayout(setsFrame)
    if not setsFrame or not setsFrame.Models or not setsFrame.Models[1] then
        return 2, 4  -- Default to Blizzard's 2x4 grid (8 models) if we can't calculate
    end

    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.SetFrameModels
    local modelWidth = setsFrame.Models[1]:GetWidth()
    local modelHeight = setsFrame.Models[1]:GetHeight()

    -- Calculate available space after accounting for padding
    local availableWidth = setsFrame:GetWidth() - GRID_CONFIG.paddingX
    local availableHeight = setsFrame:GetHeight() - GRID_CONFIG.paddingY

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

--- Repositions models in a grid layout based on available space.
--- Only handles geometric positioning, does not refresh visuals or pagination.
--- @param setsFrame Frame The SetsTransmogFrame to position models in
local function PositionSets(setsFrame)
    if not setsFrame or not setsFrame.Models then return end

    local rows, cols = CalculateSetsGridLayout(setsFrame)
    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.SetFrameModels
    local totalVisible = math.min(rows * cols, maxModels)

    local modelWidth = setsFrame.Models[1]:GetWidth()
    local modelHeight = setsFrame.Models[1]:GetHeight()

    -- Hide all models first (we'll show only the ones we need)
    for i = 1, #setsFrame.Models do
        setsFrame.Models[i]:Hide()
    end

    -- Position models in a grid pattern
    local modelIndex = 1
    for row = 1, rows do
        for col = 1, cols do
            if modelIndex > totalVisible then break end

            local model = setsFrame.Models[modelIndex]
            if model then
                model:Show()
                model:ClearAllPoints()

                -- Calculate position for this grid cell
                local xOffset = GRID_CONFIG.xOffset + (col - 1) * (modelWidth + GRID_CONFIG.modelSpacingX)
                local yOffset = GRID_CONFIG.yOffset - (row - 1) * (modelHeight + GRID_CONFIG.modelSpacingY)

                model:SetPoint("TOPLEFT", setsFrame, "TOPLEFT", xOffset, yOffset)
            end

            modelIndex = modelIndex + 1
        end
    end

    -- Update frame properties that Blizzard code relies on
    setsFrame.PAGE_SIZE = totalVisible
    setsFrame.NUM_ROWS = rows
    setsFrame.NUM_COLS = cols
end

--- Refreshes visuals, pagination, and model data after positioning.
--- Call this after PositionSets to update the UI with new set data.
--- @param setsFrame Frame The SetsTransmogFrame to refresh
local function RefreshSets(setsFrame)
    if not setsFrame or not setsFrame.Models then return end

    local totalVisible = setsFrame.PAGE_SIZE or 8

    -- Update pagination to reflect new page size
    if setsFrame.PagingFrame then
        local totalSets = (setsFrame.filteredSetsList and #setsFrame.filteredSetsList) or 0
        setsFrame.PagingFrame.maxPages = math.max(1, math.ceil(totalSets / totalVisible))
        setsFrame.PagingFrame:Update()

        -- Refresh the current page with new layout
        local currentPage = setsFrame.PagingFrame.currentPage or 1
        if setsFrame.GoToPage then
            setsFrame:GoToPage(currentPage)
        end
    end

    -- Trigger Blizzard's visual refresh if available
    if setsFrame.RefreshVisuals then
        setsFrame:RefreshVisuals()
    end

    -- Defer model reloads slightly to ensure everything is positioned first
    C_Timer.After(0.1, function()
        if not setsFrame or not setsFrame.Models then return end

        -- Force update sets to refresh the display
        if setsFrame.UpdateSets then
            setsFrame:UpdateSets()
        end

        -- Reload each visible model to ensure transmog renders correctly
        for i = 1, totalVisible do
            if setsFrame.Models[i] and setsFrame.Models[i]:IsShown() then
                local setIndex = setsFrame.PagingFrame.currentPage and ((setsFrame.PagingFrame.currentPage - 1) * totalVisible + i) or i
                if setsFrame.filteredSetsList and setsFrame.filteredSetsList[setIndex] then
                    if setsFrame.Models[i].Reload then
                        setsFrame.Models[i]:Reload()
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
    local setsFrame = WardrobeCollectionFrame.SetsTransmogFrame;
    if not setsFrame then
        _G.BetterTransmog.DebugLog("SetsTransmogFrame not found, cannot initialize additional set models.")
        return
    end
    
    -- Create any additional set models needed based on user settings
    CreateAdditionalSets(setsFrame)
    
    -- Hook into frame resize for quick repositioning during drag
    setsFrame:HookScript("OnSizeChanged", function()
        PositionSets(setsFrame)  -- Just reposition, no visual refresh
    end)
    
    -- Hook into resize button to do full refresh when resize completes
    ---@type LibRu.Frames.ResizeButton
    local resizeButton = WardrobeFrame.ResizeButton;
    if resizeButton then
        resizeButton:AddScript("OnMouseUp", function(self, handle)
            _G.BetterTransmog.DebugLog("Resize complete, refreshing sets.")
            if setsFrame:IsVisible() then
                RefreshSets(setsFrame)
            end
        end)
    end
    
    -- Reposition and refresh sets when frame becomes visible
    setsFrame:HookScript("OnShow", function()
        PositionSets(setsFrame)
        RefreshSets(setsFrame)
    end)

    -- If frame is already visible, trigger initial positioning and refresh
    if setsFrame:IsVisible() then
        C_Timer.After(0.5, function()
            PositionSets(setsFrame)
            RefreshSets(setsFrame)
        end)
    end

    -- Clean up: remove this handler since initialization only happens once
    self:RemoveScript(handle)
end)
