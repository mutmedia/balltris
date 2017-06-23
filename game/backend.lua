local json = require 'lib/json'
local Request = require 'lib/request'
local Load = require 'lib/load'

local USER_DATA_FILE_PATH = 'user_data.lua'
local BACKEND_PATH = 'http://localhost:1234'

local Backend = {}

function Backend.init()
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
    print('existing username')
    return false
  else
    local _, response = Request.post(BACKEND_PATH..'/users', {
        username=username,
        score=0,
      })
    print('Created new user:', json.encode(response))
    Backend.setUser({username=username, score=0})
    return true
  end
end

function Backend.setUser(userData)
  for k, v in pairs(userData) do
    print(k, v)
  end
  Backend.userData = userData
end

function Backend.sendScore(score)
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
