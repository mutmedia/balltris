local http = require 'socket.http'
local ltn12 = require 'ltn12'
local json = require 'lib/json'

local Request = {}

function DoRequest(request)

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
  print('code:', code)
  print('response_headers:', response_headers)
  if code ~= 200 and code ~= 209 then
    local body = table.concat(response_body)
    print(body)
    return false, code
  end

  local body = table.concat(response_body)
  print(body)
  return true, json.decode(body)
end

function Request.patch(path, data)
  return DoRequest{
    url = path,
    method = "PATCH",
    data = data,
  }
end

function Request.post(path, data)
  local path = path
  return DoRequest{
    url = path,
    method = "POST",
    data = data,
  }
end


function Request.get(path, data)
  return DoRequest{
    url = path,
    method = "GET",
  }
end

return Request

