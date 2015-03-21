local Class = require 'utils.class'
local Entities = require 'specific.entities'
local Block = Class{
   name='block',
   isBlock = true,
   __includes = Entities
}

function Block:init(world, x,y,w,h,ox,oy)
   Entities.init(self, world, x+(ox or 0), y+(oy or 0), w, h)
end

return Block
