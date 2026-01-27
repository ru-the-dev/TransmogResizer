-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.Resizing : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "Resizing", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame
    }
);

--- =======================================================
--- Dependencies
--- ======================================================
---@type BetterTransmog.Modules.TransmogFrame
local transmogFrameModule = Core.Modules.TransmogFrame;


--- =======================================================
-- Module Settings
-- =======================================================

Module.Settings = {}



-- =======================================================
-- Module Implementation
-- =======================================================
local function RestoreSavedSize()
    if transmogFrameModule.DisplayMode ~= transmogFrameModule.Enum.DISPLAY_MODE.FULL then
        Module:DebugLog("TransmogFrame is not in FULL display mode, skipping size restore.");
        return
    end;

    Module:DebugLog("Restoring TransmogFrame size from AccountDB.");
    -- restore posizesition from account DB
    local savedSize = Core.Modules.AccountDB.DB.TransmogFrame.FrameSize;

    transmogFrameModule:GetFrame():SetSize(savedSize.Width, savedSize.Height)
    
end

local function SaveFrameSize()
    Module:DebugLog("Saving TransmogFrame size to AccountDB.");
    
    if transmogFrameModule.DisplayMode ~= transmogFrameModule.Enum.DISPLAY_MODE.FULL then
        Module:DebugLog("TransmogFrame is not in FULL display mode, skipping size save.");
        return
    end; 


    local width, height = transmogFrameModule:GetFrame():GetSize()


    -- save size to account DB
    local savedSize = Core.Modules.AccountDB.DB.TransmogFrame.FrameSize

    savedSize.Width = width
    savedSize.Height = height
end

---@param eventFrame Frame
---@param handle any
---@param displayMode string
local function ApplyDisplayMode(eventFrame, handle, displayMode)
    if not transmogFrameModule:IsValidDisplayMode(displayMode) then
        Module:DebugLog("UnimplmentedDisplayMode: " .. tostring(displayMode))
        return
    end

    if transmogFrameModule.IsReopeningFrame then
        Module:DebugLog("Reopening frame, deferring resize adjustments until after show.")
        return
    end

    if displayMode == transmogFrameModule.Enum.DISPLAY_MODE.FULL then
        transmogFrameModule:SetDefaultResizeBounds();

        local positioning = transmogFrameModule:GetModule("Positioning")
        if positioning and positioning.RestoreSavedPositionDeferred then
            positioning:RestoreSavedPositionDeferred(displayMode, 0)
        end
    elseif displayMode == transmogFrameModule.Enum.DISPLAY_MODE.OUTFIT_SWAP then
        -- outfit-mode positioning is applied after preview collapse/expand in CharacterPreview
    end
end

function Module:OnInitialize()
    Module:DebugLog("Applying changes.")

    -- restore size for the first time opening
    RestoreSavedSize();

    -- hook hide to save size
    transmogFrameModule:GetFrame():HookScript("OnHide", function(self)
        SaveFrameSize();
    end)

    -- add resize button
    Module:AddResizeButton();

    Core.EventFrame:AddScript("OnTransmogFrameDisplayModeChanged", ApplyDisplayMode)

    -- hook on situations show to adjust width if needed
    transmogFrameModule:GetFrame().WardrobeCollection.TabContent.SituationsFrame:HookScript("OnShow", function(self)
        Module:DebugLog("Situations tab shown, adjusting width if needed.")

        ---@type BetterTransmog.Modules.TransmogFrame.WardrobeCollection|nil
        local wardrobeCollectionModule = transmogFrameModule:GetModule("WardrobeCollection")

        if wardrobeCollectionModule then
            wardrobeCollectionModule:UpdateSituationTabMinWidth()
        end
    end)
end

function Module:AddResizeButton()
    if transmogFrameModule:GetFrame().BT_ResizeButton then
        Module:DebugLog("Resize button already exists, skipping creation.")
        return
    end

    local resizeButton = Core.Libs.LibRu.Frames.ResizeButton.New(
        transmogFrameModule:GetFrame(),
        transmogFrameModule:GetFrame(),
        30
    )

    resizeButton:SetFrameStrata("FULLSCREEN_DIALOG")
    transmogFrameModule:GetFrame().BT_ResizeButton = resizeButton
end