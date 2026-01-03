
-- if _G.TransmogResize == nil then
--     error("Addon must be initialized before loading settings.");
-- end;

-- --- @type LibRu
-- local LibRu = _G.LibRu

-- if not LibRu then
--     error("LibRu is required to initialize TransmogResize. Please ensure LibRu is loaded before TransmogResize.lua")
-- end



-- -- Settings UI (saves to TransmogResizerAccountDB)
-- local DEFAULTS = {
--     modelWidthPercent = 40, -- percent (30-50)
--     collectionGrid = 30,    -- (18-50)
--     setGrid = 12,           -- (8-18)
-- }

-- local function EnsureDB()
--     if not TransmogResizerAccountDB then TransmogResizerAccountDB = {} end
--     for k, v in pairs(DEFAULTS) do
--         if TransmogResizerAccountDB[k] == nil then
--             TransmogResizerAccountDB[k] = v
--         end
--     end
-- end

-- local function BuildPanel()
--     local panel = CreateFrame("Frame", "TransmogResizerOptionsPanel", UIParent)
--     panel.name = "TransmogResizer"

--     local verticalSpacing = 40;

--     local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
--     title:SetPoint("TOPLEFT", 16, -16)
--     title:SetText("TransmogResizer Settings")

--     local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
--     subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
--     subtitle:SetText("Adjust layout and item grid sizes.")


--     local s1 = LibRu.Frames.Slider.New(panel, "TransmogResizer_Slider_ModelWidth", "Model Width (% of frame):", 30, 50, 1, TransmogResizerAccountDB, "modelWidthPercent", function(v) return v .. "%" end)
--     s1:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -verticalSpacing)

--     local s2 = LibRu.Frames.Slider.New(panel, "TransmogResizer_Slider_CollectionGrid", "Collection Grid Models:", 18, 50, 1, TransmogResizerAccountDB, "collectionGrid")
--     s2:SetPoint("TOPLEFT", s1, "BOTTOMLEFT", 0, -verticalSpacing)

--     local s3 = LibRu.Frames.Slider.New(panel, "TransmogResizer_Slider_SetGrid", "Set Grid Models:", 8, 18, 1, TransmogResizerAccountDB, "setGrid")
--     s3:SetPoint("TOPLEFT", s2, "BOTTOMLEFT", 0, -verticalSpacing)

--     panel.Refresh = function(self)
--         EnsureDB()
--         s1:UpdateFromDB()
--         s2:UpdateFromDB()
--         s3:UpdateFromDB()
--     end

--     local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
--     Settings.RegisterAddOnCategory(category)
-- end


-- _G.TransmogResize.EventFrame:AddEvent("ADDON_LOADED", function(handle, event, name)
--     if name == "TransmogResizer" then
--         EnsureDB()
--         BuildPanel()
--         print("TransmogResizer settings initialized.")
--     end
-- end)