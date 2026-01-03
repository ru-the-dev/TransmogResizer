

local buttonsLeft = {};
local buttonsRight = {};


local function PositionLeftButtons(yOffset, ySpacing)
    -- first left button
    buttonsLeft[1]:SetPoint("TOPLEFT", WardrobeTransmogFrame, "TOPLEFT", 28, -yOffset);
    
    -- other left buttons
    for i = 2, (#buttonsLeft) do
        buttonsLeft[i]:SetPoint("TOP", buttonsLeft[i - 1], "BOTTOM", 0, -ySpacing);
    end
end


local function PositionRightButtons(yOffset, ySpacing)
    -- first right button
    buttonsRight[1]:SetPoint("TOPRIGHT", WardrobeTransmogFrame, "TOPRIGHT", -28, -yOffset);

    -- other right buttons
    for i = 2, (#buttonsRight) do
        buttonsRight[i]:SetPoint("TOP", buttonsRight[i - 1], "BOTTOM", 0, -ySpacing);
    end
end


local function PositionSeperateShoulderButton()
-- secondary shoulder button
    WardrobeTransmogFrame.SecondaryShoulderButton:ClearAllPoints();
    WardrobeTransmogFrame.SecondaryShoulderButton:SetPoint("LEFT", WardrobeTransmogFrame.ShoulderButton, "RIGHT", 15, 0);
end

local function PositionWeaponButtons()
    -- main hand + mainEnchant
    WardrobeTransmogFrame.MainHandButton:ClearAllPoints();
    WardrobeTransmogFrame.MainHandButton:SetPoint("BOTTOM", WardrobeTransmogFrame, "BOTTOM", -28, 24);
    

    WardrobeTransmogFrame.MainHandEnchantButton:ClearAllPoints();
    WardrobeTransmogFrame.MainHandEnchantButton:SetPoint("BOTTOM", WardrobeTransmogFrame.MainHandButton, "TOP", 0, -5);


    -- off-hand + offEnchant
    WardrobeTransmogFrame.SecondaryHandButton:ClearAllPoints();
    WardrobeTransmogFrame.SecondaryHandButton:SetPoint("BOTTOM", WardrobeTransmogFrame, "BOTTOM", 28, 24);
    

    WardrobeTransmogFrame.SecondaryHandEnchantButton:ClearAllPoints();
    WardrobeTransmogFrame.SecondaryHandEnchantButton:SetPoint("BOTTOM", WardrobeTransmogFrame.SecondaryHandButton, "TOP", 0, -5);

    -- TODO: ranged button
end

local function HandleSizing(width, height)
    WardrobeTransmogFrame:SetWidth(width * 0.4);
    WardrobeCollectionFrame:SetWidth(width * 0.6);

    local yOffsetScalar = 0.1;
    local yOffset = height * yOffsetScalar;
    local ySpacing = (height * (1 - yOffsetScalar) - (#buttonsLeft * 60)) / #buttonsLeft
   
    PositionLeftButtons(yOffset, ySpacing);

    PositionSeperateShoulderButton();

    -- double shoulder xmog toggle
    WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:ClearAllPoints();
    WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:SetPoint("BOTTOMLEFT", WardrobeCollectionFrame, "BOTTOMLEFT", 20, 20);

    PositionRightButtons(yOffset, ySpacing);

    PositionWeaponButtons();
end



-- Create Event Frame using Mixin
local eventFrame = CreateFrame("Frame")
eventFrame = Mixin(eventFrame, LibRu.EventMixin);
local handle = eventFrame._nextEventHandle + 1; 
eventFrame:AddEvent("TRANSMOGRIFY_UPDATE", function()
    if(WardrobeFrame == nil) then return end;

    -- handle wardrobe size changing
    WardrobeFrame:SetScript("OnSizeChanged", function(self, width, height)
        HandleSizing(width, height);
    end)

    
    LibRu.CreateResizeButton(WardrobeFrame, WardrobeFrame, 16);
    --eventFrame:RemoveEvent(handle)

    WardrobeCollectionFrame:SetPoint("TOPRIGHT", WardrobeFrame, "TOPRIGHT");
    WardrobeCollectionFrame:SetPoint("BOTTOMRIGHT", WardrobeFrame, "BOTTOMRIGHT");

    WardrobeTransmogFrame:SetPoint("TOPLEFT", WardrobeFrame, "TOPLEFT", 4, -86);
    WardrobeTransmogFrame:SetPoint("BOTTOMLEFT", WardrobeFrame, "BOTTOMLEFT", 0 , 24);
    
    WardrobeTransmogFrame.ModelScene:SetPoint("TOPLEFT", WardrobeTransmogFrame, "TOPLEFT");
    WardrobeTransmogFrame.ModelScene:SetPoint("BOTTOMRIGHT", WardrobeTransmogFrame, "BOTTOMRIGHT");

    WardrobeTransmogFrame.Inset.BG:Hide();

    WardrobeTransmogFrame.HeadButton:ClearAllPoints();
    buttonsLeft = {
        WardrobeTransmogFrame.HeadButton,
        WardrobeTransmogFrame.ShoulderButton,
        WardrobeTransmogFrame.BackButton,
        WardrobeTransmogFrame.ChestButton,
        WardrobeTransmogFrame.ShirtButton,
        WardrobeTransmogFrame.TabardButton,
        WardrobeTransmogFrame.WristButton
    };

    buttonsRight = {
        WardrobeTransmogFrame.HandsButton,
        WardrobeTransmogFrame.WaistButton,
        WardrobeTransmogFrame.LegsButton,
        WardrobeTransmogFrame.FeetButton
    }
    
    HandleSizing(WardrobeFrame:GetWidth(), WardrobeFrame:GetHeight());
end)




-- local eventFrame = CreateFrame("Frame")
-- eventFrame:RegisterEvent("ADDON_LOADED")
-- eventFrame:RegisterEvent("PLAYER_LOGIN")
-- eventFrame:SetScript("OnEvent", function(self, event, arg1)
--     if TrySetup() then
--         self:UnregisterAllEvents()
--         return
--     end

--     if event == "ADDON_LOADED" then
--         if arg1 == "Blizzard_Collections" or arg1 == "Blizzard_TransmogUI" then
--             if TrySetup() then
--                 self:UnregisterAllEvents()
--             end
--         end
--     elseif event == "PLAYER_LOGIN" then
--         if TrySetup() then
--             self:UnregisterAllEvents()
--         end
--     end
-- end)


-- Do some work when player loads in


-- Do some work when the transmog opens

-- do some work when the transmog frame updates