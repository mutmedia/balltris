--[[ Template
(
[P + (N-1)%5] = {
    name = '',
    description = '',
    event = EVENT_,
    condition = function()
    end,
  }
)
]]--
ACHIEVEMENTS_PER_PAGE = 5
GAME_ACHIEVEMENTS = {
  -- Important Page
  {
    name = 'Strategist',
    description = 'Spend most of your game in slow motion (70%)',
    event = EVENT_GAME_OVER,
    condition = function()
      return Game.stats.slomoTime >= 70
    end,
  },
  {
    name = 'Bad Meta',
    description = 'Lose a game during your first combo higher than 30',
    event = EVENT_BALLS_TOO_HIGH,
    condition = function()
      if not Game.comboList[1] then return false end
      for k, v in ipairs(Game.comboList) do
        if v > 30 then
          return k == #Game.comboList
        end
      end
    end,
  },
  {
    name = 'Good Meta',
    description = 'Make two combos of at least 30 in a single game',
    event = EVENT_BALLS_TOO_HIGH,
    condition = function()
      if not Game.comboList[1] then return false end
      local combo30count = 0
      for _, v in ipairs(Game.comboList) do
        if v >= 30 then
          combo30count = combo30count + 1
        end
      end
      return combo30count > 1
    end,
  },
  {
    name = 'That save',
    description = 'Lose a combo of \nat least 20 and then \nclear the gray balls',
    event = EVENT_COMBO_CLEARED,
    condition = function()
      if not Game.comboList[1] then return false end
      for _, v in ipairs(Game.comboList) do
        print(v)
        if v >= 20 then
          return true
        end
      end
      return false
    end,
  },
  {
    name = 'Getting Good',
    description = 'Score more than 4000 points',
    event = EVENT_SCORED,
    condition = function()
      return Game.score > 4000
    end,
  },

  -- Misc page
  {
    name = 'Combo boost',
    description = 'Group 5 balls at the same time',
    event = EVENT_STREAK,
    condition = function(streak)
      return streak == 5
    end,
  },
  {
    name = 'Balltris v0',
    description = 'Finish the game without destroying any balls',
    event = EVENT_BALLS_TOO_HIGH,
    condition = function()
      return Game.stats.ballsCleared == 0
    end,
  },
  {
    name = 'Super Balltris',
    description = 'Finish the game dropping 30 or less balls',
    event = EVENT_GAME_OVER,
    condition = function()
      return Game.stats.totalBalls <= 30
    end
  },
  {
    name = 'sllabhtnyS',
    description = 'Finish the game with 0 points',
    event = EVENT_GAME_OVER,
    condition = function()
      return Game.stats.score == 0
    end,
  },
  {
    name = 'R N Jesus',
    description = 'Score more than 2500 points playing very fast',
    event = EVENT_GAME_OVER,
    condition = function()
      return Game.stats.score >= 2500 and Game.stats.frequency >= 3.5 and Game.stats.slomoTime <= 25
    end,
  },

  -- White balls page
  {
    name = '50 shades of gray',
    description = 'Destroy 50 gray balls',
    event = EVENT_CLEARED_BALL,
    condition = function()
      return Game.stats.whiteCleared >= 50
    end,
  },
  {
    name = 'Gray Anatomy',
    description = 'Destroy 80 gray balls',
    event = EVENT_CLEARED_BALL,
    condition = function()
      return Game.stats.whiteCleared >= 80
    end,
  },
  {
    name = 'Grayveyard',
    description = 'Destroy 120 gray balls',
    event = EVENT_CLEARED_BALL,
    condition = function()
      return Game.stats.whiteCleared >= 120
    end,
  },
  {
    name = 'Gray Matter',
    description = 'Destroy 160 gray balls',
    event = EVENT_CLEARED_BALL,
    condition = function()
      return Game.stats.whiteCleared >= 160
    end,
  },
  {
    name = 'Jean Gray',
    description = 'Destroy 200 gray balls',
    event = EVENT_CLEARED_BALL,
    condition = function()
      return Game.stats.whiteCleared >= 200
    end,
  },


  -- Combo Page
  {
    name = 'Combo Apprentice',
    description = 'Make a combo of \n20 or more',
    event = EVENT_SCORED,
    condition = function()
      return Game.combo >= 20
    end,
  },
  {
    name = 'Combo Maker',
    description = 'Make a combo of \n40 or more',
    event = EVENT_SCORED,
    condition = function()
      return Game.combo >= 40
    end,
  },
  {
    name = 'Combo Pro',
    description = 'Make a combo of \n60 or more',
    event = EVENT_SCORED,
    condition = function()
      return Game.combo >= 60
    end,
  },
  {
    name = 'Combo Master',
    description = 'Make a combo of \n80 or more',
    event = EVENT_SCORED,
    condition = function()
      return Game.combo >= 80
    end,
  },
  {
    name = 'Combo God',
    description = 'Make a combo of \n100 or more',
    event = EVENT_SCORED,
    condition = function()
      return Game.combo >= 100
    end,
  },
}
