local Load = require 'lib/load'

local LocalSave = {}

local SAVE_PATH = 'local_data.lua'

local error = function(str)
  print('LOCAL SAVE ERROR: '..(str or ''))
end

local print = function(str)
  print('LOCAL SAVE: '..(str or ''))
end

function serialize (o)
  local str = {}
  if type(o) == 'number' then
    table.insert(str, o)
  elseif type(o) == 'string' then
    table.insert(str, string.format('%q', o))
  elseif type(o) == 'table' then
    table.insert(str, '{\n')
    for k,v in pairs(o) do
      table.insert(str, '\t['..serialize(k)..'] = ')
      table.insert(str, serialize(v))
      table.insert(str, ',\n')
    end
    table.insert(str, '}\n')
  else
    error('cannot serialize a ' .. type(o))
  end
  return table.concat(str)
end

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


local savestring = table.concat(savestrings)
--print(savestring)

local file, errorstr = love.filesystem.newFile(SAVE_PATH, 'w') 
if errorstr then 
  error(errorstr)
  return 
end

print('Save file contents: ////')
print(savestring)
print('////////////////////////')

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
