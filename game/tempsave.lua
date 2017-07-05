--TODO: save last loaded file to prevent loading a lot of times

local Load = require 'lib/load'
local Balls = require 'balls'
local Queue = require 'lib/queue'
local RandomBag = require 'lib/randombag'

local TempSave = {}

local SAVE_PATH = 'save_temp.lua'

local error = function(str)
  return print('TEMP SAVE ERROR: '..(str or ''))
end

function TempSave.Save(game)
  if game.inState(STATE_GAME_RUNNING) then return end
  local savestrings = {}
  table.insert(savestrings,
    [[
local rawGame = {}
rawGame.objects = {}
]]
    )

  -- Scores
  table.insert(savestrings, string.format(
      [[

rawGame.score = %d
rawGame.maxCombo = %d
]],
      game.score,
      game.maxCombo)
    )

  -- Ball Preview
  table.insert(savestrings, string.format([[

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
  table.insert(savestrings, [[

rawGame.objects.nextBallPreviews = {
]])

  game.objects.nextBallPreviews:forEach(function(nextBallPreview)
    table.insert(savestrings, string.format([[
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

  table.insert(savestrings, [[
}
]])


  -- Balls
  table.insert(savestrings, [[

rawGame.objects.balls = {
]])

  game.objects.balls:forEach(function(ball)
    table.insert(savestrings, string.format([[
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

  table.insert(savestrings, [[
}
]])

  -- Random bags
  table.insert(savestrings, string.format([[

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

  table.insert(savestrings, string.format([[

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

  table.insert(savestrings, [[

return rawGame
]])

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

function TempSave.Clear()
  local ok = love.filesystem.remove(SAVE_PATH)
  if not ok then
    error('Failed to delete temporary save')
  end
end

function TempSave.CreateLoadFunc()
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
    savedGame.objects.nextBallPreviews = Queue.New()
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
    savedGame.ballChances = RandomBag.New(
      rawGame.ballChances.size,
      rawGame.ballChances.modifier,
      rawGame.ballChances.values)

    savedGame.radiusChances = RandomBag.New(
      rawGame.radiusChances.size,
      rawGame.radiusChances.modifier,
      rawGame.radiusChances.values)

    return savedGame
  end
end


return TempSave
