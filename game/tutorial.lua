local Scheduler = require 'lib/scheduler'
local Game = require 'game'

local print = function(str)
  print('TUTORIAL: '..(str or ''))
end



function MoveToLearn(learnCallback)
  Game.events.schedule(EVENT_MOVED_PREVIEW, function()
    Game.tutorial.state = STATE_TUTORIAL_NONE
    learnCallback()
  end)
end

function MoveToLearnAfterTimeout(learnCallback, timeout)
  Scheduler.add(
    function() 
      MoveToLearn(learnCallback)
    end,
    TUTORIAL_MIN_TIME)
end

function Game.InitializeTutorial()
  -- TODO: load user tutorial file
  Game.tutorial = {
    learnedAimBall = false,
    learnedDropBall = false,
    learnedSlomo = false,
    learnedScore = false,
    learnedWhiteBalls = false,
    learnedCombo = false,
    learnedLoseCombo = false,
    learnedClearCombo = false,
    learnedNewComboClearsat = false,
    learnedCombometerScore = false,
    learnedCombometerDrop = false,
    state = STATE_TUTORIAL_NONE,
  }

  if not Game.tutorial.learnedAimBall or not Game.tutorial.learnedDropBall then
    Game.tutorial.state = STATE_TUTORIAL_AIMBALL
    Game.events.schedule(EVENT_MOVED_PREVIEW, function()
      Game.tutorial.state = STATE_TUTORIAL_DROPBALL
      print('finished aim tutorial')
      Game.tutorial.learnedAimBall = true

      Game.events.schedule(EVENT_RELEASED_PREVIEW, function()
        print('finished drop tutorial')
        Game.tutorial.state = STATE_TUTORIAL_NONE
        Game.tutorial.learnedDropBall = true

      end)
    end)
  end

  if not Game.tutorial.learnedSlomo then
    Game.events.schedule(EVENT_SAFE_TO_DROP, function()
      Game.events.schedule(EVENT_SAFE_TO_DROP, function()
        Scheduler.add(
          function()
            Game.tutorial.state = STATE_TUTORIAL_SLOMO
            MoveToLearnAfterTimeout(function() end)
            Game.events.schedule(EVENT_SAFE_TO_DROP, function()
              Game.tutorial.state = STATE_TUTORIAL_SLOMO_OPTIONS
              MoveToLearnAfterTimeout(function()
                Game.tutorial.learnedSlomo = true 
              end)
            end)
          end,
          TUTORIAL_SLOMO_TIMEOUT_AFTERSAFE)
      end)
    end)
  end

  if not Game.tutorial.learnedScore then
    Game.events.schedule(EVENT_SCORED, function()
      Scheduler.add(
        function()
          Game.tutorial.state = STATE_TUTORIAL_SCORE
          MoveToLearnAfterTimeout(function() Game.tutorial.learnedScore = true end)
        end,
        TUTORIAL_SCORE_TIMEOUT_AFTERHIT)
    end)
  end

  if not Game.tutorial.learnedWhiteBalls then
    Game.events.schedule(EVENT_WHITE_BALLS_HIT, function()
      Game.tutorial.state = STATE_TUTORIAL_WHITEBALLS
      MoveToLearnAfterTimeout(function() Game.tutorial.learnedWhiteBalls = true end)
    end)
  end

  if not Game.tutorial.learnedCombo then
    learnToCombo()
  end

  if Game.tutorial.learnedLoseCombo and not Game.tutorial.learnedCombometerDrop then
    learnedCombometerDrop()
  end

  if Game.tutorial.learnedLoseCombo and not Game.tutorial.learnedCombometerScore then
    learnCombometerScore()
  end

  if Game.tutorial.learnedNewComboClearsat then
    Game.events.schedule(EVENT_COMBO_NEW_CLEARSAT, function()
      Game.tutorial.state = STATE_TUTORIAL_NEW_COMBO_CLEARSAT
      MoveToLearnAfterTimeout(function() Game.tutorial.learnedNewComboClearsat = true end)
    end)
  end

  if not Game.tutorial.learnedLoseCombo then
    learnToLoseCombo()
  end

  if not Game.tutorial.learnedClearCombo then
    Game.events.schedule(EVENT_COMBO_CLEARED, function()
      Scheduler.add(
        function()
          Game.tutorial.state = STATE_TUTORIAL_CLEARCOMBO
          MoveToLearnAfterTimeout(function() Game.tutorial.learnedClearCombo = true end)
        end, TUTORIAL_CLEAR_TIMEOUT)
    end)
  end
end

function learnCombometerDrop()
  Game.events.schedule(EVENT_SAFE_TO_DROP, function()
    Scheduler.add(
      function()
        Game.tutorial.state = STATE_TUTORIAL_COMBOMETER_DROP
        MoveToLearnAfterTimeout(function() Game.tutorial.learnedCombometerDrop = true end)
      end, 0)
  end)
end

function learnCombometerScore()
  Game.events.schedule(EVENT_SCORED, function()
    Scheduler.add(
      function()
        Game.tutorial.state = STATE_TUTORIAL_COMBOMETER_SCORE
        MoveToLearnAfterTimeout(function() Game.tutorial.learnedCombometerScore = true end)
      end, 0)
  end)
end

function learnToCombo()
  function learnToComboRecursion()
    print('learned combo')
    Scheduler.add(
      function()
        if Game.combo > 1 then
          Game.tutorial.state = STATE_TUTORIAL_COMBO
          MoveToLearnAfterTimeout(function() Game.tutorial.learnedCombo = true end)
        else
          Game.events.schedule(EVENT_SCORED, learnToComboRecursion)
        end
      end, TUTORIAL_COMBO_TIMEOUT_AFTERHIT)
  end
  Game.events.schedule(EVENT_SCORED, learnToComboRecursion)
end


function learnToLoseCombo()
  function learnToLoseComboRecursion()
    if Game.combo > 1 then
      Game.tutorial.state = STATE_TUTORIAL_LOSECOMBO
      MoveToLearnAfterTimeout(function() 
        Game.tutorial.learnedLoseCombo = true 
        learnCombometerScore()
        learnCombometerDrop()
      end)
    else
      Game.events.schedule(EVENT_COMBO_END, learnToLoseComboRecursion)
    end
  end
  Game.events.schedule(EVENT_COMBO_END, learnToLoseComboRecursion)
end

