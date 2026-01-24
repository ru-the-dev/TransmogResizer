-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = _G.BetterTransmog;

--- @class BetterTransmog.Modules.TransmogFrame.CharacterPreview : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "CharacterPreview", 
    Core.Modules.TransmogFrame, 
    { 
        Core.Modules.TransmogFrame 
    }
);

Module.IsResetCameraHooked = false;


--- ======================================================
--- Locals 
--- ====================================================
---@type BetterTransmog.Modules.TransmogFrame
local transmogFrameModule = Core.Modules.TransmogFrame;
local _characterPreviewFrame = nil;

--- =======================================================
--- Module Settings
--- =======================================================

Module.Settings = {
    MinFrameWidth = 450,
    MaxFrameWidth = 900,
    MinCameraZoom = 2.5,
    MaxCameraZoom = 7.5,
    DefaultCameraZoom = 5.0,

    
}

-- =======================================================
-- Module Implementation
-- =======================================================

local function CharacterPreviewFrame_FixCamera()
    local preview = Module:GetFrame()
    local modelScene = preview.ModelScene
    local camera = modelScene:GetActiveCamera();


    camera:SetMinZoomDistance(Module.Settings.MinCameraZoom); 
    camera:SetMaxZoomDistance(Module.Settings.MaxCameraZoom);

    -- Set the current zoom to a reasonable default
    camera:SetZoomDistance(Module.Settings.DefaultCameraZoom);
end

local function CharacterPreviewFrame_HookReset()
    if Module.IsResetCameraHooked then return end;

    -- Hook the Reset method to reapply camera settings after reset
    local preview = Module:GetFrame()
    local modelScene = preview.ModelScene

    hooksecurefunc(modelScene, "Reset", function()
        CharacterPreviewFrame_FixCamera()
    end)

    Module.IsResetCameraHooked = true;
end

local function CharacterPreviewFrame_UpdateWidth()

    local accountDB = Core.Modules.AccountDB.DB;
    local preview = Module:GetFrame()

    local clampedWidth = math.min(
        math.max(
            accountDB.TransmogFrame.CharacterPreviewFrameWidth,
            Module.Settings.MinFrameWidth
        ),
        Module.Settings.MaxFrameWidth
    )

    Module:DebugLog("Setting CharacterPreview frame width to " .. clampedWidth)

    preview:SetWidth(clampedWidth)
end



local function ApplyChanges()
    Module:DebugLog("Applying changes.")

    Module:FixAnchors();

    CharacterPreviewFrame_HookReset();
    CharacterPreviewFrame_FixCamera();
    CharacterPreviewFrame_UpdateWidth();


    -- hook on show, fix camera every time, show resets the camera settings
    transmogFrameModule:GetFrame():HookScript("OnShow", function(self)
        CharacterPreviewFrame_FixCamera();
    end)
end

function Module:OnInitialize()
    Core.EventFrame:AddEvent(
        "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
        function(self, handle, _, frameId)
            if frameId ~= transmogFrameModule.Settings.TRANSMOG_FRAME_ID then return end

            ApplyChanges()
            self:RemoveEvent(handle)
        end
    )
end


function Module:FixAnchors()
    local outfitCollectionModule = transmogFrameModule:GetModule("OutfitCollection");
    local outfitCollectionFrame = nil;

    if outfitCollectionModule then
        outfitCollectionFrame = outfitCollectionModule:GetFrame();
    else
        outfitCollectionFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(
            transmogFrameModule:GetFrame(),
            "OutfitCollection"
        );
    end

    local characterPreviewFrame = Module:GetFrame();

    Module:DebugLog(outfitCollectionFrame)
    characterPreviewFrame:ClearAllPoints()
    characterPreviewFrame:SetPoint("TOPLEFT", outfitCollectionFrame, "TOPRIGHT")
    characterPreviewFrame:SetPoint("BOTTOMLEFT", outfitCollectionFrame, "BOTTOMRIGHT")

    local bg = characterPreviewFrame.Background
    bg:SetAllPoints(characterPreviewFrame)

    characterPreviewFrame.Gradients.GradientLeft:SetPoint("TOPLEFT", characterPreviewFrame)
    characterPreviewFrame.Gradients.GradientLeft:SetPoint("BOTTOMLEFT", characterPreviewFrame)

    characterPreviewFrame.Gradients.GradientRight:SetPoint("TOPRIGHT", characterPreviewFrame)
    characterPreviewFrame.Gradients.GradientRight:SetPoint("BOTTOMRIGHT", characterPreviewFrame)
end

function Module:GetFrame()
    if _characterPreviewFrame then return _characterPreviewFrame end;

    _characterPreviewFrame = Core.Libs.LibRu.Utils.Frame.GetFrameByPath(transmogFrameModule:GetFrame(), "CharacterPreview");
    
    if not _characterPreviewFrame then
        error("CharacterPreview frame is not found. Is the frame available yet?")
    end

    return _characterPreviewFrame
end