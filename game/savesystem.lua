--TODO: save last loaded file to prevent loading a lot of times

local Load = require 'lib/load'
local Balls = require 'balls'
local Queue = require 'lib/queue'
local RandomBag = require 'lib/randombag'

local SaveSystem = {}

local SAVE_PATH = 'save_temp.lua'


function SaveSystem.save(game)
  local savestring = {}
  table.insert(savestring,
    [[
local rawGame = {}
rawGame.objects = {}
]]
    )

  -- Scores
  table.insert(savestring, string.format(
      [[

rawGame.score = %d
rawGame.maxCombo = %d
]],
      game.score,
      game.maxCombo)
    )

  -- Ball Preview
  table.insert(savestring, string.format([[

rawGame.objects.ballPreview = {
  number = %d,
  radius = %f,
  indestructible = %s,
}
    ]], 
      game.objects.ballPreview.number,
      game.objects.ballPreview.radius,
      game.objects.ballPreview.indestructible and 'true' or 'false')
    )

  -- Next Ball Previews
  table.insert(savestring, [[

rawGame.objects.nextBallPreviews = {
]])

  game.objects.nextBallPreviews:forEach(function(nextBallPreview)
    table.insert(savestring, string.format([[
  {
    number = %d,
    radius = %f,
    indestructible = %s,
  },
]],
        nextBallPreview.number,
        nextBallPreview.radius,
        nextBallPreview.indestructible and 'true' or 'false')
      )
  end)

  table.insert(savestring, [[
}
]])


  -- Balls
  table.insert(savestring, [[

rawGame.objects.balls = {
]])

  game.objects.balls:forEach(function(ball)
    table.insert(savestring, string.format([[
  {
    position = {
      x = %f, y = %f,
    },
    number = %d,
    radius = %f,
    indestructible = %s,
  },
]],
        ball.body:getX(), ball.body:getY(),
        ball.number,
        ball.radius,
        ball.indestructible and 'true' or 'false')
      )
  end)

  table.insert(savestring, [[
}
]])

  -- Random bags
  table.insert(savestring, string.format([[

rawGame.ballChances = {
  size = %d,
  modifier = %f,
  values = %s,
}
]],
      game.ballChances.size,
      game.ballChances.modifier,
      game.ballChances:toString())
    )

  table.insert(savestring, string.format([[

rawGame.radiusChances = {
  size = %d,
  modifier = %f,
  values = %s,
}
]],
      game.radiusChances.size,
      game.radiusChances.modifier,
      game.radiusChances:toString())
    )

  table.insert(savestring, [[

return rawGame
]])

  local saveconcat = table.concat(savestring)
  --print(saveconcat)

  local file, errorstr = love.filesystem.newFile(SAVE_PATH, 'w') 
  if errorstr then 
    print('SAVE SYSTEM ERROR: '..errorstr)
    return 
  end

  local s, err = file:write(saveconcat)
  if err then
    print('SAVE SYSTEM ERROR: '..err)
  end
end

function SaveSystem.clearSave()
  local ok = love.filesystem.remove(SAVE_PATH)
  if not ok then
    print('SAVE SYSTEM ERROR: Failed to delete temporary save')
  end
  
end

function SaveSystem.CreateLoadFunc()
  local ok, rawGame = Load.luafile(SAVE_PATH)

  if not ok or not rawGame then return end

  return function(game)

    local savedGame = game
    savedGame.objects = {}

    -- Score and MaxCombo
    savedGame.score = rawGame.score
    savedGame.maxCombo = rawGame.maxCombo

    -- ballPreview
    savedGame.objects.ballPreview = Balls.NewBallPreview(rawGame.objects.ballPreview)

    -- nextBallPreviews
    savedGame.objects.nextBallPreviews = Queue.new()
    for _, ballPreviewData in ipairs(rawGame.objects.nextBallPreviews) do
      savedGame.objects.nextBallPreviews:enqueue(Balls.NewBallPreview(ballPreviewData))
    end

    -- balls
    savedGame.objects.balls = Balls.NewList()
    for _, ballData in ipairs(rawGame.objects.balls) do
      local newBall = Balls.newBall(ballData, game.world)
      savedGame.objects.balls:add(newBall)
    end

    -- Random Bags
    savedGame.ballChances = RandomBag.new(
      rawGame.ballChances.size,
      rawGame.ballChances.modifier,
      rawGame.ballChances.values)

    savedGame.radiusChances = RandomBag.new(
      rawGame.radiusChances.size,
      rawGame.radiusChances.modifier,
      rawGame.radiusChances.values)

    return savedGame
  end
end


return SaveSystem
