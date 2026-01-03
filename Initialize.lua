-- Initialization and setup logic

_G.TransmogResize = {};

--- @class LibRu
local LibRu = _G["LibRu"]

if not LibRu then
    error("LibRu is required to initialize TransmogResize. Please ensure LibRu is loaded before TransmogResize.lua")
end

-- Create a Global event frame
_G.TransmogResize.EventFrame = LibRu.EventFrame.New(CreateFrame("Frame"));