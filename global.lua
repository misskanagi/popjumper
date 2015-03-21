local Class = require 'utils.class'
local Global = Class{
   debug = false,
   name='global',
   sprite_path='assets/sprites/',
   item_path='assets/items/',
   hud_path='assets/hud/',
   trap_path='assets/trap/',
   gravity = 2000,
   cellsize = 70,
   tileWidth = 70,
   tileHeight = 70,

   --internal useage
   free_camera = false
}

return Global
