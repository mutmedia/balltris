local http = require 'socket.http'
local ltn12 = require 'ltn12'
local json = require 'lib/json'
local NewGUID = require 'lib/guid'
local Scheduler = require 'lib/scheduler'

local Request = {}

local print = function(str)
  print('REQUEST: '..(str or ''))
end

function DoRequestSync(request)

  request.headers = {}
  request.headers["Content-Type"] = "application/json"

  if request.data then
    local payload = json.encode(request.data)
    request.source = ltn12.source.string(payload)
    request.headers["Content-Length"] = payload:len()
  end

  local response_body = {}
  request.sink = ltn12.sink.table(response_body)

  local res, code, response_headers, status = http.request(request)

  -- TODO: use code to check for errors
  headersString = {}
  table.insert(headersString, 'response_headers: {\n')

  if response_headers then 
    if type(response_headers) == 'string' then
      print(response_headers)
    else
    for k, v in ipairs(response_headers) do 
      table.insert(headersString, '\t'..k..' = '..v..',\n')
    end
    table.insert(headersString, '}')
    print(table.concat(headersString))
  end
  end

  local body = table.concat(response_body)
  print('response: '..body)
  print('code: '..(code or 'no code'))
  if code ~= 200 and code ~= 209 then
    return false, code
  end

  return true, json.decode(body)
end

-- Thread code
if type(...) == "number" then

  require 'love.timer'

  local index = ...
  local args = love.thread.getChannel(string.format('WEB_REQUEST_%d_ARGS', index)):pop()
  local ok, body = DoRequestSync(args)
  love.thread.getChannel(string.format('WEB_REQUEST_%d_RES', index)):push({ok, body})

else
  local filePath = (...):gsub('%.', '/') .. '.lua'

  function DoRequestCoroutine(request)
    local thread = love.thread.newThread(filePath)
    local index = NewGUID()
    love.thread.getChannel(string.format('WEB_REQUEST_%d_ARGS', index)):push(request)
    thread:start(index)
    local result = nil
    while result == nil do
      --print('trying to get new result')
      coroutine.yield()
      local err = thread:getError()
      if err then
        error(err)
      end
      result = love.thread.getChannel(string.format('WEB_REQUEST_%d_RES', index)):pop()
    end
    love.thread.getChannel(string.format('WEB_REQUEST_%d_RES', index)):clear()
    return unpack(result)
  end

  function Request.Patch(path, data)
    print('PATCH')
    return DoRequestCoroutine{
      url = path,
      method = "PATCH",
      data = data,
    }
  end

  function Request.Post(path, data)
    print('POST')
    local path = path
    return DoRequestCoroutine{
      url = path,
      method = "POST",
      data = data,
    }
  end


  function Request.Get(path)
    print('GET')
    return DoRequestCoroutine{
      url = path,
      method = "GET",
    }
  end

  return Request
end

