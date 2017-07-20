require 'ui/base'

Text{
  name='achievements title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_ACHIEVEMENTS),
  x=BASE_SCREEN_WIDTH/2,
  y=2*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=COLOR_YELLOW,
  width=HOLE_WIDTH*1.4,
  getText= function()
    return 'achievements'
  end,
}

local ACHIEVEMENTS_TOTAL_PAGES = math.ceil(#GAME_ACHIEVEMENTS/ACHIEVEMENTS_PER_PAGE)
local currentAchievementPage = 1

for num, achievement in ipairs(GAME_ACHIEVEMENTS) do
  Text{
    name='achievement '..achievement.name,
    layer=LAYER_MENUS,
    number=num,
    condition=And(
      inGameState(STATE_GAME_ACHIEVEMENTS), 
      function(self)
        return math.ceil(self.number/ACHIEVEMENTS_PER_PAGE) == currentAchievementPage
      end),
    x=BASE_SCREEN_WIDTH/2,
    y=(6 + 4.4 * ((num-1) % ACHIEVEMENTS_PER_PAGE))*UI_HEIGHT_UNIT,
    font=FONT_SM,
    getColor=function(self)
      return Game.achievements.achievedNums:contains(self.number) 
        and (Game.achievements.achievedThisGameNums:contains(self.number)
        and COLOR_GREEN or COLOR_BLUE)
        or COLOR_WHITE
    end,
    width=HOLE_WIDTH,
    getText= function()
      return achievement.name
    end,
  }
  Text{
    name='achievement '..achievement.name..' description',
    layer=LAYER_MENUS,
    number=num,
    condition=And(
      inGameState(STATE_GAME_ACHIEVEMENTS), 
      function(self)
        return math.ceil(self.number/ACHIEVEMENTS_PER_PAGE) == currentAchievementPage
      end),
    x=BASE_SCREEN_WIDTH/2,
    y=(1 + 6 + 4.4*((num-1) % ACHIEVEMENTS_PER_PAGE))*UI_HEIGHT_UNIT,
    font=FONT_XS,
    getColor=function(self)
      return Game.achievements.achievedNums:contains(self.number) 
        and (Game.achievements.achievedThisGameNums:contains(self.number)
        and COLOR_GREEN or COLOR_BLUE)
        or COLOR_WHITE
    end,
    width=HOLE_WIDTH,
    getText= function()
      return achievement.description or 'secret'
    end,
  }
end

Button{
  name='prev page',
  layer=LAYER_MENUS,
  condition=And(
    inGameState(STATE_GAME_ACHIEVEMENTS),
    function()
      return currentAchievementPage > 1
    end),
  x=BASE_SCREEN_WIDTH/2 - HOLE_WIDTH * 0.225,
  y=28*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.35,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  getText = function() 
    return '<--'
  end,
  onPress = function(self, x, y)
    currentAchievementPage = math.max(currentAchievementPage - 1, 1)
  end,
}


Button{
  name='next page',
  layer=LAYER_MENUS,
  condition=And(
    inGameState(STATE_GAME_ACHIEVEMENTS),
    function()
      return currentAchievementPage < ACHIEVEMENTS_TOTAL_PAGES
    end),
  x=BASE_SCREEN_WIDTH/2 + HOLE_WIDTH * 0.225,
  y=28*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.35,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  getText = function() 
    return '-->'
  end,
  onPress = function(self, x, y)
    currentAchievementPage = math.min(currentAchievementPage + 1, ACHIEVEMENTS_TOTAL_PAGES)
  end,
}


Button{
  name='back',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_ACHIEVEMENTS),
  x=BASE_SCREEN_WIDTH/2,
  y=32*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  getText = function() 
    return 'back'
  end,
  onPress = function(self, x, y)
    Game.state:pop()
  end,
}

