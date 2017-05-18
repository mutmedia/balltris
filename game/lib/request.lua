local http = require 'socket.http'
local ltn12 = require 'ltn12'
local json = require 'lib/json'

local Request = {}
function Request.post(path, data)
  local path = path
  local payload = json.encode(data)
  --print('oioioio')
  local response_body = { }
  local res, code, response_headers, status = http.request
  {
    url = path,
    method = "POST",
    headers =
    {
      ["Authorization"] = "Maybe you need an Authorization header?", 
      ["Content-Type"] = "application/json",
      ["Content-Length"] = payload:len()
    },
    source = ltn12.source.string(payload),
    sink = ltn12.sink.table(response_body)
  }
  -- TODO: use code to check for errors
  local body = table.concat(response_body)
  print(body)
  return json.decode(body)
end

return Request

