local Class = require 'utils.class'
local Entities = require('specific/entities')
local global = require 'global'
local Sprite = Class{
   name='sprite',
   __includes = Entities
}

-- to rewrite
function Sprite:update(dt) end
function Sprite:takeCoin(other) end
function Sprite:changeLevel() end
function Sprite:highJump() end
function Sprite:touchPlayer(col) end
function Sprite:touchEnemy(col) end
function Sprite:touchTrap(col) end
function Sprite:preDraw() end
function Sprite:postDraw() end
function Sprite:dead(dt)end
-- need rewrite(animation)
function Sprite:drawWalk(sx,sy,ox,oy) end

function Sprite:init(world, x,y,w,h)
   Entities.init(self, world, x, y, w, h)

   --run properties
   self.runAccel      = 200
   self.maxRunSpeed   = 100
   self.Xaccel = self.runAccel
   self.maxSpeedX = self.maxRunSpeed

   --brake properties
   self.brakeAccel    = 2000
   self.airBrakeAccel = 168
   self.brake         = self.brakeAccel

   --jump properties
   self.jumpVelocity  = 685 -- the initial upwards velocity when jumping
   self.jumpAccel     = 1000

   --rocket properties
   self.rocketAccel   = 2500
   self.maxRocketSpeed= 300

   --sprite state
   self.STAND = 0
   self.WALK = 1
   self.JUMP = 2
   self.FLY = 3
   self.CRWAL = 4
   self.DUCK = 5
   self.DEAD = 6
   self.hurt = false -- special state
   self.spriteState = self.STAND

   --sprite face
   self.FACE_RIGHT = 0
   self.FACE_LEFT = 1
   self.spriteFace = self.FACE_RIGHT

   --filter
   self.filter = function(item, other)
      if self:isDead() then return 'cross' end
      if other.isCoin   then return 'cross'
      elseif other.isBlock  then return 'slide'
      elseif other.isPlayer then return 'slide'
      elseif other.isEnemy  then return 'slide'
      elseif other.isTrap   then return 'touch'
      elseif other.isExit   then return 'touch'
      elseif other.isSpring then return 'bounce'
      else return nil
      end
   end

   --command
   self.cmds = {} --NO_CMD
   self.UP = 1
   self.DOWN = 2
   self.LEFT = 3
   self.RIGHT = 4
   self.SPACE = 5
   self.SHOOT = 6

   --hurt related
   self.no_hurt_time = 0.8
   self.hurt_period = 0
   self.flicker_time = 0.2
   self.flicker_period = 0
   self.isFlicker = false -- internal implementation
   self.flicker = false

   local sp = global.sprite_path
   local load_img = function(file)
      return love.graphics.newImage(sp .. self.name .. '/' ..file)
   end
   local exists = function(file)
      return love.filesystem.exists(sp .. self.name .. '/' ..file)
   end
   --images
   if exists('walk.png') then
      self.img_walk = load_img('walk.png')
   end
   if exists('jump.png') then
      self.img_jump = load_img('jump.png')
   end
   if exists('stand.png') then
      self.img_stand = load_img('stand.png')
   end
   if exists('hurt.png') then
      self.img_hurt = load_img('hurt.png')
   end
   if exists('duck.png') then
      self.img_duck = load_img('duck.png')
   end
   if exists('dead.png') then
      self.img_dead = load_img('dead.png')
   end
end

function Sprite:drawAction(img, sx, sy, ox, oy)
   if img then
      love.graphics.draw(img, self.x, self.y, 0, sx, sy, ox, oy)
   end
end

function Sprite:drawStand(sx,sy,ox,oy) self:drawAction(self.img_stand,sx,sy,ox,oy) end
function Sprite:drawJump(sx, sy, ox, oy) self:drawAction(self.img_jump,sx,sy,ox,oy) end
function Sprite:drawHurt(sx, sy, ox, oy) self:drawAction(self.img_hurt,sx,sy,ox,oy) end
function Sprite:drawDuck(sx, sy, ox, oy) self:drawAction(self.img_duck,sx,sy,ox,oy) end
function Sprite:drawDead(sx, sy, ox, oy) self:drawAction(self.img_dead,sx,sy,ox,oy) end
function Sprite:drawFaceDirection()
   if self:isFaceRight() then
      return -1,1,self.w,0
   else
      return 1,1,0,0
   end
end

function Sprite:draw()
   love.graphics.push()
   self:preDraw()
   local sx,sy,ox,oy = self:drawFaceDirection()
   self:drawFlicker()
   if self:isDead() then
      self:drawDead(sx,sy,ox,oy)
   elseif self:isHurt() then
      self:drawHurt(sx,sy,ox,oy)
   elseif self:isStand() then
      self:drawStand(sx,sy,ox,oy)
   elseif self:isWalk() then
      self:drawWalk(sx,sy,ox,oy)
   elseif self:isJump() then
      self:drawJump(sx,sy,ox,oy)
   elseif self:isDuck() then
      self:drawDuck(sx,sy,ox,oy)
   end

   self.world:update(self, self.x, self.y, self.w, self.h)
   self:postDraw()
   love.graphics.pop()
end

function Sprite:updateHurt(dt)
   if self:isHurt() then
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

function Sprite:drawFlicker()
   if self.isFlicker then -- flicker when hurt
      love.graphics.setColor(255,255,255,160)
   else
      love.graphics.setColor(255,255,255,255)
   end
end

function Sprite:hasCommand(cmd)
   for _,c in pairs(self.cmds) do
      if c==cmd then return true end
   end
   return false
