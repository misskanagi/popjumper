local Class = require 'utils.class'
local Sprite = require('specific/sprite')
local global = require 'global'

local Enemy = Class{
   name='enemy',
   ctype='touch',
   isEnemy = true,
   __includes = Sprite
}

function Enemy:init(world, x, y, w, h)
   Sprite.init(self, world, x, y, w, h)

   self.targetInRadius = false
   self.detectRadius  = 300

   --patrol implement
   self.patrolCMD = self.LEFT
   self.patrolCount = 0

   --death remove
   self.isRemovable = false
   self.removeCount = 0
end

function Enemy:touchTrap(col)
   col.other:doDamage(col.normal.x, col.normal.y, self)
end

function Enemy:touchPlayer(col)
   if self:isDead() then return end
   if(col.normal.x ~= 0) or (col.normal.y < 0) then -- attack player
      if col.other:hurting() then return end
      col.other:takeDamage(1)
      col.other:ouch(self.spriteFace == self.FACE_RIGHT and 1 or -1)
   elseif(col.normal.y > 0) then -- attack by player
      col.other:bounce(1.1)
      self:ouch()
      self:takeDamage(10)
   end
end

function Enemy:takeDamage(amount)
   if amount > self.health then
      self.health = 0
   else
      self.health = self.health - amount
   end
end

function Enemy:canRemove() return self.isRemovable end

function Enemy:updateHealth(dt)
   if self.health <= 0 then
      self.health = 0
      if not self:isDead() then
         self:setSpriteState('dead')
      end
      if self.removeCount > 2 then
         self.isRemovable = true
         self.removeCount = 0
      else
         self.removeCount = self.removeCount + dt
      end
   end
end

function Enemy:detectPlayer(dt)
   local cx,cy = self.target:pos()
   local dx = cx - self.x
   local dy = cy - self.y
   local dist2 = dx*dx + dy*dy
   if dist2 <= self.detectRadius*self.detectRadius then
      if not self.targetInRadius then
         print('entering radius')
      end
      self.targetInRadius = true
   else
      self.targetInRadius = false
   end
end

function Enemy:chasePlayer(dt)
   local cx,cy = self.target:pos()
   if cx-self.x < -5 then -- move horizontally
      self:giveCommand(self.LEFT)
   elseif cx-self.x > 5 then
      self:giveCommand(self.RIGHT)
   end
   if cy-self.y < -5 then -- move vertically
      self:giveCommand(self.UP)
   elseif cy-self.y > 5 then
      self:giveCommand(self.DOWN)
   end
end

function Enemy:patrol(dt)
   self.patrolCount = self.patrolCount+dt
   if self.patrolCount > 2 then
      self.patrolCount = 0
      if self.patrolCMD == self.LEFT then
         self.patrolCMD = self.RIGHT
      else
         self.patrolCMD = self.LEFT
      end
   end
   self:giveCommand(self.patrolCMD)
end

function Enemy:drawDetectRadius()
   --detect radius
   if global.debug then
      local sx,sy = self:getCenter()
      local cx,cy = self.target:getCenter()
      love.graphics.setColor(180,100,98)
      love.graphics.circle('line', sx, sy, self.detectRadius)
      if self.targetInRadius then
         love.graphics.line(cx, cy, sx, sy)
      end
   end
end

function Enemy:postDraw()
   self:drawDetectRadius()
end

function Enemy:dead(dt)
   local brake = dt * (self.vx < 0 and self.airBrakeAccel or -self.airBrakeAccel)
   self.gravityAccel = global.gravity
   if math.abs(brake) > math.abs(self.vx) then
      self.vx = 0
   else
      self.vx = self.vx + brake
   end
end

function Enemy:takeForce(fx,fy,nx,ny,factor) -- to be pushed
   local vx, vy = self.vx, self.vy
   local abs = math.abs
   if nx > 0 then vx = vx + abs(fx)*(factor or 0.2) end
   if nx < 0 then vx = vx - abs(fx)*(factor or 0.2) end
   if ny > 0 then vy = vy + abs(fy)*(factor or 0.2) end
   if ny < 0 then vy = vy - abs(fy)*(factor or 0.2) end
   self.vx,self.vy=vx,vy
end

return Enemy
