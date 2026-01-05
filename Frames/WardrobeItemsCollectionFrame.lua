if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before WardrobeItemsCollectionFrame.lua. Please ensure Initialize.lua is loaded first.")
end

local ItemsCollectionFrameModule = {}

local GRID_CONFIG = {
    modelSpacingX = 16,
    modelSpacingY = 24,
    paddingX = 50,
    paddingY = 200,
    xOffset = 40,
    yOffset = -92
}

local function CreateAdditionalModels(itemsFrame)
    if not itemsFrame or not itemsFrame.Models then return end

    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.CollectionFrameModels
    local currentModels = #itemsFrame.Models

    for i = currentModels + 1, maxModels do
        local model = CreateFrame("DressUpModel", "$parentCustomModel" .. i, itemsFrame, "WardrobeItemsModelTemplate")
        itemsFrame.Models[i] = model
        Mixin(model, WardrobeItemsModelMixin)
        model:OnLoad()
        model:Hide()
    end
end

local function CalculateGridLayout(itemsFrame)
    if not itemsFrame or not itemsFrame.Models or not itemsFrame.Models[1] then
        return 3, 6
    end

    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.CollectionFrameModels
    local modelWidth = itemsFrame.Models[1]:GetWidth()
    local modelHeight = itemsFrame.Models[1]:GetHeight()

    local availableWidth = itemsFrame:GetWidth() - GRID_CONFIG.paddingX
    local availableHeight = itemsFrame:GetHeight() - GRID_CONFIG.paddingY

    local maxCols = math.floor((availableWidth + GRID_CONFIG.modelSpacingX) / (modelWidth + GRID_CONFIG.modelSpacingX))
    local maxRows = math.floor((availableHeight + GRID_CONFIG.modelSpacingY) / (modelHeight + GRID_CONFIG.modelSpacingY))

    maxCols = math.max(maxCols, 1)
    maxRows = math.max(maxRows, 1)

    local cols = math.min(maxCols, maxModels)
    local rows = math.min(maxRows, math.ceil(maxModels / cols))

    return rows, cols
end

local function PositionModels(itemsFrame)
    if not itemsFrame or not itemsFrame.Models then return end

    local rows, cols = CalculateGridLayout(itemsFrame)
    local maxModels = _G.BetterTransmog.DB.Account.TransmogFrame.CollectionFrameModels
    local totalVisible = math.min(rows * cols, maxModels)

    local modelWidth = itemsFrame.Models[1]:GetWidth()
    local modelHeight = itemsFrame.Models[1]:GetHeight()

    for i = 1, #itemsFrame.Models do
        itemsFrame.Models[i]:Hide()
    end

    local modelIndex = 1
    for row = 1, rows do
        for col = 1, cols do
            if modelIndex > totalVisible then break end

            local model = itemsFrame.Models[modelIndex]
            if model then
                model:Show()
                model:ClearAllPoints()

                local xOffset = GRID_CONFIG.xOffset + (col - 1) * (modelWidth + GRID_CONFIG.modelSpacingX)
                local yOffset = GRID_CONFIG.yOffset - (row - 1) * (modelHeight + GRID_CONFIG.modelSpacingY)

                model:SetPoint("TOPLEFT", itemsFrame, "TOPLEFT", xOffset, yOffset)
            end

            modelIndex = modelIndex + 1
        end
    end

    itemsFrame.PAGE_SIZE = totalVisible
    itemsFrame.NUM_ROWS = rows
    itemsFrame.NUM_COLS = cols

    if itemsFrame.PagingFrame then
        local totalItems = (itemsFrame.filteredVisualsList and #itemsFrame.filteredVisualsList) or 0
        itemsFrame.PagingFrame.maxPages = math.max(1, math.ceil(totalItems / totalVisible))
        itemsFrame.PagingFrame:Update()

        local currentPage = itemsFrame.PagingFrame.currentPage or 1
        if itemsFrame.GoToPage then
            itemsFrame:GoToPage(currentPage)
        end
    end

    if itemsFrame.RefreshVisuals then
        itemsFrame:RefreshVisuals()
    end

    C_Timer.After(0.1, function()
        if not itemsFrame or not itemsFrame.Models then return end

        if itemsFrame.UpdateItems then
            itemsFrame:UpdateItems()
        end

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

function ItemsCollectionFrameModule:Init(itemsFrame, parentFrame, eventFrame)
    if not itemsFrame then return end

    eventFrame = eventFrame or (_G.BetterTransmog and _G.BetterTransmog.EventFrame)
    if not eventFrame then return end

    eventFrame:AddScript("OnAccountDBInitialized", function(self, handle)
        CreateAdditionalModels(itemsFrame)

        itemsFrame:HookScript("OnSizeChanged", function()
            PositionModels(itemsFrame)
        end)
        itemsFrame:HookScript("OnShow", function()
            PositionModels(itemsFrame)
        end)

        if itemsFrame:IsVisible() then
            C_Timer.After(0.5, function()
                PositionModels(itemsFrame)
            end)
        end

        self:RemoveScript(handle)
    end)
end

_G.BetterTransmog.Frames = _G.BetterTransmog.Frames or {}
_G.BetterTransmog.Frames.WardrobeItemsCollectionFrame = ItemsCollectionFrameModule
