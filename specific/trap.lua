local Class = require 'utils.class'
local global = require('global')
local Entities = require 'specific.entities'
local Trap = Class{
   name='trap',
   isTrap = true,
   __includes = Entities
}

function Trap:init(world, x,y,w,h,ox,oy)
   Entities.init(self, world, x+(ox or 0), y+(oy or 0), w, h)
   self.gravityAccel = 0

   local sp = global.trap_path
   local load_img = function(file)
      return love.graphics.newImage(sp .. self.name .. '/' ..file)
   end
   local exists = function(file)
      return love.filesystem.exists(sp .. self.name .. '/' ..file)
   end

   if exists('trap.png') then
      self.img = load_img('trap.png')
   end
end

function Trap:drawTrap(sx,sy,ox,oy)
   if self.img then
      love.graphics.draw(self.img, self.x, self.y, 0, sx, sy, ox, oy)
   end
end

function Trap:draw()
   self:drawTrap(1,1,0,0)
end

return Trap
