---@class BetterTransmog
local Core = _G.BetterTransmog;

---@class BetterTransmog.Modules.MinimapButton : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
    "MinimapButton", 
    Core, 
    { 
        Core,
        Core.Modules.AccountDB
    } 
)

--- ======================================================
--- Module Data
--- ======================================================

-- Initialize
function Module:OnInitialize()
    local LibDBIcon = LibStub("LibDBIcon-1.0")
    if not LibDBIcon then
        error("LibDBIcon-1.0 not found")
    end
    
    local ldb = LibStub("LibDataBroker-1.1")
    if not ldb then
        error("LibDataBroker-1.1 not found")
    end
    
    local dataobj = ldb:NewDataObject("BetterTransmog", {
        type = "launcher",
        text = "BetterTransmog",
        icon = "Interface\\AddOns\\BetterTransmog\\Assets\\logo",
        OnClick = function(self, button)
            if button == "LeftButton" then
                -- Toggle the collections journal (which contains transmog)
                ToggleCollectionsJournal()
            elseif button == "RightButton" then
                -- Show settings or menu
                if Core.Modules.Settings then
                    Core.Modules.Settings:OpenSettingsFrame()
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("BetterTransmog")
            tooltip:AddLine("Left-click to toggle [Outfit Swap Mode]", 1, 1, 1)
            tooltip:AddLine("Right-click for options", 1, 1, 1)
        end,
    })
    
    local db = Core.Modules.AccountDB.DB
    db.MinimapButton = db.MinimapButton or {}
    
    LibDBIcon:Register("BetterTransmog", dataobj, db.MinimapButton)
    
    self:DebugLog("LibDBIcon registered")
end

--- Shows or hides the minimap button
function Module:SetMinimapButtonVisible(visible)
    local LibDBIcon = LibStub("LibDBIcon-1.0")
    if visible then
        LibDBIcon:Show("BetterTransmog")
    else
        LibDBIcon:Hide("BetterTransmog")
    end
    
    -- Save visibility setting
    local db = Core.Modules.AccountDB.DB
    db.MinimapButton = db.MinimapButton or {}
    db.MinimapButton.hide = not visible
end

--- Gets the current minimap button visibility
function Module:IsMinimapButtonVisible()
    local LibDBIcon = LibStub("LibDBIcon-1.0")
    return LibDBIcon:IsVisible("BetterTransmog")
end
