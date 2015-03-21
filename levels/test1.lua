--platformer with TILED
local sti = require('libraries/STI')
local anim8 = require('libraries/anim8/anim8')
local bump = require('libraries/bump/bump')
local bump_debug = require('libraries/bump/bump_debug')
local player = require('specific/player')
local slime = require('specific/slime')
local bee = require('specific/bee')
local frog = require('specific/frog')
local spider = require('specific/spider')
local coin = require('specific/coin')
local ripper = require('specific/ripper')

local hud = require('specific/hud')
local media = require('media')

local Fence = require('specific.fence')
local Brick = require('specific.brick')
local camera = require('utils.camera')
local global = require('global')

local test1 = {}

local map-- = sti.new("maps/map01")
local world-- = bump.newWorld(global.cellsize)
local timer = require('utils.timer')

local function drawWorldCollision(world)
   local items, len = world:getItems()
   for i=1,len do
      t = items[i]
      love.graphics.rectangle("line", t.x, t.y, t.w, t.h)
   end
end

function test1:createPlayer(p)
   return player(map, world, p.x, p.y)
end

function test1:createEnemy(e, player)
   local p = e.properties['enemyType']
   if p == 'slime' then
      return slime(map, player, world, e.x, e.y)
   elseif p == 'frog' then
      return frog(map, player, world, e.x, e.y)
   elseif p == 'spider' then
      return spider(map, player, world, e.x, e.y)
   elseif p == 'bee' then
      return bee(map, player, world, e.x, e.y)
   end
end

function test1:loadSprites(layer)
   local o = layer.objects
   local sprites = {}
   local player
   for _, v in ipairs(o) do
      if v.type == 'player' then
         player = self:createPlayer(v)
         sprites.player = player
      elseif v.type == 'enemy' then
         table.insert(sprites, self:createEnemy(v,player))
      end
   end
   return sprites
end

function test1:createCoin(c)
   local p = c.properties['coinType']
   return coin(p,map,world,c.x,c.y)
end

function test1:loadItems(layer)
   local o = layer.objects
   local items = {}
   for _, v in ipairs(o) do
      if v.type == 'coin' then
         table.insert(items, self:createCoin(v))
      end
   end
   return items
end

function test1:loadTraps(layer)
   local o = layer.objects
   local traps = {}
   for _, v in ipairs(o) do
      if v.type == 'ripper' then
         table.insert(traps, ripper(world,v.x,v.y,v.width,v.height))
      end
   end
   return traps
end

function test1:loadTiles(layer)
   for i, tiles in pairs(layer.data) do
      for j, tile in pairs(tiles) do
         local btype = map:getTilePropertiesById(tile.id)['btype']
         local x = j*tile.width+tile.offset.x
         local y = i*tile.height+tile.offset.y
         local w = tile.width
         local h = tile.height
         local obj
         if btype == 'fence' then
            fw = w/3
            obj = Fence(map, world, x, y)
         elseif btype == 'halfbrick' then
            obj = Brick(map, world, x, y, w, h, true)
         else
            obj = Brick(map, world, x, y, w, h)
         end
      end
   end
end

function test1:loadSpriteLayer()
   local spritesLayer = map.layers["sprites"]
   spritesLayer.sprites = self:loadSprites(spritesLayer)

   -- Update callback for Custom Layer
   function spritesLayer:update(dt)
      for _, sprite in pairs(self.sprites) do
         sprite:update(dt)
      end
   end

   -- Draw callback for Custom Layer
   function spritesLayer:draw()
      for _, sprite in pairs(self.sprites) do
         sprite:draw()
      end
   end
end

function test1:loadItemLayer()
   local itemsLayer = map.layers["items"]
   itemsLayer.items = self:loadItems(itemsLayer)

   -- Update callback for Custom Layer
   function itemsLayer:update(dt)
      for _, i in pairs(self.items) do
         i:update(dt)
      end
   end

   -- Draw callback for Custom Layer
   function itemsLayer:draw()
      for _, i in pairs(self.items) do
         i:draw()
      end
   end
end

function test1:loadTrapLayer()
   local trapsLayer = map.layers["traps"]
   trapsLayer.traps = self:loadTraps(trapsLayer)

   -- Update callback for Custom Layer
   function trapsLayer:update(dt)
      for _, i in pairs(self.traps) do
         i:update(dt)
      end
   end

   -- Draw callback for Custom Layer
   function trapsLayer:draw()
      for _, i in pairs(self.traps) do
         i:draw()
      end
   end
end

function test1:init()
   self.resetCount = 0
   self.resetTime = 2
   self:reset()


   --set camera
   local p = map.layers['sprites'].sprites.player
   local x,y = p:pos()
   cam = camera(x, y)
