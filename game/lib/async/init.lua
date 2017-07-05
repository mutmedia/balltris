local Scheduler = require 'lib/scheduler'

function Async(func, interval)
  local call = 0

  local nest = function()
    for i=100, 110 do
      print('banana '..i)
      coroutine.yield()
    end
  end
  ffunc = function() 
    for i=0,10 do
      print('potato '..i..' '..call)
      nest()
      coroutine.yield()
    end
  end
  interval = interval or 0
  local asyncCoroutine = coroutine.create(func)
  local function doThingAndWait()
    local ok, errmsg = coroutine.resume(asyncCoroutine)
    if not ok then
      error(errmsg)
    end
    if coroutine.status(asyncCoroutine) == 'dead' then
      return
    else
      Scheduler.add(function()
        call = call + 1
        doThingAndWait()
      end, 0)
  end
end

doThingAndWait()
end

return Async
