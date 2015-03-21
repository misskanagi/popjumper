local Class = require 'utils.class'
local anim8 = require('libraries/anim8/anim8')
local timer = require("utils.timer")
local tween = require('libraries/tween/tween')

local Sprite = require('specific/sprite')
local media = require('media')
local global = require 'global'
local Player = Class{
   name='player',
   isPlayer = true,
   __includes = Sprite
}

local deadDuration  = 3   -- seconds until res-pawn

local cw            = 60
local ch            = 95

function Player:init(map, world, x,y)
   Sprite.init(self, world, x, y, cw, ch)
   local grid = anim8.newGrid(78, 97, self.img_walk:getWidth(), self.img_walk:getHeight(),2)
   self.walk_anim = anim8.newAnimation(grid('1-11',1), 0.05)
   self.dash_anim = anim8.newAnimation(grid('1-11',1), 0.025)

   --health
   self.health = 6
   self.currentHealth = 6

   self.map = map
   self.r = 0
   self.isDash = false
   self.col_len = 0
   self.deadCounter = 0

   self.bounciness = 1.5

   --run properties
   self.runAccel      = 400
   self.maxRunSpeed   = 460
   self.Xaccel = self.runAccel
   self.maxSpeedX = self.maxRunSpeed

   --dash properties
   self.dashAccel     = 850 -- dashing acceleration
   self.maxDashSpeed  = 800

   --rocket properties
   self.rocketAccel   = 2500
   self.maxRocketSpeed= 300

   --coins
   self.coins = 0

   --SFX
   self.playHurtSFX = false
   self.playCoinSFX = false
   self.playDeathSFX = false
end

function Player:dead(dt)
   local brake = dt * (self.vx < 0 and self.airBrakeAccel or -self.airBrakeAccel)
   if math.abs(brake) > math.abs(self.vx) then
      self.vx = 0
   else
      self.vx = self.vx + brake
   end
end

function Player:changeVelocityByKeys(dt)
   self.isJumpingOrFlying = false
   if self:isDead() then self:dead(dt) return end

   local vx, vy = self.vx, self.vy
   local brake = 0

   -- dashing code
   if love.keyboard.isDown("lshift") and self.onGround then --dash
      self.isDash = true
      self.maxSpeedX = self.maxDashSpeed
      self.Xaccel = self.dashAccel
   else
      self.isDash = false
      self.maxSpeedX = self.maxRunSpeed
      if math.abs(vx) > self.maxSpeedX then
         vx = vx + brake
      end
      self.Xaccel = self.runAccel
   end

   -- brake in the air and on the ground is different
   if self:isJump() then
      brake = dt * (vx < 0 and self.airBrakeAccel or -self.airBrakeAccel)
   else
      brake = dt * (vx < 0 and self.brakeAccel or -self.brakeAccel)
   end

   if love.keyboard.isDown("down") then -- duck
      vx = self:duck(dt, vx)
   else
      if love.keyboard.isDown("left") then -- move left
         vx = self:leftAccel(dt, vx)
      elseif love.keyboard.isDown("right") then -- move right
         vx = self:rightAccel(dt, vx)
      else
         if self.onGround then self:setSpriteState('stand')
         else self:setSpriteState('jump') end
         if math.abs(brake) > math.abs(vx) then
            vx = 0
         else
            vx = vx + brake
         end
      end
      if love.keyboard.isDown("z") and (self.onGround) then -- jump
         vy = self:jump(dt, vy)
      end
      if love.keyboard.isDown("z") and not self.onGround then -- jump accel
         vy = vy + -self.jumpAccel * dt
      end
      if love.keyboard.isDown("up") then--and not self.onGround then -- fly
         vy = self:fly(dt, vy)
      end
   end

   self.vx, self.vy = vx, vy
end

function Player:playEffects()
   if self.isJumpingOrFlying then
      if self.onGround then
         media.sfx.player_jump:play()
      end
   end
   if self.playHurtSFX then
      self.playHurtSFX = false
      media.sfx.player_hurt:play()
   end
   if self.playCoinSFX then
      self.playCoinSFX = false
      media.sfx.coin:play()
   end
   if self.playDeathSFX then
      self.playDeathSFX = false
      media.sfx.player_death:play()
   end