end

function Sprite:giveCommand(cmd)
   table.insert(self.cmds, cmd)
end

function Sprite:changeVelocityByCmds(dt)
   self.isJumpingOrFlying = false
   if self:isDead() then self:dead(dt) return end
   local vx, vy = self.vx, self.vy
   self.stand = true
   -- brake in the air and on the ground is different
   if self:isJump() then
      self.brake = dt * (vx < 0 and self.airBrakeAccel or -self.airBrakeAccel)
   else
      self.brake = dt * (vx < 0 and self.brakeAccel or -self.brakeAccel)
   end

   if self:hasCommand(self.LEFT) then -- move left
      self.stand = false
      vx,vy = self:leftAccel(dt, vx, vy)
   elseif self:hasCommand(self.RIGHT) then -- move right
      self.stand = false
      vx,vy = self:rightAccel(dt, vx, vy)
   end

   if self:hasCommand(self.UP) then -- fly up
      self.stand = false
      vy = self:fly(dt, vy)
   elseif self:hasCommand(self.DOWN) then -- duck or fly down
      self.stand = false
      vy = self:duck(dt, vy)
   else
      vy = self:notFly(dt, vy)
   end

   if self:hasCommand(self.SPACE) then -- jump
      self.stand = false
      vy = self:jump(dt, vy)
   end

   if self.stand then
      if self.onGround then self:setSpriteState('stand') end
      if math.abs(self.brake) > math.abs(vx) then
         vx = 0
      else
         vx = vx + self.brake
      end
   end

   self.cmds = {} -- clear all commands

   self.vx, self.vy = vx, vy
end

function Sprite:leftAccel(dt, vx, vy)
   self:setSpriteFace('left')
   if self.onGround then self:setSpriteState('walk')
   else self:setSpriteState('jump') end
   if math.abs(vx) <= self.maxSpeedX or vx > 0 then
      vx = vx - dt * (vx > 0 and self.brakeAccel or self.Xaccel)
   end
   return vx,vy
end

function Sprite:rightAccel(dt, vx, vy)
   self:setSpriteFace('right')
   if self.onGround then self:setSpriteState('walk')
   else self:setSpriteState('jump') end
   if math.abs(vx) <= self.maxSpeedX or vx < 0 then
      vx = vx + dt * (vx < 0 and self.brakeAccel or self.Xaccel)
   end
   return vx,vy
end

function Sprite:duck(dt, vx)
   self:setSpriteState('duck')
   if math.abs(self.brake) > math.abs(vx) then
      vx = 0
   else
      vx = vx + self.brake
   end
   return vx
end

function Sprite:notFly(dt, vy) return vy end

function Sprite:jump(dt, vy)
   self:setSpriteState('jump')
   vy = -self.jumpVelocity
   self.isJumpingOrFlying = true
   return vy
end

function Sprite:fly(dt, vy)
   self:setSpriteState('jump')
   if math.abs(self.vy) <= self.maxRocketSpeed then
      vy = vy + -self.rocketAccel * dt
   end
   self.isJumpingOrFlying = true
   return vy
end

function Sprite:changeVelocityByBeingOnGround()
   if self.onGround then
      self.vy = math.min(self.vy, 0)
   end
end

function Sprite:checkIfOnGround(ny, col_type)
   if ny < 0 and col_type == 'slide' then
      self.onGround = true
   end
end

function Sprite:moveColliding(dt)
   self.onGround = false
   local world = self.world

   local future_l = self.x + self.vx * dt
   local future_t = self.y + self.vy * dt

   local next_l, next_t, cols, len = world:move(self, future_l, future_t,self.filter)
   self.col_len = len

   for i=1, len do
      local col = cols[i]
      local other = col.other
      if other.isCoin then
         self:takeCoin(col.other)
      elseif other.isPlayer then
         self:touchPlayer(col)
      elseif other.isEnemy then
         self:touchEnemy(col)
      elseif other.isTrap then
         self:touchTrap(col)
      elseif other.isExit then
         self:changeLevel()
      elseif other.isSpring then
         self:highJump()
      end

      if col.type == 'slide' then
         self:changeVelocityByCollisionNormal(
            col.normal.x, col.normal.y)
      end
      self:checkIfOnGround(col.normal.y, col.type)
   end
   self.x, self.y = next_l, next_t
end

-- check state
function Sprite:isStand() return self.spriteState == self.STAND end
function Sprite:isWalk() return self.spriteState == self.WALK end
function Sprite:isJump() return self.spriteState == self.JUMP end
function Sprite:isDuck() return self.spriteState == self.DUCK end
function Sprite:isDead() return self.spriteState == self.DEAD end
function Sprite:isHurt() return self.hurt end

function Sprite:setSpriteState(state)
   if state=='stand' then
      self.spriteState=self.STAND
   elseif state=='walk' then
      self.spriteState=self.WALK
   elseif state=='jump' then
      self.spriteState=self.JUMP
   elseif state=='fly' then
      self.spriteState=self.FLY
   elseif state=='duck' then
      self.spriteState=self.DUCK
   elseif state=='dead' then
      self.spriteState=self.DEAD
   end
end

function Sprite:isFaceLeft() return self.spriteFace == self.FACE_LEFT end
function Sprite:isFaceRight() return self.spriteFace == self.FACE_RIGHT end

function Sprite:setSpriteFace(face)
   if face=='right' then
      self.spriteFace=self.FACE_RIGHT
   else
      self.spriteFace=self.FACE_LEFT
   end
end

return Sprite
