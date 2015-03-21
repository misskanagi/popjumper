local Class = require 'utils.class'
local anim8 = require('libraries/anim8/anim8')

local Enemy = require('specific/enemy')
local media = require('media')
local global = require 'global'
local Bee = Class{
   name='bee',
   __includes = Enemy
}

local cw            = 58
local ch            = 45

function Bee:init(map, target, world, x,y)
   Enemy.init(self, world, x, y, cw, ch)
   local grid = anim8.newGrid(65, 45, self.img_walk:getWidth(), self.img_walk:getHeight())
   self.walk_anim = anim8.newAnimation(grid('1-2',1), 0.12)
   self.target = target
   self.health = 1
   self.map = map
   self.r = 0
   self.hurt = false
   self.runAccel      = 200
   self.maxRunSpeed   = 100
   self.Xaccel = self.runAccel
   self.maxSpeedX = self.maxRunSpeed

   self.brakeAccel    = 2000
   self.airBrakeAccel = 168
   self.detectRadius  = 300

   self.gravityAccel = 0
   self.detectRadius  = 400
end

function Bee:fly(dt, vy)
   if self.onGround then self:setSpriteState('walk')
   else self:setSpriteState('jump') end
   if math.abs(vy) <= self.maxSpeedX or vy > 0 then
      vy = vy - dt * (vy > 0 and self.brakeAccel or self.Xaccel)
   end
   return vy
end

function Bee:duck(dt, vy)
   if self.onGround then self:setSpriteState('walk')
   else self:setSpriteState('jump') end
   if math.abs(vy) <= self.maxSpeedX or vy < 0 then
      vy = vy + dt * (vy < 0 and self.brakeAccel or self.Xaccel)
   end
   return vy
end

function Bee:notFly(dt, vy)
   if math.abs(self.brake) > math.abs(vy) then
      vy = 0
   else
      vy = vy + self.brake
   end
   return vy
end

function Bee:update(dt)
   self:updateHurt(dt)
   self:updateHealth(dt)
   self:detectPlayer(dt)

   if self.targetInRadius then -- detected target
      self:chasePlayer(dt)
   else -- target not here, so patrol
      self:patrol(dt)
   end


   self.walk_anim:update(dt)
   self:changeVelocityByCmds(dt)

   --bee will always fly!
   self:changeVelocityByGravity(dt)
   --self:playEffects()

   self:moveColliding(dt)
   self:changeVelocityByBeingOnGround(dt)
end

function Bee:ouch()
   if not self.hurt then
      self.hurt = true
      media.sfx.slime_death:play()
      self.vy = 600
   end
end

function Bee:drawStand(sx,sy,ox,oy)
   self:drawWalk(sx,sy,ox,oy)
end
function Bee:drawJump(sx,sy,ox,oy)
   self:drawWalk(sx,sy,ox,oy)
end
function Bee:drawWalk(sx,sy,ox,oy)
   self.walk_anim:draw(self.img_walk, self.x, self.y, 0, sx, sy, ox, oy)
end

return Bee
