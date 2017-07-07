local json = require 'lib/json'
local Async = require 'lib/async'
local Request = require 'lib/async/request'
local Load = require 'lib/load'
local Scheduler = require 'lib/scheduler'

local USER_DATA_FILE_PATH = 'user_data.lua'
--local BACKEND_PATH = 'http://localhost:1234'
local BACKEND_PATH = 'https://balltris.herokuapp.com'

local Backend = {}

local print = function(...)
  print('BACKEND: ', ...)
end


function Backend.Init()
  Backend.isOffline = true

  local ok, rawUserData = Load.luafile(USER_DATA_FILE_PATH)
  if not ok then 
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
    local ok, response = Request.Post(BACKEND_PATH..'/users', {
        username='',
      })
    if not ok then 
      Game.backendConnectionError = response 
    else
      Backend.userData = {
        id = response._id
      }
      Backend.isOffline = false
      SaveUserDataToFile(Backend.userData)
      Game.state:push(STATE_GAME_MAINMENU)
    end
  end)
end

function Backend.TryCreateUser(username)
  Game.highscore.number = {}
  Async(function()
    Game.usernameErrorMsg = nil
    Game.state:push(STATE_GAME_USERNAME_LOADING)
    local exists, _ = Request.Get(BACKEND_PATH..'/users/'..username)
    if exists then
      Game.usernameErrorMsg = 'name already taken'
      Game.state:push(STATE_GAME_USERNAME)
      Scheduler.add(function() Game.usernameErrorMsg = nil end, 4) -- invalid username will be displayed for 4 seconds
      return 
    else
      local success, response = Request.Post(BACKEND_PATH..'/users', {
          username=username,
          score=0,
        })
      if success then 
        print('Created new user:', json.encode(response))
        local userData = {username=username, score=0} 
        Backend.SetUser(userData)
        SaveUserDataToFile(userData)
        Game.state:push(STATE_GAME_MAINMENU)
        print('Crated new user: '..username)
        if Game.highscore.stats then
          Backend.SendStats(Game.highscore.stats, Game.highscore.number)
        end
        return
      else
        Game.usernameErrorMsg = response
        Game.state:push(STATE_GAME_USERNAME)
        Scheduler.add(function() Game.usernameErrorMsg = nil end, 4) -- invalid username will be displayed for 4 seconds
        print('Error creating new user: '..response)
        return
      end
    end
  end)
end

function SaveUserDataToFile(userData)
  local userDataFile = string.format([[
  return {
    id='%s'
    }
  ]], userData.username, userData.id)

  local file, errorstr = love.filesystem.newFile(USER_DATA_FILE_PATH, 'w') 
  if errorstr then 
    print('SAVE USER ERROR: '..errorstr)
    return 
  end

  local s, err = file:write(userDataFile)
  if err then
    print('SAVE USER ERROR: '..err)
  end
end

function Backend.SetUser(rawUserData)
end

function Backend.SendStats(stats, gamenumber)
  if Backend.isOffline then return end
  print('Sending stats')
  local data = {
    username=Game.usernameText,
    userid=Backend.userData.id,
    game=gamenumber,
    stats=stats,
  }
  print(json.encode(data))
  --print(BACKEND_PATH..'/'..Backend.userData.username)
  Async(function()
    local _, response = Request.Post(BACKEND_PATH..'/games', data)
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
