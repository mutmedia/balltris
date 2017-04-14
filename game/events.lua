require 'game_debug'

local List = require 'doubly_linked_list'

-- Events
EVENT_MOVED_PREVIEW = 'previewMoved'
EVENT_RELEASED_PREVIEW = 'previewReleased'
EVENT_PRESSED_SWITCH = 'switchReleased'
EVENT_ON_BALLS_STATIC = 'ballsStatic'

game = game or {}

game.events = {}

function game.events:add(eventName, callback)
  if not self[eventName] then
    self[eventName] = List.new()
  end
  local callbackObject = {
    call = callback
  }
  self[eventName]:add(callbackObject)
end

function game.events:fire(eventName, ...)
  local arg = {...}
  if not self[eventName] then 
    DEBUGGER.line('No event named: '..eventName)
    return 
  end
  
  --DEBUGGER.line('Firing event: '..eventName)
  local argstr = ''
  for k, v in pairs(arg) do
    argstr = argstr..tostring(k)..'='..tostring(v)..'; '
  end

  --DEBUGGER.line('args: '..argstr)


  self[eventName]:forEach(function(callback)
    callback.call(unpack(arg))
  end)
end

