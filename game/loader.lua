local dataToLoadChannel = love.thread.getChannel('data_to_load')
local dataLoadedChannel = love.thread.getChannel('data_loaded')
local threadPrintChannel = love.thread.getChannel('thread_print')

local callbacks = {
  print = function(value)
    threadPrintChannel:push('Print requested: '..value)
  end,
  shader = function(value) 
    threadPrintChannel:push('THREAD: Loading new shader')
    local ok, v = pcall(function() love.graphics.newShader(unpack(value)) end)
    if not ok then
      threadPrintChannel:push('ERROR: Shader loading error: '..tostring(v))
    end

    threadPrintChannel:push('Shader loaded: '..tostring(v))
    threadPrintChannel:push(tostring(v))
  end
}

while true do
  local v = dataToLoadChannel:pop()
  if v then
    threadPrintChannel:push('THREAD: New data to load!')
    if not v.type then
      threadPrintChannel:push('THREAD ERROR: Data to load has no type')
      return
    elseif not v.value then
      threadPrintChannel:push('THREAD ERROR: Data to load has no value')
      return
    elseif not callbacks[v.type] then
      threadPrintChannel:push('THREAD ERROR: Data to load type not supported')
      return
    end
    threadPrintChannel:push('THREAD: Calling load for type: '..v.type..' with value: '..tostring(v.value))
    callbacks[v.type](v.value)
  end
end

