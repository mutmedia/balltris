-- Misc
TITLE = 'BallTris'

-- Physics
METER = 64
GRAVITY = 10 * METER
FIXED_DT = 1/60
MAX_DT_ACC = 1

-- Screen
BASE_SCREEN_WIDTH = 640
BASE_SCREEN_HEIGHT = 960
ASPECT_RATIO = 2/3
HOLE_WIDTH = 300
HOLE_DEPTH = 900
BORDER_THICKNESS = (BASE_SCREEN_WIDTH - HOLE_WIDTH)/2
BOTTOM_THICKNESS = BASE_SCREEN_HEIGHT - HOLE_DEPTH

-- Ball
BALL_BASE_RADIUS = 25
BALL_RADIUS_MULTIPLIERS = {1, 1.7, 2.5}
BALL_MAX_RADIUS = BALL_BASE_RADIUS * BALL_RADIUS_MULTIPLIERS[#BALL_RADIUS_MULTIPLIERS]

BALL_COLORS = {
  --[[ Synthwave
  {65, 163, 162},
  {82, 107, 163},
  {105, 78, 156},
  {140, 58, 145},
  {168, 34, 92},
 ]]--
  --[[ Neon]]--
  {154, 0, 157}, -- Pink
  {254, 0, 2}, -- REd
  {0, 205, 254},
  {51, 205, 49},
  {255, 203, 3},
  
  --[[ Same Luma
  {33, 224, 3},
  {3, 203, 213},
  {249, 54, 252},
  {253, 148, 103},
  {191, 191, 3}
  ]]--
  --[[ Strong
  {255, 0, 0},
  {0, 255, 0},
  {0, 123, 123},
  {123, 0, 123},
  {123, 123, 0}
  ]]--
  --[[ Pastel
  {255, 179, 186},
  {255, 223, 186},
  {255, 255, 186},
  {186, 255, 201},
  {186, 225, 255},
  ]]--
}

BALL_LINES_DISTANCE = 6
BALL_LINE_WIDTH_OUT = 2
BALL_LINE_WIDTH_IN = 2


BALL_SPEED_STRETCH = 0.0001
BALL_TIME_TO_DESTROY = 0.2
BALL_CHANCE_MODIFIER = 0.1
BALL_DRAW_SCALE = 0.99

-- White Ball
WHITE_BALL_SIZE = BALL_BASE_RADIUS * 1.7
WHITE_BALL_COLOR = {190, 190, 190}
--WHITE_BALL_COLOR = {150, 150, 150}
WHITE_BALL_BORDER_COLOR = {99, 99, 99}
WHITE_BALL_BORDER_WIDTH = 5

-- Preview
PREVIEW_SPEED = 200
PREVIEW_PADDING = 0
NUM_BALL_PREVIEWS = 5

-- Minimum value definitions
FRAMES_TO_STATIC = 25
MIN_SPEED2 = 20

-- Collision
COL_MAIN_CATEGORY = 1

--Input
INPUT_SWITCH_BALL = 'c'
INPUT_RELEASE_BALL = 'space'

-- Game End
MIN_DISTANCE_TO_TOP = 2 * BALL_MAX_RADIUS * BALL_DRAW_SCALE

-- Game states
STATE_GAME_RUNNING = 1
STATE_GAME_LOST = 2 -- When balls cross the line
STATE_GAME_OVER  = 4 -- When everything ends
STATE_GAME_PAUSED  = 8 -- When game is paused
STATE_GAME_LOADING = 16 -- When game is paused
STATE_GAME_MAINMENU = 32 -- When game in on main menu

-- Layers
LAYER_BACKGROUND = 'background'
LAYER_GAME = 'game'
LAYER_HUD = 'hud'
LAYER_MENUS = 'menus'

GAME_LAYERS = {
  LAYER_BACKGROUND,
  LAYER_GAME,
  LAYER_HUD,
  LAYER_MENUS,
}

-- Effects
EFFECT_CRT_DISTORTION = {0.015, 0.050}
