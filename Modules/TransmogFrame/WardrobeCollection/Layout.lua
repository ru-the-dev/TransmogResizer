-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.WardrobeCollection.Layout : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "Layout", 
    Core.Modules.TransmogFrame.Modules.WardrobeCollection, 
    { 
        Core.Modules.TransmogFrame.Modules.WardrobeCollection
    }
);

--- =======================================================
--- Dependencies
--- ======================================================
local wardrobeCollectionModule = Core.Modules.TransmogFrame.Modules.WardrobeCollection;


--- =======================================================
-- Module Settings
-- =======================================================


-- =======================================================
-- Module Implementation
-- =======================================================

local function GetFirstVisibleElementFrame(view)
    for _, child in ipairs({ view:GetChildren() }) do
        if child:IsShown()
            and child.GetWidth
            and child:GetWidth() > 0
            and child:GetHeight() > 0
        then
            return child
        end
    end
end


local function GetOneViewedPagedContentFrameLayoutSignature(pagedContentFrame)
    -- get the first view frame
    local view = pagedContentFrame.ViewFrames and pagedContentFrame.ViewFrames[1]
    if not view then 
        Module:DebugLog("No view frame found on paged content frame.")
        return nil
    end

    -- check if there's no multiple views (we can add support for this later)
    if #pagedContentFrame.ViewFrames > 1 then
        error("WardrobeCollectionLayoutSignature does not support multiple view frames yet.")
        return nil
    end

    -- find the first visible element frame
    local element = GetFirstVisibleElementFrame(view)
    if not element then
        Module:DebugLog("No visible element frame found in view.")
        return nil
    end

    -- get element dimensions
    local ew, eh = element:GetWidth(), element:GetHeight()
    if ew <= 0 or eh <= 0 then
        Module:DebugLog("Element has invalid dimensions: " .. tostring(ew) .. "x" .. tostring(eh))
        return nil
    end

    -- get view dimensions
    local vw, vh = view:GetWidth(), view:GetHeight()
    if vw <= 0 or vh <= 0 then
        Module:DebugLog("View has invalid dimensions: " .. tostring(vw) .. "x" .. tostring(vh))
        return nil
    end

    -- Horizontal stride (element + x padding)
    local xPadding = pagedContentFrame.xPadding or 0
    local elementStrideX = ew + xPadding

    -- Vertical stride (element or spacer + y padding)
    local spacerSize = pagedContentFrame.spacerSize or 0
    local elementStrideY = math.max(eh, spacerSize)

    -- Secondary padding (yPadding)
    if pagedContentFrame.yPadding then
        elementStrideY = elementStrideY + pagedContentFrame.yPadding
    end

    local columns = math.floor((vw + xPadding) / elementStrideX)
    local rows    = math.floor(vh / elementStrideY)

    if columns < 1 then columns = 1 end
    if rows < 1 then rows = 1 end

    return columns .. "x" .. rows
end


--- Updates the layout of the active wardrobe collection tab if needed
--- by checking if the layout signature has changed (rows x columns)
local function UpdateActiveTabLayout()
    local wardrobeCollectionFrame = wardrobeCollectionModule:GetFrame();

    -- get active tab ID
    local tabId = wardrobeCollectionFrame:GetTab()

    -- get active tab elements
    local tabElements = wardrobeCollectionFrame:GetElementsForTab(tabId)

    -- loop over elements
    for _, element in ipairs(tabElements) do

        -- if the element has paged content (AKA it's a PagedContentFrame)
        if element:IsShown() and element.PagedContent then
            local paged = element.PagedContent

            -- get the layout signature (rows x columns)
            local sig = GetOneViewedPagedContentFrameLayoutSignature(paged)
            Module:DebugLog("Calculated layout signature: " .. tostring(sig))
            -- if the signature has changed from the old layout, update layouts
            if sig and paged.BT_LayoutSignature ~= sig then
                -- store new signature on the frame
                

                Module:DebugLog("Layout signature changed to " .. sig .. ", updating layouts.")
                -- update layouts
                paged:UpdateLayouts()

                paged.BT_LayoutSignature = sig
            end
        end
    end
end


local function ApplyChanges()
    Module:DebugLog("Applying changes.")

    -- hook size changed to update layout
    wardrobeCollectionModule:GetFrame():HookScript("OnSizeChanged", function()
       UpdateActiveTabLayout();
    end)


    --- hook into tab changes to update remove layout signature to avoid stale layouts
    hooksecurefunc(wardrobeCollectionModule:GetFrame().internalTabTracker, "SetTab", function(self, tabId)
        -- get active tab elements
        local tabElements = self:GetElementsForTab(tabId)

        -- loop over elements
        for _, element in ipairs(tabElements) do
            -- if the element has paged content (AKA it's a PagedContentFrame)
            if element.PagedContent then
                local paged = element.PagedContent
                -- clear old signature to force layout update on next size change
                paged.BT_LayoutSignature = nil
            end
        end
    end)
end

function Module:OnInitialize()
    Core.EventFrame:AddEvent(
        "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
        function(self, handle, _, frameId)
            if frameId ~= Core.Modules.TransmogFrame.Settings.TRANSMOG_FRAME_ID then return end
            ApplyChanges()
            self:RemoveEvent(handle)
        end
    )
end

