--[[
-- media file
-- This file loads and controls all the sounds of the game.
-- * media.load() reads the sounds from the disk. It must be called before
--   the sounds or music are used
-- * media.music contains a source with the music
-- * media.sfx.* contains multisources (see lib/multisource.lua)
-- * media.cleanup liberates unused sounds.
-- * media.countInstances counts how many sound instances are there in the
--   system. This is used for debugging
]]

local multisource = require 'libraries.multisource'
local media = {}

local function newSource(name)
  local path = 'assets/sfx/' .. name .. '.ogg'
  local source = love.audio.newSource(path)
  if name == 'slime_death' then -- volume fix
     source:setVolume(1)
  elseif name == 'player_death' then
     source:setVolume(0.5)
  elseif name == 'coin' then
     source:setVolume(0.05)
  else
     source:setVolume(0.1)
  end
  return multisource.new(source)
end

media.load = function()
  local names = [[
    explosion
    grenade_wall_hit
    guardian_death guardian_shoot guardian_target_acquired
    player_jump player_full_health player_propulsion
    player_hurt player_death coin slime_death boing
  ]]

  love.audio.setVolume(1)
  media.sfx = {}
  for name in names:gmatch('%S+') do -- ogg
     media.sfx[name] = newSource(name)
  end

  media.sfx.player_propulsion:setLooping(true)

  media.music = love.audio.newSource('assets/sfx/nature.mp3')
  media.music:setVolume(0.7)
  media.music:setLooping(true)
end

media.cleanup = function()
  for _,sfx in pairs(media.sfx) do
    sfx:cleanup()
  end
end

media.countInstances = function()
  local count = 0
  for _,sfx in pairs(media.sfx) do
    count = count + sfx:countInstances()
  end
  return count
end


return media
