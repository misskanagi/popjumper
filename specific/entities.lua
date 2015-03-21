local Class = require 'utils.class'
local global = require 'global'
local Entities = Class{name='entities'}


function Entities:init(world, x,y,w,h)
   self.world, self.x, self.y, self.w, self.h = world,x,y,w,h
   self.vx, self.vy = 0,0
   self.world:add(self,x,y,w,h)
   self.created_at = love.timer.getTime()

   self.gravityAccel  = global.gravity -- pixels per second^2
   self.maxFallSpeed = 1280
end

function Entities:changeVelocityByGravity(dt)
   if math.abs(self.vy) <= self.maxFallSpeed then
      self.vy = self.vy + self.gravityAccel * dt
   end
end

function Entities:changeVelocityByCollisionNormal(nx, ny, bounciness)
  bounciness = bounciness or 0
  local vx, vy = self.vx, self.vy

  if (nx < 0 and vx > 0) or (nx > 0 and vx < 0) then
    vx = -vx * bounciness
  end

  if (ny < 0 and vy > 0) or (ny > 0 and vy < 0) then
    vy = -vy * bounciness
  end

  self.vx, self.vy = vx, vy
end

function Entities:getCenter()
  return self.x + self.w / 2,
         self.y + self.h / 2
end

function Entities:size()
   return self.w,self.h
end

function Entities:pos()
   return self.x,self.y
end

function Entities:destroy()
  self.world:remove(self)
end

function Entities:getUpdateOrder()
  return self.class.updateOrder or 10000
end

return Entities
