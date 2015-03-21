local Class = require 'utils.class'
local global = require('global')
local Trap = require 'specific.trap'
local Ripper = Class{
   name='ripper',
   __includes = Trap
}

function Ripper:init(world, x,y,w,h)
   Trap.init(self, world, x+(ox or 0), y+(oy or 0), w, h)
end

function Ripper:doDamage(nx, ny, who)
   if ny < 0 then
      who:takeDamage(100)
   end
end

function Ripper:update(dt)end

return Ripper
