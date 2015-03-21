local Class = require 'utils.class'
local Block = require 'specific.block'
local Brick = Class{
   name='brick',
   __includes = Block
}

function Brick:init(map, world, x,y,w,h,half)
   local isHalf = half or false
   Block.init(self, world, x,y,w,(isHalf and h/2) or h)
   self.map = map
   self.r = 0
end

return Brick
