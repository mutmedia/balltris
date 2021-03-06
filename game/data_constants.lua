-- Misc
TITLE = 'BallTris'
VERSION='0.7.2'

-- Online things
USERNAME_PATTERN = '^[a-zA-Z0-9]*$'
USERNAME_MAX_LENGTH  = 10
USERNAME_MIN_LENGTH  = 3
USERNAME_PLACEHOLDER = 'enter name'

-- Physics
METER = 256
GRAVITY = 10 * METER * 2
FIXED_DT = 1/120
MAX_DT_ACC = 1

-- Screen
BASE_SCREEN_WIDTH = 540
BASE_SCREEN_HEIGHT = 960
ASPECT_RATIO = BASE_SCREEN_WIDTH/BASE_SCREEN_HEIGHT
WIDTH_SCALE = 540/640
HOLE_WIDTH = 0.47 * BASE_SCREEN_WIDTH
HOLE_DEPTH = 0.94 * BASE_SCREEN_HEIGHT
BORDER_THICKNESS = (BASE_SCREEN_WIDTH - HOLE_WIDTH)/2
BOTTOM_THICKNESS = BASE_SCREEN_HEIGHT - HOLE_DEPTH

-- Ball
BALL_COLORS = 5

BALL_BASE_RADIUS = 25 * WIDTH_SCALE * BASE_SCREEN_WIDTH/540
BALL_RADIUS_MULTIPLIERS = {1, 1.7, 2.5}
BALL_MAX_RADIUS = BALL_BASE_RADIUS * BALL_RADIUS_MULTIPLIERS[#BALL_RADIUS_MULTIPLIERS]

BALL_LINES_DISTANCE = 12 * BASE_SCREEN_WIDTH/1080
BALL_LINE_WIDTH_OUT = 4 * BASE_SCREEN_WIDTH/1080
BALL_LINE_WIDTH_IN = 4 * BASE_SCREEN_WIDTH/1080

BALL_STRETCH_NORMALIZER = 1/3000
BALL_STRETCH_FACTOR = 1.08
BALL_TIME_TO_DESTROY = 0.2
BALL_CHANCE_MODIFIER = 0.1
BALL_DRAW_SCALE = 0.99

BALL_NEON_GAP = 0

-- White Ball
WHITE_BALL_SIZE = BALL_BASE_RADIUS * 1.7
WHITE_BALL_BORDER_WIDTH = 5

-- UI
RECTANGLE_BORDER_RADIUS = 5
FRENZY_SPEED = 30

-- Preview
PREVIEW_SPEED = 200
PREVIEW_HOLD_TIME = 0.2
PREVIEW_PADDING = 0
NUM_BALL_PREVIEWS = 5

-- Time Scales
TIME_SCALE_REGULAR = 1.0
TIME_SCALE_SLOMO = 0.1

-- Minimum value definitions
FRAMES_TO_STATIC = 20
MIN_SPEED = 5
COMBO_INITIAL_OBJECTIVE = 5
COMBO_OBJECTIVE_INCREMENT = 5
COMBO_OBJECTIVE_INCREMENTS = {5, 5, 4, 4, 3, 3, 2, 2, 1}
COMBO_MAX_TIMEOUT = 0.8 * TIME_SCALE_REGULAR -- seconds
COMBO_INCREMENT_SCORE = 0.17 * TIME_SCALE_REGULAR-- seconds
COMBO_INCREMENT_DROP = (0.20) * TIME_SCALE_REGULAR -- seconds
COMBO_TIMEOUT_BUFFER = 0.10 * COMBO_MAX_TIMEOUT

-- Collision
COL_MAIN_CATEGORY = 1

--Input
INPUT_SWITCH_BALL = 'c'
INPUT_RELEASE_BALL = 'space'

-- Game End
MIN_DISTANCE_TO_TOP = 2 * BALL_MAX_RADIUS * BALL_DRAW_SCALE

-- Effects
EFFECT_CRT_DISTORTION = {0.015, 0.050}
EFFECT_CRT_PIXEL = 3
EFFECT_CRT_OPACITY = 0.5
EFFECT_CRT_FADE = 0.5
EFFECT_CRT_SCAN_HEIGHT = 0.5

-- Game states
STATE_GAME_RUNNING = 1
STATE_GAME_LOST = 2 -- When balls cross the line
STATE_GAME_OVER  = 4 -- When everything ends
STATE_GAME_PAUSED  = 8 -- When game is paused
STATE_GAME_LOADING = 16 -- When game is paused
STATE_GAME_MAINMENU = 32 -- When game in on main menu
STATE_GAME_LEADERBOARD = 64 --when in leaderboard screen
STATE_GAME_USERNAME = 128 --when in user name input screen 
STATE_GAME_OFFLINE_CONFIRMATION = 256 --when asking for confirmation to play offline
STATE_GAME_OPTIONS = 512 --main menu options
STATE_GAME_LEADERBOARD_LOADING = 1024 --when in leaderboard screen loading
STATE_GAME_USERNAME_LOADING = 2048 --when in user name input screen loading
STATE_GAME_FIRST_CONNECTION = 4096 --when connecting to server for first time
STATE_GAME_LEADERBOARD_STATS = 8192 --when looking at a players stats on the leaderboard
STATE_GAME_ACHIEVEMENTS = 16384 -- when viewing achievements
STATE_GAME_OVER_ACHIEVEMENTS  = 32768 -- When everything ends
STATE_GAME_CREDITS = 65535 -- Displaying game credits

-- Tutorial states
LEARN_AIMBALL = 'aim ball'
LEARN_DROPBALL = 'drop ball'
LEARN_COMBO = 'combo'
LEARN_LOSECOMBO = 'lose combo'
LEARN_CLEARCOMBO = 'clear combo'
LEARN_SLOMO = 'slo mo'
LEARN_SCORE = 'score'
LEARN_WHITEBALLS = 'white balls'
LEARN_SLOMOOPTIONS = 'slmo mo options'
LEARN_COMBOMETERDROP = 'combometer drop'
LEARN_COMBOMETERSCORE = 'combometer score'
LEARN_NEWCOMBOCLEARSAT = 'new combo clearsat'
LEARN_GAMELOSE = 'game lose'
LEARN_STREAK = 'combo streak'

TUTORIALS_TO_LEARN = {
  LEARN_AIMBALL,
  LEARN_DROPBALL,
  LEARN_COMBO,
  LEARN_LOSECOMBO,
  LEARN_CLEARCOMBO,
  --LEARN_SLOMO, LEARN_SLOMOOPTIONS,
  LEARN_SCORE,
  LEARN_WHITEBALLS,
  LEARN_COMBOMETERDROP,
  LEARN_COMBOMETERSCORE,
  LEARN_NEWCOMBOCLEARSAT,
  LEARN_GAMELOSE,
  LEARN_STREAK,
}

-- Tutorial things
TUTORIAL_MIN_TIME = 1.5
TUTORIAL_SCORE_TIMEOUT_AFTERHIT = 0.1 * TIME_SCALE_REGULAR
TUTORIAL_COMBO_TIMEOUT_AFTERHIT = 0.1 * TIME_SCALE_REGULAR
TUTORIAL_CLEAR_TIMEOUT = 0.15 * TIME_SCALE_REGULAR
TUTORIAL_SLOMO_TIMEOUT_AFTERSAFE = 0.04 * TIME_SCALE_REGULAR

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

-- Events
EVENT_MOVED_PREVIEW = 'previewMoved'
EVENT_RELEASED_PREVIEW = 'previewReleased'
EVENT_PRESSED_SWITCH = 'switchReleased'
EVENT_ON_BALLS_STATIC = 'ballsStatic'
EVENT_SAFE_TO_DROP = 'safeToDrop'
EVENT_BALLS_TOO_HIGH = 'ballsTooHigh'
EVENT_OPEN_MENU = 'ballsTooHigh'
EVENT_COMBO_START = 'combostarted'
EVENT_COMBO_END = 'comboended'
EVENT_SCORED = 'scored'
EVENT_NEW_BALL = 'newball'
EVENT_COMBO_TIMEOUT = 'timeout'
EVENT_NEW_BALL_INGAME = 'newballingame'
EVENT_WHITE_BALLS_HIT = 'whiteballshit'
EVENT_COMBO_CLEARED = 'combocleared'
EVENT_COMBO_NEW_CLEARSAT = 'newclearsatvalue'
EVENT_CLICKED_TUTORIAL = 'clickedtutorial'
EVENT_CLEARED_BALL = 'clearedball'
EVENT_DROPPED_BALL = 'dropedball'
EVENT_STREAK = 'samecolorstreak'
EVENT_GAME_OVER = 'gameover'

-- Palette
PALETTE_DEFAULT_PATH = 'content/palette_base.png'
PALETTE_CALANGO_PATH = 'content/palette_calango.png'

-- Options
OPTIONS_SLOMO_HOLD = 'default'
OPTIONS_SLOMO_RELEASE = 'reverse'
OPTIONS_SLOMO_ALWAYSON = 'always'

DEFAULT_OPTIONS = {
  slomoType = OPTIONS_SLOMO_HOLD,
  calango = false,
  audio = false
}

-- Stats
LEADERBOARD_STATS = {
  {
    key = 'timesCleared',
    name = 'total clears',
    text = '%d',
  },
  {
    key = 'whiteCleared',
    name = 'grays cleared',
    text = '%d',
  },
  {
    key = 'slomoTime',
    name = 'slomo %',
    text = '%d',
  },
  {
    key = 'slomoType',
    name = 'slomo',
    text = '%s'
  },
  {
    key = 'frequency',
    name = 'frequency',
    text = '%4.2f /sec',
  },


  {
    key = 'totalBalls',
    name = 'balls',
    text = '%d',
  },
  {
    key = 'bestCombo',
    name = 'best combo',
    text = '%d',
  },
  --ballsCleared = {
  --name = 'balls',
  --text = '%d',
  --},
  --score = {
  --name = 'balls',
  --text = '%d',
  --},

}

-- Credits
CREDITS_DEVELOPER = 'Gustavo Guimaraes (mut)'
CREDITS_MUSIC = 'Yuri Galindo (bay)'
CREDITS_SPECIAL_THANKS = {
  'Edson Guimaraes (pai)',
  'Lígia Guimaraes',
  'Gabriel Ilharco (aco)',
  'Josué Montalvão (Josu)',
  'Vinicius Canaã (vcanaa)',
  'Daniel Cardoso (Calango)',
  'Luiz Felipeh (wakazu)',
  'Luiz Henrique (hikk)',
  'Francisco Castro (chico)',
  'Marina Ballarin',
  'Felipe Ballarin',
  'You',
}

CREDITS_TWITTER = 'https://twitter.com/mutmedia'

-- More data
require 'data_achievements'

