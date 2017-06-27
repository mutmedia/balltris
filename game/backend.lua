local json = require 'lib/json'
local Request = require 'lib/request'
local Load = require 'lib/load'

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
    Game.state = STATE_GAME_USERNAME
  else
    Backend.setUser(userData)
  end
end

function Backend.tryCreateUser(username)
  local exists, _ = Request.get(BACKEND_PATH..'/users/'..username)
  if exists then
    return false, 'Username already exists'
  else
    local success, response = Request.post(BACKEND_PATH..'/users', {
        username=username,
        score=0,
      })
    if success then 
      print('Created new user:', json.encode(response))
      local userData = {username=username, score=0} 
      Backend.setUser(userData)
      SaveUserDataToFile(userData)
      return true, 'Created new user'
    else
      print('Error creating new user')
      return false, response
    end
  end
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
  local _, response = Request.patch(BACKEND_PATH..'/users/'..Backend.userData.username, data)
  userId = response['_id']
  print(userId)
end

function Backend.getTopPlayers()
  local ok, top10Data = Request.get(BACKEND_PATH..'/top10')
  for k, v in ipairs(top10Data) do
    print(k, v.username, v.score)
  end
  Backend.top10Data = top10Data
  Game.state = GAME_STATE_LEADERBOARD
end

return Backend
