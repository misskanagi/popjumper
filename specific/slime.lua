local Class = require 'utils.class'
local anim8 = require('libraries/anim8/anim8')

local Enemy = require('specific/enemy')
local media = require('media')
local global = require 'global'
local Slime = Class{
   name='slime',
   __includes = Enemy
}

local cw            = 50
local ch            = 35



function Slime:init(map, target, world, x,y)
   Enemy.init(self, world, x, y, cw, ch)
   local grid =
      anim8.newGrid(60, 40, self.img_walk:getWidth(), self.img_walk:getHeight(),2)
   local sp = global.sprite_path
   self.walk_anim = anim8.newAnimation(grid('1-2',1), 0.2)
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
end
function Slime:fly(dt, vy) return vy end
function Slime:duck(dt,vx) return vx end
function Slime:update(dt)
   self:updateHurt(dt)
   self:detectPlayer(dt)

   if self.targetInRadius then -- detected target
      self:chasePlayer(dt)
      --self:patrol(dt)
   else -- target not here, so patrol
      self:patrol(dt)
   end

   self.walk_anim:update(dt)
   self:changeVelocityByCmds(dt)
   self:changeVelocityByGravity(dt)
   --self:playEffects()

   self:moveColliding(dt)
   self:changeVelocityByBeingOnGround(dt)
   self:updateHealth(dt)
end

function Slime:ouch()
   if not self.hurt then
      self.hurt = true
      media.sfx.slime_death:play()
   end
end

function Slime:preDraw()
   if self:isHurt()  then
      self.h = ch
   else
      self.h = ch
   end
end

function Slime:drawWalk(sx, sy, ox, oy)
   self.walk_anim:draw(self.img_walk, self.x, self.y, 0, sx, sy, ox, oy)
end

function Slime:drawJump(sx, sy, ox, oy)
   self.walk_anim:draw(self.img_walk, self.x, self.y, 0, sx, sy, ox, oy)
end

return Slime
