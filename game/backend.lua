local json = require 'lib/json'
local Async = require 'lib/async'
local Request = require 'lib/async/request'
local Load = require 'lib/load'
local Scheduler = require 'lib/scheduler'

local USER_DATA_FILE_PATH = 'user_data.lua'
--local BACKEND_PATH = 'http://localhost:1234'
local BACKEND_PATH = 'https://balltris.herokuapp.com'

local Backend = {}

local print = function(str)
  print('BACKEND: '..(str or ''))
end

function Backend.init()
  Backend.isOffline = true

  local ok, userData = Load.luafile(USER_DATA_FILE_PATH)
  if not ok then 
    print('No user set')
    Game.state:push(STATE_GAME_USERNAME)
  else
    Backend.setUser(userData)
  end
end

function Backend.tryCreateUser(username)
  Async(function()
    if string.match(username, USERNAME_PATTERN) ~= username then
      print('Invalid username')
      return
    end
    local exists, _ = Request.Get(BACKEND_PATH..'/users/'..username)
    if exists then
      Game.usernameErrorMsg = "name already taken"
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
        Backend.setUser(userData)
        SaveUserDataToFile(userData)
        Game.state:push(STATE_GAME_MAINMENU)
        print('Crated new user: '..username)
        Backend.sendScore(Game.highScore or 0)
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
    username='%s',
    score=%d,
    }
  ]], userData.username, userData.score)

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

function Backend.setUser(userData)
  for k, v in pairs(userData) do
    print(k, v)
  end
  Backend.userData = userData
  Backend.isOffline = false
end

function Backend.sendScore(score)
  if Backend.isOffline then return end
  print('Sending score')
  local data = {
    username=Backend.userData.username,
    score=score 
  }
  print(json.encode(data))
  print(BACKEND_PATH..'/'..Backend.userData.username)
  Async(function()
    local _, response = Request.Patch(BACKEND_PATH..'/users/'..Backend.userData.username, data)
    userId = response['_id']
    print(userId)
  end)
end

function Backend.getTopPlayers()
  Async(function()
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
        print(k, v.username, v.score)
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
