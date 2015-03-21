local Class = require 'utils.class'
local global = require 'global'
local Item = require 'specific.item'
local Coin = Class{
   name='coin',
   isCoin = true,
   coinType = 'bronze',
   __includes = Item
}

local cw = 70
local ch = 70

function Coin:init(type, map, world, x,y)
   Item.init(self, world, x,y,cw,ch)
   self.map = map
   self.r = 0

   self.coinType = type
   local sp = global.item_path
   if self.coinType == 'bronze' then
      self.img = love.graphics.newImage(sp .. self.name .. '/bronze.png')
   elseif self.coinType == 'silver' then
      self.img = love.graphics.newImage(sp .. self.name .. '/silver.png')
   elseif self.coinType == 'gold' then
      self.img = love.graphics.newImage(sp .. self.name .. '/gold.png')
   end
end

function Coin:takenByPlayer()
   self.img = nil
end

function Coin:update(dt) end

return Coin
