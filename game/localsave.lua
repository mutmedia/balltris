local Load = require 'lib/load'

local LocalSave = {}

local SAVE_PATH = 'local_data.lua'

local error = function(str)
  print('LOCAL SAVE ERROR: '..(str or ''))
end

local print = function(str)
  print('LOCAL SAVE: '..(str or ''))
end


function LocalSave.Save(game)
  local savestrings = {}

  table.insert(savestrings, string.format([[
Game.highScore = %d

]],
      game.highScore)
    )

  if Game.tutorial then
    table.insert(savestrings, [[
Game.tutorial = {}
Game.tutorial.learnedRaw = {
]])
    for k, v in pairs(Game.tutorial.learned) do
      table.insert(savestrings, string.format("\t'%s',\n", k))
    end
    table.insert(savestrings, '}')
  end
  local savestring = table.concat(savestrings)
  --print(savestring)

  local file, errorstr = love.filesystem.newFile(SAVE_PATH, 'w') 
  if errorstr then 
    error(errorstr)
    return 
  end

  print(savestring)

  local s, err = file:write(savestring)
  if err then
    error(err)
  end
end

function LocalSave.Load()
  local ok = Load.luafile(SAVE_PATH)
  if not ok then
    error('Could not find save file')
  end
end

function LocalSave.Clear()
  local ok = love.filesystem.remove(SAVE_PATH)
  if not ok then
    error('Failed to delete temporary save')
  end
end

return LocalSave
