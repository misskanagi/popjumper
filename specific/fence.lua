local Class = require 'utils.class'
local Block = require 'specific.block'
local global = require 'global'
local Fence = Class{
   name='fence',
   __includes = Block
}
local fw = global.tileWidth/3
local fh = global.tileHeight

function Fence:init(map, world, x,y)
   Block.init(self, world, x,y,fw,fh,global.tileWidth/2-fw/2,0)
   self.map = map
   self.r = 0
end

return Fence
