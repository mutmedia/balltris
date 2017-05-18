local json = require 'lib/json'
local Request = require 'lib/request'
local Load = require 'lib/load'

local USER_DATA_FILE_PATH = 'user_data.lua'
local BACKEND_PATH = 'http://localhost:1234/users'

local Backend = {}

function Backend.init()
  local ok, userData = Load.luafile(USER_DATA_FILE_PATH)
  if not ok then return end -- Request user to enter data for first time
  print('Loaded user')
  for k, v in pairs(userData) do
    print(k, v)
  end
  Backend.userData = userData
end

function Backend.sendScore(score)
  --local userId = 12345
  
  local data = {
    name=Backend.userData.name,
    score=score 
  }
  print(json.encode(data))
  local response = Request.post(BACKEND_PATH, data)
  userId = response['_id']
  print(userId)
end

return Backend
