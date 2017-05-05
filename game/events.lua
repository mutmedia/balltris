local List = require 'doubly_linked_list'

-- Events
EVENT_MOVED_PREVIEW = 'previewMoved'
EVENT_RELEASED_PREVIEW = 'previewReleased'
EVENT_PRESSED_SWITCH = 'switchReleased'
EVENT_ON_BALLS_STATIC = 'ballsStatic'
EVENT_SAFE_TO_DROP = 'safeToDrop'
EVENT_BALLS_TOO_HIGH = 'ballsTooHigh'
EVENT_OPEN_MENU = 'ballsTooHigh'
EVENT_COMBO_START = 'combostarted'
EVENT_COMBO_END = 'comboended'
EVENT_SCORED = 'scored'

Events = {
  _callBacks = {},
}

local EVENT_ONCE = 0
local EVENT_PERMANENT = 1

function addNew(eventName, callback, type)
  if not Events._callBacks[eventName] then
    Events._callBacks[eventName] = List.new()
  end
  local callbackObject = {
    call = callback,
    type=type,
  }
  Events._callBacks[eventName]:add(callbackObject)
end

function Events.add(eventName, callback)
  addNew(eventName, callback, EVENT_PERMANENT)
end

function Events.schedule(eventName, callback)
  addNew(eventName, callback, EVENT_ONCE)
end

function Events.fire(eventName, ...)
  local arg = {...}
  if not Events._callBacks[eventName] then 
    return 
  end
  Events._callBacks[eventName]:Clean()
  
  Events._callBacks[eventName]:forEach(function(callback)
    callback.call(unpack(arg))
    if callback.type == EVENT_ONCE then
      Events._callBacks[eventName]:SetToDelete(callback)
    end
  end)

end

function Events.clear()
  Events._callBacks = {}
end

return Events

