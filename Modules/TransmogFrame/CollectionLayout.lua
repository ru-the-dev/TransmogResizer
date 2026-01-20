-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

if not Core then
    error("BetterTransmog must be initialized. Please ensure Core.lua is loaded first.")
    return
end

--- @class BetterTransmog.Modules.TransmogFrame.CollectionLayout : LibRu.Module
local Module = Core.LibRu.Module.New("TransmogFrame.CollectionLayout");

Core.Modules = Core.Modules or {};

---@class BetterTransmog.Modules.TransmogFrame: LibRu.Module
local TransmogFrameModule = Core.Modules.TransmogFrame;

if not TransmogFrameModule then
    error(Module.Name .. " module requires TransmogFrame module to be loaded first.")
    return;
end


Module.Settings = {
    MinFrameWidth = 440,
}

TransmogFrameModule.CollectionLayout = Module;


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
    if not view then return nil end

    -- check if there's no multiple views (we can add support for this later)
    if #pagedContentFrame.ViewFrames > 1 then
        error("WardrobeCollectionLayoutSignature does not support multiple view frames yet.")
        return nil
    end

    -- find the first visible element frame
    local element = GetFirstVisibleElementFrame(view)
    if not element then return nil end

    -- get element dimensions
    local ew, eh = element:GetWidth(), element:GetHeight()
    if ew <= 0 or eh <= 0 then return nil end

    -- get view dimensions
    local vw, vh = view:GetWidth(), view:GetHeight()
    if vw <= 0 or vh <= 0 then return nil end

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
    local wardrobeCollectionFrame = _G.TransmogFrame.WardrobeCollection

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
            
            -- if the signature has changed from the old layout, update layouts
            if sig and paged.BT_LayoutSignature ~= sig then
                -- store new signature on the frame
                paged.BT_LayoutSignature = sig

                -- update layouts
                paged:UpdateLayouts()
            end
        end
    end
end


local function ApplyChanges()
    Module:DebugLog("Applying changes.")


     -- hook size changed to update layout
    _G.TransmogFrame.WardrobeCollection:HookScript("OnSizeChanged", function()
        UpdateActiveTabLayout()
    end)

end

function Module:OnInitialize()
    Core.EventFrame:AddEvent(
        "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
        function(self, handle, _, frameId)
            if frameId ~= TransmogFrameModule.Settings.TRANSMOG_FRAME_ID then return end
            ApplyChanges()
            self:RemoveEvent(handle)
        end
    )
end