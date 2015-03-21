local Class = require 'utils.class'
local anim8 = require('libraries/anim8/anim8')

local Enemy = require('specific/enemy')
local media = require('media')
local global = require 'global'
local Spider = Class{
   name='spider',
   __includes = Enemy
}

local cw            = 80
local ch            = 55



function Spider:init(map, target, world, x,y)
   Enemy.init(self, world, x, y, cw, ch)
   local grid =
      anim8.newGrid(80, 55,
                    self.img_walk:getWidth(),
                    self.img_walk:getHeight(),2)
   self.walk_anim = anim8.newAnimation(grid('1-2',1), 0.1)
   self.target = target
   self.health = 1
   self.map = map
   self.r = 0

   self.hurt = false

   self.runAccel      = 600
   self.maxRunSpeed   = 500
   self.Xaccel = self.runAccel
   self.maxSpeedX = self.maxRunSpeed

   self.brakeAccel    = 2000
   self.airBrakeAccel = 168
   self.detectRadius  = 300
end

function Spider:update(dt)
   self:updateHurt(dt)
   self:updateHealth(dt)
   self:detectPlayer(dt)

   if self.targetInRadius then -- detected target
      cx,_ = self.target:pos()
      if cx-self.x < -5 then
         self:giveCommand(self.LEFT)
      elseif cx-self.x > 5 then
         self:giveCommand(self.RIGHT)
      end
   else -- target not here, so patrol
      self:patrol(dt)
   end

   self.walk_anim:update(dt)
   self:changeVelocityByCmds(dt)
   self:changeVelocityByGravity(dt)
   --self:playEffects()

   self:moveColliding(dt)
   self:changeVelocityByBeingOnGround(dt)
end

function Spider:ouch()
   if not self.hurt then
      self.hurt = true
      media.sfx.slime_death:play()
   end
end

function Spider:drawWalk(sx, sy, ox, oy)
   self.walk_anim:draw(self.img_walk, self.x, self.y, 0, sx, sy, ox, oy)
end

function Spider:drawJump(sx, sy, ox, oy)
   self.walk_anim:draw(self.img_walk, self.x, self.y, 0, sx, sy, ox, oy)
end

return Spider
