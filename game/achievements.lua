local Set = require 'lib/set'
local Scheduler = require 'lib/scheduler'

local print = function(...)
  print('ACHIEVEMENTS: ', ...)
end

function Game.InitializeAchievements()
  if not Game.achievements.achievedNums then
    print('Setting loaded things')
    Game.achievements.achievedNums = Set.New()
    print(Game.achievements.achievedNumsRaw._count)
    if Game.achievements.achievedNumsRaw._count then 
      for k, v in pairs(Game.achievements.achievedNumsRaw) do
        if k ~= "_count" then 
          print(k)
          Game.achievements.achievedNums:add(k)
        end
      end
    end
  end
  Game.achievements.achievedThisGameNums = Set.New()
  -- setup events for not achieved
  for num, achievement in ipairs(GAME_ACHIEVEMENTS) do
    print('scheduling', achievement.name, 'for event', achievement.event)
    if Game.achievements.achievedNums:contains(num) then 
      print('already has this achievement')
    else

      local function achievementRecursion(...)
        if achievement.condition(...) then
          Game.achievements.achievedNums:add(num)
          Game.achievements.achievedThisGameNums:add(num)
          Game.achievements.displaying = achievement.name
          Scheduler.add(function()
            Game.achievements.displaying = nil
          end, 1)
        else
          Game.events.schedule(achievement.event, achievementRecursion)
        end
      end

      Game.events.schedule(achievement.event, achievementRecursion)
    end
  end
end
