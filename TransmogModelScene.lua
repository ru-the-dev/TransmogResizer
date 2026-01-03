-- transmog model scene logic here

_G.TransmogResize = {};

--- @type LibRu
local LibRu = _G.LibRu

if not LibRu then
    error("LibRu is required to initialize TransmogResize. Please ensure LibRu is loaded before TransmogResize.lua")
end


-- handle button positioning logic
-- handle 