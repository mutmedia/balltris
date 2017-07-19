local Game = require 'game'

function Game.InitilizeStats()
  Game.stats = {
    totalBalls = 0,
    whiteCleared = 0,
    ballsCleared = 0,
    bestCombo = 0,
    timesCleared = 0,
    slomoTime = 0,
    score = 0,
    frequency = 0
  }
end

function Game.SetEndGameStats()
  Game.stats.slomoTime = Game.slomoPlayTime/Game.playTime * 100
  Game.stats.frequency = Game.stats.totalBalls/Game.playTimeScaled
end

function Game.SetStatsEvents()
  Game.events.add(EVENT_DROPPED_BALL, function()
      Game.stats.totalBalls = Game.stats.totalBalls + 1
  end)

  Game.events.add(EVENT_CLEARED_BALL, function(ball)
    Game.stats.ballsCleared = Game.stats.ballsCleared + 1
    if ball.indestructible then
      Game.stats.whiteCleared =  Game.stats.whiteCleared + 1
    end
  end)

  Game.events.add(EVENT_COMBO_END, function()
    Game.stats.bestCombo = math.max(Game.stats.bestCombo, Game.combo)
  end)

  Game.events.add(EVENT_COMBO_CLEARED, function()
    Game.stats.timesCleared = Game.currentObjectiveNumber
  end)

  Game.events.add(EVENT_BALLS_TOO_HIGH, function()
    Game.SetEndGameStats()
  end)

  Game.events.add(EVENT_SCORED, function()
    Game.stats.score = Game.score
  end)
end

Game.InitilizeStats()