end

function Player:ouch(dir)
   if not self.hurt then
      self.hurt = true
      self.playHurtSFX = true
      local d = self:isFaceLeft() and 1 or -1
      self.vx = dir ~= 0 and dir * 500 or 500*d
      self.vy = -300
   end
end

function Player:touchEnemy(col)
   local nx,ny = col.normal.x,col.normal.y
   if col.other:isDead() then
      --col.other:takeForce(self.vx,self.vy,-nx,-ny,0.5)
      return
   end
   if(nx ~= 0) or (ny > 0)then -- touch enemy
      if self.hurt then return end
      self:takeDamage(1)
      self:ouch(nx)
   elseif ny < 0 then -- jump on enemy's head
      self:bounce(1.1)
      col.other:ouch()
      col.other:takeDamage(10)
   end
end

function Player:touchTrap(col)
   col.other:doDamage(col.normal.x, col.normal.y, self)
end

function Player:takeCoin(other)
   self.playCoinSFX = true
   self.coins = self.coins+1
   self.world:remove(other)
   other:takenByPlayer()
end

function Player:bounce(factor)
   local vy = self.vy
   vy = -vy * factor
   self.vy = vy
end

function Player:updateHealth(dt)
   if self.currentHealth <= 0 then
      self.currentHealth = 0
      if not self:isDead() then
         self.playDeathSFX = true
      end
      self:setSpriteState('dead')
   end
end

function Player:takeDamage(dmg)
   if dmg > self.currentHealth then
      self.currentHealth = 0
   else
      self.currentHealth = self.currentHealth - dmg
   end
end

function Player:updateHurt(dt)
   if self.hurt then
      self.flicker_period = self.flicker_period + dt
      if self.flicker_period > self.flicker_time then
         self.isFlicker = not self.isFlicker
         self.flicker_period = 0
      end
      self.hurt_period = self.hurt_period + dt
      if (self.hurt_period > self.no_hurt_time) then
         self.hurt = false
         self.isFlicker = false
         self.hurt_period = 0
      end
   end
end

function Player:hurting() -- ugly internal implement
   return self.hurt
end

function Player:isHurt() -- ugly internal implement
   return self.hurt and not self.onGround
end

function Player:update(dt)
   self:updateHurt(dt)
   self.walk_anim:update(dt)
   self.dash_anim:update(dt)
   self:updateHealth(dt)
   self:changeVelocityByKeys(dt)
   self:changeVelocityByGravity(dt)
   self:playEffects()

   self:moveColliding(dt)
   self:changeVelocityByBeingOnGround(dt)
end

function Player:canFly()
  return self.health == 1
end

function Player:drawDebugInfo()
   --debug info
   love.graphics.push()
   local w,h = love.graphics.getDimensions()
   local statistics =
      ("Health: %d, Xspeed: %03d, Xaccel: %d, Yspeed: %04d, brake: %d"):format(
         self.currentHealth,
         self.vx,
         self.Xaccel,
         self.vy,
         self.brakeAccel)
   love.graphics.setColor(255, 255, 255)
   love.graphics.printf(statistics, w-550, 30, 500, 'right')
   love.graphics.pop()
end

function Player:drawWalk(sx,sy,ox,oy)
   if self.isDash then
      self.dash_anim:draw(self.img_walk, self.x, self.y, 0, sx, sy, ox, oy)
   else
      self.walk_anim:draw(self.img_walk, self.x, self.y, 0, sx, sy, ox, oy)
   end
end

function Player:drawDead(sx,sy,ox,oy)
   self:drawHurt(sx,sy,ox,oy)
end

function Player:drawFaceDirection()
   if self:isFaceRight() then
      return 1,1,0,0
   else
      return -1,1,self.w,0
   end
end

function Player:preDraw()
   if self:isDuck()  then
      self.h = ch-25
   else
      self.h = ch
   end
end

function Player:getColLen()
   return self.col_len
end

function Player:getCurrentHealth() return self.currentHealth end
function Player:getTotalHealth() return self.health end
function Player:getCoins() return self.coins end

return Player
