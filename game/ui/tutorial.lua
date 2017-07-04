require 'ui/base'

function inTutorialState(...) 
  local vars = {...}
  return function()
    local tutorialStates = vars
    for _, tutorialState in pairs(tutorialStates) do
      --print(tutorialState)
      if Game.tutorial and Game.tutorial.state and Game.tutorial.state:peek() == tutorialState then
        return true
      end
    end
    return false
  end
end

function TutorialText(data)
  data.name = 'tutorial '..data.name
  data.layer=LAYER_MENUS
  data.condition = And(inGameState(STATE_GAME_RUNNING, STATE_GAME_LOST), data.condition)
  data.x=BASE_SCREEN_WIDTH/2
  data.y=11*UI_HEIGHT_UNIT
  data.font=FONT_SM
  data.width=0.9 * HOLE_WIDTH
  data.textColor=COLOR_WHITE
  data.color=COLOR_BLACK
  data.height=8 * UI_HEIGHT_UNIT
  data.lineColor=COLOR_WHITE
  data.lineWidth=3
  return Button(data)
end


TutorialText{
  name='aim ball',
  condition=inTutorialState(LEARN_AIMBALL),
  getText = function()
    return [[
Drag you finger
in the play area 
to aim the ball
]]
  end,
}

TutorialText{
  name='drop ball',
  condition=inTutorialState(LEARN_DROPBALL),
  getText = function()
    return [[
Release your finger 
from play area 
or from screen
to drop the ball
]]
  end,
}

TutorialText{
  name='score',
  condition=inTutorialState(LEARN_SCORE),
  getText = function()
    return [[
When balls with
same color collide
they are destroyed
and you score
]]
  end,
}

TutorialText{
  name='white balls',
  condition=inTutorialState(LEARN_WHITEBALLS),
  getText = function()
    return [[
White balls don't 
destroy each other
]]
  end,
}

TutorialText{
  name='slomo',
  condition=inTutorialState(LEARN_SLOMO),
  getText = function()
    return [[
While aiming,
time moves slowly 
]]
  end,
}

TutorialText{
  name='slomo',
  condition=inTutorialState(LEARN_SLOMOOPTIONS),
  getText = function()
    return [[
Slow motion
can be changed
in options menu
]]
  end,
}

TutorialText{
  name='combo',
  condition=inTutorialState(LEARN_COMBO),
  getText = function()
    return [[
Destroy balls
in quick succession
to combo
]]
  end,
}

TutorialText{
  name='lose combo',
  condition=inTutorialState(LEARN_LOSECOMBO),
  getText = function()
    return [[
When the 
combo meter
is depleted
your combo ends
]]
  end,
}

TutorialText{
  name='combo meter drop',
  condition=inTutorialState(LEARN_COMBOMETERDROP),
  getText = function()
    return [[
Releasing a ball
fills combo meter
]]
  end,
}

TutorialText{
  name='combo meter score',
  condition=inTutorialState(LEARN_COMBOMETERSCORE),
  getText = function()
    return [[
Balls disappearing
fills combo meter 
]]
  end,
}

TutorialText{
  name='combo clear',
  condition=inTutorialState(LEARN_CLEARCOMBO),
  getText = function()
    return [[
When combo higher
than 'clear at' value
all the white balls
disappear
]]
  end,
}

TutorialText{
  name='combo new clearsat',
  condition=inTutorialState(LEARN_NEWCOMBOCLEARSAT),
  getText = function()
    return [[
After losing a
cleared combo
'clears at' value
increases
]]
  end,
}

--[[
TutorialText{
  name='debug',
  condition=True(),inTutorialState(LEARN_NEWCOMBOCLEARSAT),
  getText = function()
print(Game.tutorial.state)
    return 'test' 
  end,
}
]]--

--[[
Button{
  name='new game button',
  layer=LAYER_MENUS,
  condition=False(),--False(Not(inTutorialState(LEARN_NONE))),
  x=BASE_SCREEN_WIDTH/2,
  y=20*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  getText = function() 
    return 'ok'
  end,
  onPress = function(self, x, y)
    Game.tutorial.state = LEARN_NONE
  end,
}
]]--


