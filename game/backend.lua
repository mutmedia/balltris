local json = require 'lib/json'
local Request = require 'lib/request'
local Load = require 'lib/load'

local USER_DATA_FILE_PATH = 'user_data.lua'
local BACKEND_PATH = 'http://localhost:1234/users'

local Backend = {}

function Backend.init()
  local ok, userData = Load.luafile(USER_DATA_FILE_PATH)
  if not ok then 
    -- Request user to enter data for first time
    -- TODO: make actual firts time stuff

  end 

  print('Loaded user')
  for k, v in pairs(userData) do
    print(k, v)
  end
  Backend.userData = userData

  local isSaved, data = Request.get(BACKEND_PATH..'/'..Backend.userData.username)
  if isSaved then
    print('Existing user', data)
  else
    local _, response = Request.post(BACKEND_PATH, {
        username=Backend.userData.username,
        score=0,
      })
    print('Created new user:', json.encode(response))
  end

end

function Backend.sendScore(score)
  local data = {
    username=Backend.userData.username,
    score=score 
  }
  print(json.encode(data))
  print(BACKEND_PATH..'/'..Backend.userData.username)
  local _, response = Request.patch(BACKEND_PATH..'/'..Backend.userData.username, data)
  userId = response['_id']
  print(userId)
end

return Backend
