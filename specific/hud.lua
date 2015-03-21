local Class = require 'utils.class'
local global = require 'global'
local HUD = Class{
   name='hud',
}

function HUD:init(player)
   self.player = player

   local sp = global.hud_path
   local load_img = function(file)
      return love.graphics.newImage(sp ..  '/' ..file)
   end
   self.img_0 = load_img('hud_0.png')
   self.img_1 = load_img('hud_1.png')
   self.img_2 = load_img('hud_2.png')
   self.img_3 = load_img('hud_3.png')
   self.img_4 = load_img('hud_4.png')
   self.img_5 = load_img('hud_5.png')
   self.img_6 = load_img('hud_6.png')
   self.img_7 = load_img('hud_7.png')
   self.img_8 = load_img('hud_8.png')
   self.img_9 = load_img('hud_9.png')
   self.img_x = load_img('hud_x.png')
   self.img_coins = load_img('hud_coins.png')
   self.img_heart_empty = load_img('hud_heartEmpty.png')
   self.img_heart_half = load_img('hud_heartHalf.png')
   self.img_heart_full = load_img('hud_heartFull.png')
end

function HUD:drawHealth()
   local h = self.player:getCurrentHealth()
   local maxh = self.player:getTotalHealth()
   local hs = h/2
   local ox = 1
   local drawX,drawY = 20,20
   local offsetx = 53*(ox-1)+2
   for i=1,math.floor(hs) do -- draw full health
      offsetx = 53*(i-1)+2
      love.graphics.draw(
         self.img_heart_full, drawX+offsetx, drawY)
      ox=ox+1
   end

   if hs-math.floor(hs)-0.1 > 0 then -- draw half health
      offsetx = 53*(ox-1)+2
      love.graphics.draw(
         self.img_heart_half, drawX+offsetx, drawY)
      ox=ox+1
   end

   local n = maxh/2 - math.ceil(hs)
   for i=1,n do -- draw empty health
      offsetx = 53*(ox-1)+2
      love.graphics.draw(
         self.img_heart_empty, drawX+offsetx, drawY)
      ox=ox+1
   end
end

function HUD:drawNumber(num, x,y)
   local draw = love.graphics.draw
   if num == '0' then draw(self.img_0,x,y)
   elseif num == '1' then draw(self.img_1,x,y)
   elseif num == '2' then draw(self.img_2,x,y)
   elseif num == '3' then draw(self.img_3,x,y)
   elseif num == '4' then draw(self.img_4,x,y)
   elseif num == '5' then draw(self.img_5,x,y)
   elseif num == '6' then draw(self.img_6,x,y)
   elseif num == '7' then draw(self.img_7,x,y)
   elseif num == '8' then draw(self.img_8,x,y)
   elseif num == '9' then draw(self.img_9,x,y)
   end
end

function HUD:drawCoins()
   local drawX,drawY = 20,76
   local ox,oy = 0,0
   love.graphics.draw( -- draw coins label
      self.img_coins, drawX+ox, drawY)
   ox = 47+2
   oy = 10
   love.graphics.draw( -- draw x label
      self.img_x, drawX+ox, drawY+oy)
   ox = ox + 30 + 2
   oy = 5
   local c = string.format('%02d', self.player:getCoins())
   for i in c:gmatch(".") do
      self:drawNumber(i,drawX+ox,drawY+oy)
      ox = ox + 30 + 2
   end
end

function HUD:draw()
   love.graphics.push()
   self:drawHealth()
   self:drawCoins()
   love.graphics.pop()
end

return HUD
