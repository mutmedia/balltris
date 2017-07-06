require 'ui/base'

local i = 0
for k, v in pairs(Game.stats) do
  Text{
    name='stat totalBalls',
    layer=LAYER_HUD,
    condition=function() return Game.stats ~= nil end,
    x=BORDER_THICKNESS/2,
    y=25*UI_HEIGHT_UNIT + 1.8 * UI_HEIGHT_UNIT * i,
    font=FONT_XS,
    color=COLOR_WHITE,
    width=BORDER_THICKNESS,
    getText = function()
      return k..'\n'..Game.stats[k]
    end,
  }
  i = i + 1
end
