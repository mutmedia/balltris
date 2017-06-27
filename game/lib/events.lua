local List = require 'lib/doubly_linked_list'

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
