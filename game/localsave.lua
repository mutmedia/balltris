local Load = require 'lib/load'
local Checksum = require 'checksum'
local LocalSave = {}

local SAVE_PATH = 'local_data_v'..VERSION..'.lua'

local error = function(str)
  print('LOCAL SAVE ERROR: '..(str or ''))
end

local print = function(str)
  print('LOCAL SAVE: '..(str or ''))
end

local serialize = require 'lib/serialize'

function LocalSave.Save(game)
  local savestrings = {}

  table.insert(savestrings, string.format('Game.number = %s\n', game.number or 0))

  if game.highscore then
    table.insert(savestrings, [[
Game.highscore = ]])
    table.insert(savestrings, serialize(game.highscore))
  end

  if game.usernameText then
    table.insert(savestrings, string.format([[
Game.usernameText = '%s' 
]]
      , game.usernameText))
  end

  -- TUTORIAL
  if game.tutorial then
    table.insert(savestrings, [[
Game.tutorial = {}
Game.tutorial.learnedRaw = {
]])
    for k, v in pairs(game.tutorial.learned) do
      table.insert(savestrings, string.format("\t'%s',\n", k))
    end
    table.insert(savestrings, '}\n')
  end

  -- OPTIONS
  if game.options then
    table.insert(savestrings, [[
Game.options = ]])
    table.insert(savestrings, serialize(game.options))
  end

  -- Achievements
  if game.achievements then
    table.insert(savestrings, [[
Game.achievements = {}
Game.achievements.achievedNumsRaw = 
]])
    table.insert(savestrings, serialize(game.achievements.achievedNums))
  end

  local savestring = table.concat(savestrings)
  Checksum.SaveWith(SAVE_PATH, savestring)
end

function LocalSave.Load()
  local ok = Checksum.LoadWith(SAVE_PATH)
  if not ok then
    error('Could not load save file')
  end
end

function LocalSave.Clear()
  local ok = love.filesystem.remove(SAVE_PATH)
  if not ok then
    error('Failed to delete temporary save')
  end
end

return LocalSave
