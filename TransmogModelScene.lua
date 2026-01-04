-- transmog model scene logic here

if not _G.BetterTransmog then
    error("BetterTransmog must be initialized before TransmogModelScene.lua. Please ensure Initialize.lua is loaded first.")
end

--- @type LibRu
local LibRu = _G.LibRu

if not LibRu then
    error("LibRu is required to initialize BetterTransmog. Please ensure LibRu is loaded before BetterTransmog.lua")
end


_G.BetterTransmog.EventFrame:AddEvent("ADDON_LOADED", function(handle, event, name)
    if name ~= "BetterTransmog" then return end;
    
end)

