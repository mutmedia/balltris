require 'game_debug'

local List = require 'doubly_linked_list'

-- Events
EVENT_MOVED_PREVIEW = 'previewMoved'
EVENT_RELEASED_PREVIEW = 'previewReleased'
EVENT_PRESSED_SWITCH = 'switchReleased'
EVENT_ON_BALLS_STATIC = 'ballsStatic'
EVENT_SAFE_TO_DROP = 'safeToDrop'
EVENT_BALLS_TOO_HIGH = 'ballsTooHigh'

Events = {
  _callBacks = {},
}

function Events.add(eventName, callback)
  if not Events._callBacks[eventName] then
    DEBUGGER.line('New event type')
    Events._callBacks[eventName] = List.new()
  end
  local callbackObject = {
    call = callback
  }
  Events._callBacks[eventName]:add(callbackObject)
end

function Events.fire(eventName, ...)
  local arg = {...}
  if not Events._callBacks[eventName] then 
    DEBUGGER.line('No event named: '..eventName)
    return 
  end
  
  --DEBUGGER.line('Firing event: '..eventName)
  Events._callBacks[eventName]:forEach(function(callback)
    callback.call(unpack(arg))
  end)
end

function Events.clear()
  --Events._callBacks = {}
end

return Events

