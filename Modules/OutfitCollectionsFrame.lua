
local Module = {}

function Module.FixAnchors()
    ---@Frame
    local outfitFrame = _G.TransmogFrame.OutfitCollection;
    
    outfitFrame:ClearAllPoints();
    outfitFrame:SetPoint("TOPLEFT")
    outfitFrame:SetPoint("BOTTOMLEFT")
end


_G.BetterTransmog.OutfitCollectionsFrameModule = Module;