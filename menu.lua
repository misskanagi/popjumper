local menu = {}
local selection = 0
local camera = require('utils.camera')
local cam = camera(100,100, 2, math.pi/2)

function menu:init()
end

function menu:update(dt)
   cam:move(dt * 5, dt * 6)
end

function menu:draw()
   love.graphics.setColor(0, 255, 0, 255)

   if selection == 0 then
      love.graphics.print("> start", 300, 200)
   else
      love.graphics.print("  start", 300, 200)
   end

   if selection == 1 then
      love.graphics.print("> options", 300, 250)
   else
      love.graphics.print("  options", 300, 250)
   end

   if selection == 2 then
      love.graphics.print("> quit", 300, 300)
   else
      love.graphics.print("  quit", 300, 300)
   end
end

function menu:keyreleased(key)
   if key == 'up' then
      selection = (selection - 1)%3
   elseif key == 'down' then
      selection = (selection + 1)%3
   elseif key == 'return' or key == ' ' then
      if(selection == 0) then
      end
      if(selection == 2) then
         love.event.quit()
      end
   end
end

return menu
