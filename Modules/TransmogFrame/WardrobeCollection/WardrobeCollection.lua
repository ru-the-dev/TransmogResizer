-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.WardrobeCollection : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "WardrobeCollection", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame 
    }
);

--- =======================================================
--- Dependencies
--- ======================================================
local transmogFrameModule = Core.Modules.TransmogFrame;

--- =======================================================
--- Locals
--- =====================================================
local _wardrobeCollectionFrame = nil;

--- =======================================================
-- Module Settings
-- =======================================================
Module.Settings = {
    MinFrameWidth = 450,
    SituationsTabMinWidth = 630,
    TabContentFrame = {
        BackgroundPadding = {
            Top = 0,
            Bottom = 10,
            Left = 0,
            Right = 10,
        },
        BorderPadding = {
            Top = -14,
            Bottom = -5,
            Left = -12,
            Right = -3,
        }
    }
}


-- =======================================================
-- Module Implementation
-- =======================================================
function Module:OnInitialize()
    Core.EventFrame:AddEvent(
        "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
        function(self, handle, _, frameId)
            if frameId ~= transmogFrameModule.Settings.TRANSMOG_FRAME_ID then return end
            
            Module:FixAnchors();
            

            self:RemoveEvent(handle)
        end
    )
end


function Module:UpdateSituationTabMinWidth()
    local situationsFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(self:GetFrame(), "TabContent.SituationsFrame");
    
    if (situationsFrame == nil) then
        Module:DebugLog("Situations frame not found, cannot update min width.")
        return
    end
    
    if (situationsFrame:GetWidth() < Module.Settings.SituationsTabMinWidth) then
        Module:DebugLog("Situations tab width is less than minimum, adjusting collection frame width.")
        self:SetCollectionFrameWidth(Module.Settings.SituationsTabMinWidth)
    end
end


--- Adjusts the width of the TransmogFrame to set the collection frame to the desired width.
---@param collectionFrameWidth number The desired width of the collection frame
function Module:SetCollectionFrameWidth(collectionFrameWidth)
    Module:DebugLog("Setting TransmogFrame collection frame width to " .. tostring(collectionFrameWidth))

    transmogFrameModule:SetMinFrameWidth(transmogFrameModule:GetStaticSizedChildrenWidth() + collectionFrameWidth);
end


function Module:FixAnchors()
    local characterPreviewModule = transmogFrameModule:GetModule("CharacterPreview");

    local wardrobeCollectionFrame = self:GetFrame();
    local transmogFrame = transmogFrameModule:GetFrame();
    local characterPreviewFrame = nil;

    if characterPreviewModule then
        characterPreviewFrame = characterPreviewModule:GetFrame();
    else
        characterPreviewFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrame, "CharacterPreview");
    end


    wardrobeCollectionFrame:ClearAllPoints()
    wardrobeCollectionFrame:SetPoint("TOPLEFT", characterPreviewFrame, "TOPRIGHT")
    wardrobeCollectionFrame:SetPoint("BOTTOMLEFT", characterPreviewFrame, "BOTTOMRIGHT")
    wardrobeCollectionFrame:SetPoint("TOPRIGHT", transmogFrame, "TOPRIGHT", 0, 0) -- -Module.Settings.OutfitCollectionFrame.AnchorOffset.Top
    wardrobeCollectionFrame:SetPoint("BOTTOMRIGHT", transmogFrame, "BOTTOMRIGHT")

    local tabContent = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(wardrobeCollectionFrame, "TabContent");
    if tabContent then 
        tabContent:ClearAllPoints()
        tabContent:SetPoint("TOPLEFT", self:GetFrame(), "TOPLEFT", 0, -35)
        tabContent:SetPoint("BOTTOMRIGHT", self:GetFrame())

        local background = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
            tabContent,
            "Background"
        );

        if background then
            local backgroundPadding = Module.Settings.TabContentFrame.BackgroundPadding
            background:SetPoint("TOPLEFT", tabContent, backgroundPadding.Left, -backgroundPadding.Top)
            background:SetPoint("BOTTOMRIGHT", tabContent, -backgroundPadding.Right, backgroundPadding.Bottom)
        end

        local border = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
            tabContent,
            "Border"
        );
        if border then
            local borderPadding = Module.Settings.TabContentFrame.BorderPadding
            border:SetPoint("TOPLEFT", tabContent, borderPadding.Left, -borderPadding.Top)
            border:SetPoint("BOTTOMRIGHT", tabContent, -borderPadding.Right, borderPadding.Bottom)
        end
        
    end
end

function Module:GetFrame()
    if _wardrobeCollectionFrame then return _wardrobeCollectionFrame end;

    _wardrobeCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrameModule:GetFrame(), "WardrobeCollection");
    
    if not _wardrobeCollectionFrame then
        error("WardrobeCollection frame is not found. Is the frame available yet?")
    end

    return _wardrobeCollectionFrame
end