local Class = require 'utils.class'
local anim8 = require('libraries/anim8/anim8')

local Enemy = require('specific/enemy')
local media = require('media')
local global = require 'global'
local Frog = Class{
   name='frog',
   __includes = Enemy
}

local cw            = 58
local ch            = 39

-- jump internal time
local wait_every_jump = 1.2
local jump_wait = 0

function Frog:init(map, target, world, x,y)
   Enemy.init(self, world, x, y, cw, ch)
   self.target = target
   self.health = 1
   self.map = map
   self.r = 0
   self.hurt = false

   self.brakeAccel    = 2000
   self.airBrakeAccel = 168
   self.detectRadius  = 300
end

function Frog:update(dt)
   jump_wait = jump_wait + dt

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

   self:changeVelocityByCmds(dt)
   self:changeVelocityByGravity(dt)
   --self:playEffects()

   self:moveColliding(dt)
   self:changeVelocityByBeingOnGround(dt)
end

function Frog:ouch()
   if not self.hurt then
      self.hurt = true
      media.sfx.slime_death:play()
      self.vy = 300
   end
end

function Frog:leftAccel(dt, vx, vy)
   local vy = self.vy
   if jump_wait > wait_every_jump and self.onGround then
      jump_wait = 0
      self.onGround = false
      self:setSpriteFace('left')
      self:setSpriteState('jump')
      self.isJumpingOrFlying = true
      vx = -300
      vy = -450
   else
      self.stand = true
   end
   self.vy = vy
   return vx,vy
end

function Frog:rightAccel(dt, vx, vy)
   local vy = self.vy
   if jump_wait > wait_every_jump and self.onGround then
      jump_wait = 0
      self.onGround = false
      self:setSpriteFace('right')
      self:setSpriteState('jump')
      self.isJumpingOrFlying = true
      vx = 300
      vy = -450
   else
      self.stand = true
   end
   self.vy = vy
   return vx,vy
end

function Frog:drawWalk(sx,sy,ox,oy)
   love.graphics.draw(self.img_walk, self.x, self.y, 0, sx, sy, ox, oy)
end

function Frog:drawJump(sx,sy,ox,oy)
   love.graphics.draw(self.img_walk, self.x, self.y, 0, sx, sy, ox, oy)
end

return Frog
