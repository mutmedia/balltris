local json = require 'lib/json'
local Async = require 'lib/async'
local Request = require 'lib/async/request'
local Load = require 'lib/load'
local Scheduler = require 'lib/scheduler'
local Checksum = require 'checksum'

local CreatePassword = require 'password' or function() return 'no password' end

local USER_DATA_FILE_PATH = 'user_data_v'..VERSION..'.lua'
local BACKEND_PATH = 'http://localhost:8080'
--local BACKEND_PATH = 'https://balltris.herokuapp.com'

local Backend = {}

local print = function(...)
  print('BACKEND: ', ...)
end


function Backend.Init()
  Backend.isOffline = true

  local ok, rawUserData = Checksum.LoadWith(USER_DATA_FILE_PATH)
  if not ok or not rawUserData.id then 
    print('No user set')
    Backend.ConnectFirstTime()
  else
    Backend.userData = {
      id = rawUserData.id
    }
    Backend.isOffline = false
  end
end

function Backend.CheckUsername(username)
  return string.match(username, USERNAME_PATTERN) == username and string.len(username) <= USERNAME_MAX_LENGTH and string.len(username) >= USERNAME_MIN_LENGTH
end

function Backend.ConnectFirstTime()
  Async(function()
    Game.state:push(STATE_GAME_FIRST_CONNECTION)
    Game.backendConnectionError = nil
    print('-----------OS', love.system.getOS())
    local ok, response = Request.Post(BACKEND_PATH..'/users', {
        os=love.system.getOS(),
      })
    if not ok then 
      Game.backendConnectionError = response 
    else
      Backend.userData = {
        id = response._id
      }
      local userDataFile = string.format([[
  return {
    id='%s'
    }
  ]], Backend.userData.id)
      Checksum.SaveWith(USER_DATA_FILE_PATH, userDataFile)
      Game.state:push(STATE_GAME_MAINMENU)
      Backend.isOffline = false
    end
  end)
end

function Backend.SendStats(stats, gamenumber, isOver)
  if Backend.isOffline then return end
  print('Sending stats')
  local data = {
    username=Game.usernameText,
    userid=Backend.userData.id,
    game=gamenumber,
    stats=stats,
    version=VERSION,
    --over=isOver or false,
  }
  local passwordData = data.userid..data.game
  local password = CreatePassword(passwordData)
  data.password = password
  print('sending data: ', json.encode(data))
  --print(BACKEND_PATH..'/'..Backend.userData.username)
  Async(function()
    local ok, response = Request.Post(BACKEND_PATH..'/games', data)
    if ok then
    end
  end)
end

function Backend.GetTopPlayers()
  Async(function()
    if Game.inState(STATE_GAME_LEADERBOARD_LOADING) then
      return 
    end
    Game.state:push(STATE_GAME_LEADERBOARD_LOADING)
    local ok, top10Data = Request.Get(BACKEND_PATH..'/top10')
    if not ok then
      print('error: '..top10Data)
      Backend.top10Error = 'Could not connect\nto game server.'
      if Game.inState(STATE_GAME_LEADERBOARD_LOADING) then
        Game.state:pop()
        Game.state:push(STATE_GAME_LEADERBOARD)
      end
      return
    else
      Backend.top10Error = nil
      for k, v in ipairs(top10Data) do
        print(k, v.username, v.stats.score, v.userid)
      end
      Backend.top10Data = top10Data
      if Game.inState(STATE_GAME_LEADERBOARD_LOADING) then
        Game.state:pop()
        Game.state:push(STATE_GAME_LEADERBOARD)
      end
    end
  end)
end

return Backend
