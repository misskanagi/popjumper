local gamestate = require('utils/gamestate')
local menu = require('menu')

--platformer with TILED
local media = require('media')

-- test
local test1 = require('levels.test1')

function love.load()
   media.load()
   media.music:play()
   -- Grab window size
   windowWidth = love.graphics.getWidth()
   windowHeight = love.graphics.getHeight()

   gamestate.registerEvents()
   gamestate.switch(test1)
end

function love.update(dt)
   media.cleanup()
end

function love.resize(w, h)
   --map:resize(w, h)
end
