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

  table.insert(savestrings, string.format([[
Game.tutorial = {
  learnedAimBall = %s,
  learnedDropBall = %s,
  learnedSlomo = %s,
  learnedScore = %s,
  learnedWhiteBalls = %s,
  learnedCombo = %s,
  learnedLoseCombo = %s,
  learnedClearCombo = %s,
  learnedNewComboClearsat = %s,
  learnedCombometerScore = %s,
  learnedCombometerDrop = %s,
}

]],

      Game.tutorial.learnedAimBall and 'true' or 'false',
      Game.tutorial.learnedDropBall and 'true' or 'false',
      Game.tutorial.learnedSlomo and 'true' or 'false',
      Game.tutorial.learnedScore and 'true' or 'false',
      Game.tutorial.learnedWhiteBalls and 'true' or 'false',
      Game.tutorial.learnedCombo and 'true' or 'false',
      Game.tutorial.learnedLoseCombo and 'true' or 'false',
      Game.tutorial.learnedClearCombo and 'true' or 'false',
      Game.tutorial.learnedNewComboClearsat and 'true' or 'false',
      Game.tutorial.learnedCombometerScore and 'true' or 'false',
      Game.tutorial.learnedCombometerDrop and 'true' or 'false')
    )

  local savestring = table.concat(savestrings)
  --print(savestring)

  local file, errorstr = love.filesystem.newFile(SAVE_PATH, 'w') 
  if errorstr then 
    error(errorstr)
    return 
  end

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
