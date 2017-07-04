local Scheduler = require 'lib/scheduler'
local Game = require 'game'
local LocalSave = require 'localsave'
local Set = require 'lib/set'
local Stack = require 'lib/stack'
require 'test/stack'

local print = function(str)
  print('TUTORIAL: '..(str or ''))
end

function MoveToLearnAfterTimeout()
  Scheduler.add(
    function() 
      Game.events.schedule(EVENT_MOVED_PREVIEW, function()
        Learn()
      end)
    end,
    TUTORIAL_MIN_TIME)
end

local learnedThing = nil
function Learn()
  if learnedThing then 
    print('already learned '..learnedThing..' this event')
    MoveToLearnAfterTimeout()
    return 
  end
  learnedThing = Game.tutorial.state:pop()
  Game.tutorial.learned:add(learnedThing)
  print('learned '..learnedThing)
  LocalSave.Save(Game)
  Scheduler.add(function() learnedThing = nil end, 0)
end

function Game.IsTutorialOver()
  if not Game.tutorial or not Game.tutorial.learned then 
    print('ERROR: tutorial does not exist')
    return false 
  end
  for k, v in pairs(TUTORIALS_TO_LEARN) do
    if not Game.tutorial.learned:contains(v) then
      return false
    end
  end
  return true
end

function Game.IsTutorialReset()
  if not Game.tutorial or not Game.tutorial.learned then 
    print('ERROR: tutorial does not exist')
    return false 
  end
  for k, v in pairs(TUTORIALS_TO_LEARN) do
    if Game.tutorial.learned:contains(v) then
      return false
    end
  end
  return true
end

function Game.ResetTutorial()
  Game.tutorial.learned = Set.New() 
  LocalSave.Save(Game)
end

function Game.SkipTutorial()
  Game.tutorial.learned = Set.New(TUTORIALS_TO_LEARN)
  LocalSave.Save(Game)
end

function Game.InitializeTutorial(loadedTutorial)
  -- TODO: load user tutorial file
  Game.tutorial = Game.tutorial or {}
  Game.tutorial.learned = Game.tutorial.learned or Set.New(Game.tutorial.learnedRaw)
  Game.tutorial.state = Stack.New()
  --Game.tutorial.state:push(LEARN_NOTHING)


  if not Game.tutorial.learned:contains(LEARN_AIMBALL) or not Game.tutorial.learned:contains(LEARN_DROPBALL) then
    Game.tutorial.state:push(LEARN_AIMBALL)
    Game.events.schedule(EVENT_MOVED_PREVIEW, function()
      Game.tutorial.state:pop()
      Game.tutorial.state:push(LEARN_DROPBALL)
      Game.tutorial.learned:add(LEARN_AIMBALL) 

      Game.events.schedule(EVENT_RELEASED_PREVIEW, function()
        Game.tutorial.state:pop()
        Game.tutorial.learned:add(LEARN_DROPBALL) 
        LocalSave.Save(Game)
      end)
    end)
  end

  if not Game.tutorial.learned:contains(LEARN_SLOMO) then
    Game.events.schedule(EVENT_SAFE_TO_DROP, function()
      Game.events.schedule(EVENT_SAFE_TO_DROP, function()
        Scheduler.add(
          function()
            Game.tutorial.state:push(LEARN_SLOMO)
            MoveToLearnAfterTimeout()
            Game.events.schedule(EVENT_SAFE_TO_DROP, function()
              Game.tutorial.state:push(LEARN_SLOMOOPTIONS)
              MoveToLearnAfterTimeout()
            end)
          end,
          TUTORIAL_SLOMO_TIMEOUT_AFTERSAFE)
      end)
    end)
  end

  if not Game.tutorial.learned:contains(LEARN_SCORE) then
    Game.events.schedule(EVENT_SCORED, function()
      Scheduler.add(
        function()
          Game.tutorial.state:push(LEARN_SCORE)
          MoveToLearnAfterTimeout()
        end,
        TUTORIAL_SCORE_TIMEOUT_AFTERHIT)
    end)
  end

  if not Game.tutorial.learned:contains(LEARN_WHITEBALLS) then
    Game.events.schedule(EVENT_WHITE_BALLS_HIT, function()
      Game.tutorial.state:push(LEARN_WHITEBALLS)
      MoveToLearnAfterTimeout()
    end)
  end

  if not Game.tutorial.learned:contains(LEARN_COMBO) then
    learnToCombo()
  end

  if Game.tutorial.learned:contains(LEARN_LOSECOMBO) and not Game.tutorial.learned:contains(LEARN_COMBOMETERDROP) then
    learnCombometerDrop()
  end

  if Game.tutorial.learned:contains(LEARN_LOSECOMBO) and not Game.tutorial.learned:contains(LEARN_COMBOMETERSCORE) then
    learnCombometerScore()
  end

  if not Game.tutorial.learned:contains(LEARN_NEWCOMBOCLEARSAT) then
    Game.events.schedule(EVENT_COMBO_NEW_CLEARSAT, function()
      Game.tutorial.state:push(LEARN_NEWCOMBOCLEARSAT)
      MoveToLearnAfterTimeout()
    end)
  end

  if not Game.tutorial.learned:contains(LEARN_LOSECOMBO) then
    learnToLoseCombo()
  end

  if not Game.tutorial.learned:contains(LEARN_CLEARCOMBO) then
    Game.events.schedule(EVENT_COMBO_CLEARED, function()
      Scheduler.add(
        function()
          Game.tutorial.state:push(LEARN_CLEARCOMBO)
          MoveToLearnAfterTimeout()
        end, TUTORIAL_CLEAR_TIMEOUT)
    end)
  end
end

function learnCombometerDrop()
  print('scheduled combometer drop')
  Game.events.schedule(EVENT_SAFE_TO_DROP, function()
    Scheduler.add(
      function()
        Game.tutorial.state:push(LEARN_COMBOMETERDROP)
        MoveToLearnAfterTimeout()
      end, 0)
  end)
end

function learnCombometerScore()
  print('scheduled combometer drop')
  Game.events.schedule(EVENT_SCORED, function()
    Scheduler.add(
      function()
        Game.tutorial.state:push(LEARN_COMBOMETERSCORE)
        MoveToLearnAfterTimeout()
      end, 0)
  end)
end

function learnToCombo()
  function learnToComboRecursion()
    Scheduler.add(
      function()
        if Game.combo > 1 then
          Game.tutorial.state:push(LEARN_COMBO)
          MoveToLearnAfterTimeout()
        else
          Game.events.schedule(EVENT_SCORED, learnToComboRecursion)
        end
      end, TUTORIAL_COMBO_TIMEOUT_AFTERHIT)
  end
  Game.events.schedule(EVENT_SCORED, learnToComboRecursion)
end


function learnToLoseCombo()
  function learnToLoseComboRecursion()
    --print('waiting to learn lose combo')
    Game.tutorial.state:push(LEARN_LOSECOMBO)
    MoveToLearnAfterTimeout()
  end
  Game.events.schedule(EVENT_COMBO_END, learnToLoseComboRecursion)
end