end

function test1:reset()
   map = sti.new("maps/map01")
   world = bump.newWorld(global.cellsize)

   self:loadSpriteLayer()
   self:loadItemLayer()
   self:loadTrapLayer()

   -- init hud
   self.hud = hud(map.layers['sprites'].sprites.player)
   -- load all tiles
   l = map.layers['ground']
   self:loadTiles(l)
end

function test1:removeDeadSprites()
   local sprites = map.layers['sprites'].sprites

   for i,s in ipairs(sprites) do
      if s:canRemove() then
         table.remove(sprites, i)
         world:remove(s)
      end
   end
end

function test1:checkIfCamWillHitEdge(cx, cy)
   local ex,ey = false,false
   local sw,sh = love.graphics.getDimensions()
   if cx-sw/2 < 70 then
      ex=true
   end
   if cx+sw/2 > map.width*map.tilewidth-70 then
      ex = true
   end
   if cy-sh/2 < 70 then
      ey=true
   end
   if cy+sh/2 > map.height*map.tileheight-70 then
      ey = true
   end
   return ex,ey
end

function test1:update(dt)
   -- Update sprite's coordinates
   local sprite = map.layers["sprites"].sprites.player
   -- local down = love.keyboard.isDown
   map:update(dt)
   --timer.update(dt)

   -- move camera
   if global.debug then
      self:moveCamera()
   end

   if not sprite:isDead() and not global.free_camera then
      local x,y = sprite:getCenter()
      local dx,dy = x - cam.x, y - cam.y
      local ex,ey = self:checkIfCamWillHitEdge(x,y)
      cam:move(ex and 0 or dx/10, ey and 0 or dy/15)
   end
   -- game reset if player is dead
   if sprite:isDead() then
      if self.resetCount > self.resetTime then
         self.resetCount = 0
         self:reset()
      else
         self.resetCount = self.resetCount + dt
      end
   end

   self:removeDeadSprites()
end

function test1:moveCamera()
   local pushed = false
   if love.keyboard.isDown('w') then
      local x,y = cam:pos()
      cam:lookAt(x,y-10)
      pushed = true
   elseif love.keyboard.isDown('s') then
      local x,y = cam:pos()
      cam:lookAt(x,y+10)
      pushed = true
   end
   if love.keyboard.isDown('a') then
      local x,y = cam:pos()
      cam:lookAt(x-10,y)
      pushed = true
   elseif love.keyboard.isDown('d') then
      local x,y = cam:pos()
      cam:lookAt(x+10,y)
      pushed = true
   end
   if pushed then
      global.free_camera = true
   else
      global.free_camera = false
   end
end

function test1:draw()
   cam:attach()
   local sprite = map.layers["sprites"].sprites.player
   local imageLayer = map.layers["background image"]
   local iw,ih = imageLayer.image:getDimensions()
   local x,y = sprite:pos()
   local cx,cy = cam:pos()
   local fx = cx/(map.width*map.tilewidth)
   local fy = cy/(map.height*map.tileheight)
   local nx = iw*fx
   local ny = ih*fy

   local sw,sh = love.graphics.getDimensions()

   local tx = cx-nx
   local ty = cy-ny

   -- parallax background
   if ty+ih<cy+sh/2 then ty=cy+sh/2-ih end
   if tx+iw<cx+sw/2 then tx=cx+sw/2-iw end
   if ty>cy-sh/2 then ty=cy-sh/2 end
   if tx>cx-sw/2 then tx=cx-sw/2 end
   imageLayer.x = tx--imageLayer.x/2
   imageLayer.y = ty--imageLayer.y/2

   map:draw()

   if global.debug then
      drawWorldCollision(world)
      --bump_debug.draw(world)
   end

   cam:detach()

   -- HUD
   self.hud:draw()

   if global.debug then
      local statistics =
         ("fps: %d, mem: %dKB, collisions: %d, items: %d, sfx: %d"):format(
            love.timer.getFPS(),
            collectgarbage("count"),
            sprite:getColLen(),
            world:countItems(),                                              media.countInstances())
      love.graphics.setColor(255, 255, 255)
      love.graphics.printf(statistics, sw-450, sh-30, 400, 'right')

      --player debug info
      sprite:drawDebugInfo()
      --camera info
      local caminfo =
         ("camX: %04d, camY: %04d, playerX: %04d, playerY: %04d"):format(
            cx,cy,x,y)
      love.graphics.printf(caminfo, 20, sh-30, 400, 'left')
   end
end

function test1:keypressed(key)
end

function test1:keyreleased(key)
   if key == '`' then
      global.debug = not global.debug
   end
   --map.layers["Sprite Layer"].sprites.player:keyreleased(key)
end

return test1
