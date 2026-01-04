-- ---@type LibRu
-- local LibRu = _G["LibRu"]

-- if not LibRu then
-- 	error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
-- end

-- local MIN_VISIBLE_SET_BUTTONS = 18
-- local DEFAULT_SET_BUTTON_HEIGHT = 46
-- local DEFAULT_TEMPLATE = "WardrobeSetsScrollFrameButtonTemplate"

-- local function GetSetsFrame()
-- 	if not WardrobeCollectionFrame then
-- 		return nil
-- 	end

-- 	return WardrobeCollectionFrame.SetsCollectionFrame
-- end

-- local function GetSetsScrollContainer()
-- 	local setsFrame = GetSetsFrame()
-- 	if not setsFrame then
-- 		return nil
-- 	end

-- 	if setsFrame.ScrollFrame then
-- 		return setsFrame.ScrollFrame
-- 	end

-- 	-- Some builds replaced HybridScrollFrame with ScrollBox; bail out gracefully if present.
-- 	return nil
-- end

-- local function EnsureSetButtons(scrollFrame)
-- 	if not scrollFrame then
-- 		return
-- 	end

-- 	scrollFrame.buttons = scrollFrame.buttons or {}

-- 	local buttons = scrollFrame.buttons
-- 	local buttonHeight = scrollFrame.buttonHeight or (buttons[1] and buttons[1]:GetHeight()) or DEFAULT_SET_BUTTON_HEIGHT
-- 	scrollFrame.buttonHeight = buttonHeight

-- 	local spacing = scrollFrame.buttonSpacing or 2
-- 	local visibleNeeded = math.max(math.floor((scrollFrame:GetHeight() + spacing) / (buttonHeight + spacing)) + 2, MIN_VISIBLE_SET_BUTTONS)
-- 	local template = scrollFrame.buttonTemplate or DEFAULT_TEMPLATE
-- 	local parent = scrollFrame.scrollChild or scrollFrame

-- 	for i = (#buttons + 1), visibleNeeded do
-- 		local buttonName = (scrollFrame:GetName() or "BetterTransmogSetsButton") .. i
-- 		buttons[i] = CreateFrame("BUTTON", buttonName, parent, template)
-- 	end

-- 	-- Re-anchor to ensure the newly created buttons sit correctly.
-- 	for i, button in ipairs(buttons) do
-- 		button:ClearAllPoints()
-- 		if i == 1 then
-- 			button:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
-- 		else
-- 			button:SetPoint("TOPLEFT", buttons[i - 1], "BOTTOMLEFT", 0, -spacing)
-- 		end
-- 	end
-- end

-- local function RefreshSetsList()
-- 	local setsFrame = GetSetsFrame()
-- 	local scrollFrame = GetSetsScrollContainer()

-- 	if not setsFrame or not scrollFrame then
-- 		return
-- 	end

-- 	EnsureSetButtons(scrollFrame)

-- 	-- Nudge the native refresh so freshly visible buttons populate.
-- 	if setsFrame.Refresh then
-- 		setsFrame:Refresh()
-- 	elseif setsFrame.UpdateSetsList then
-- 		setsFrame:UpdateSetsList()
-- 	end

-- 	if scrollFrame.update then
-- 		scrollFrame.update(scrollFrame)
-- 	end
-- end

-- local function OnSetsFrameResized()
-- 	RefreshSetsList()
-- end

-- local eventFrame = CreateFrame("Frame")
-- eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- eventFrame:SetScript("OnEvent", function(self, event)
-- 	if event ~= "PLAYER_ENTERING_WORLD" then
-- 		return
-- 	end

-- 	self:UnregisterEvent(event)

-- 	C_Timer.After(2, function()
-- 		local setsFrame = GetSetsFrame()
-- 		local scrollFrame = GetSetsScrollContainer()

-- 		if not setsFrame or not scrollFrame then
-- 			return
-- 		end

-- 		scrollFrame:HookScript("OnSizeChanged", OnSetsFrameResized)
-- 		setsFrame:HookScript("OnShow", OnSetsFrameResized)

-- 		if setsFrame:IsVisible() then
-- 			OnSetsFrameResized()
-- 		end
-- 	end)
-- end)
