if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
end

--- @class LibRu
local LibRu = _G["LibRu"]

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end


-- convert wardrobe transmog frame to a eventframe
WardrobeTransmogFrame = LibRu.Frames.EventFrame.New(WardrobeTransmogFrame);

-- Button arrays for positioning
local slotButtons = {
    Left = {
        WardrobeTransmogFrame.HeadButton,
        WardrobeTransmogFrame.ShoulderButton,
        WardrobeTransmogFrame.BackButton,
        WardrobeTransmogFrame.ChestButton,
        WardrobeTransmogFrame.ShirtButton,
        WardrobeTransmogFrame.TabardButton,
        WardrobeTransmogFrame.WristButton
    },
    Right = {
        WardrobeTransmogFrame.HandsButton,
        WardrobeTransmogFrame.WaistButton,
        WardrobeTransmogFrame.LegsButton,
        WardrobeTransmogFrame.FeetButton
    }
}

-- set new anchor points for the WardrobeTransmogFrame
WardrobeTransmogFrame:ClearAllPoints();
WardrobeTransmogFrame:SetPoint("TOPLEFT", WardrobeFrame, "TOPLEFT", 4, -86);
WardrobeTransmogFrame:SetPoint("BOTTOMLEFT", WardrobeFrame, "BOTTOMLEFT", 4, 25);

-- set new anchor points for the ModelScene
WardrobeTransmogFrame.ModelScene:SetPoint("TOPLEFT", WardrobeTransmogFrame, "TOPLEFT");
WardrobeTransmogFrame.ModelScene:SetPoint("BOTTOMRIGHT", WardrobeTransmogFrame, "BOTTOMRIGHT");

-- increase max zoom out distance on the modelscene
hooksecurefunc(WardrobeTransmogFrame.ModelScene, "SetActiveCamera", function(self, camera)
    -- Hook this specific camera instance to catch SetMinZoomDistance calls
    hooksecurefunc(camera, "ApplyFromModelSceneCameraInfo", function(self, modelSceneCameraInfo, transitionType, modificationType)
        _G.BetterTransmog.DebugLog("Setting min zoom distance for WardrobeTransmogFrame ModelScene camera");
        self:SetMaxZoomDistance(7.5);
        self:SetZoomDistance(4);
    end)
end)



-- adjust Inset background to fit new frame size
local InsetBG = WardrobeTransmogFrame.Inset.BG;
InsetBG:ClearAllPoints();
InsetBG:SetPoint("TOPLEFT", WardrobeTransmogFrame.Inset, "TOPLEFT", 1, -1);
InsetBG:SetPoint("BOTTOMRIGHT", WardrobeTransmogFrame.Inset, "BOTTOMRIGHT", -1, 1);


-- function to update transmog slot button positions based on frame height
local function UpdateTransmogSlotPositions(height)
    local yOffsetScalar = 0.1;
    local yOffset = height * yOffsetScalar;
    local distanceFromBorder = 10;
    local ySpacing = (height * (1 - yOffsetScalar) - (#slotButtons.Left * 60)) / #slotButtons.Left

    -- Position left side buttons
    slotButtons.Left[1]:SetPoint("TOPLEFT", WardrobeTransmogFrame, "TOPLEFT", distanceFromBorder, -yOffset);
    for i = 2, (#slotButtons.Left) do
        slotButtons.Left[i]:SetPoint("TOP", slotButtons.Left[i - 1], "BOTTOM", 0, -ySpacing);
    end
    
    -- Position secondary shoulder button
    WardrobeTransmogFrame.SecondaryShoulderButton:ClearAllPoints();
    WardrobeTransmogFrame.SecondaryShoulderButton:SetPoint("LEFT", WardrobeTransmogFrame.ShoulderButton, "RIGHT", 15, 0);
    
    -- Position right side buttons
    slotButtons.Right[1]:SetPoint("TOPRIGHT", WardrobeTransmogFrame, "TOPRIGHT", -distanceFromBorder, -yOffset);
    for i = 2, (#slotButtons.Right) do
        slotButtons.Right[i]:SetPoint("TOP", slotButtons.Right[i - 1], "BOTTOM", 0, -ySpacing);
    end
    
    -- Position weapon buttons
    WardrobeTransmogFrame.MainHandButton:ClearAllPoints();
    WardrobeTransmogFrame.MainHandButton:SetPoint("BOTTOM", WardrobeTransmogFrame, "BOTTOM", -28, distanceFromBorder);
    WardrobeTransmogFrame.MainHandEnchantButton:ClearAllPoints();
    WardrobeTransmogFrame.MainHandEnchantButton:SetPoint("BOTTOM", WardrobeTransmogFrame.MainHandButton, "TOP", 0, -5);
    
    WardrobeTransmogFrame.SecondaryHandButton:ClearAllPoints();
    WardrobeTransmogFrame.SecondaryHandButton:SetPoint("BOTTOM", WardrobeTransmogFrame, "BOTTOM", 28, distanceFromBorder);
    WardrobeTransmogFrame.SecondaryHandEnchantButton:ClearAllPoints();
    WardrobeTransmogFrame.SecondaryHandEnchantButton:SetPoint("BOTTOM", WardrobeTransmogFrame.SecondaryHandButton, "TOP", 0, -5);
end


WardrobeFrame:AddScript("OnSizeChanged", function(self, handle, width, height)
    local TransmogFrameConfig = _G.BetterTransmog.DB.Account.TransmogFrame;
    local newWidth = TransmogFrameConfig.CharacterModelWidthPercent / 100 * width;
    WardrobeTransmogFrame:SetWidth(newWidth);
    
    -- Position buttons based on new size
    UpdateTransmogSlotPositions(height);
end)

UpdateTransmogSlotPositions(WardrobeTransmogFrame:GetHeight());