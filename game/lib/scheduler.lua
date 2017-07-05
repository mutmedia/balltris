local List = require 'lib/doubly_linked_list'

local Scheduler = {
  _schedule = {},
  _time = 0,
}

local print = function(str)
  --print('SCHEDULER: '..(str or ''))
end

function Scheduler.add(func, dt)
  print('Adding new thing to schedule')
  dt = dt or 0
  dt = math.max(dt, 0)
  local time = Scheduler._time + dt
  if not Scheduler._schedule[time] then
    Scheduler._schedule[time] = {} 
  end
  table.insert(Scheduler._schedule[time], func)
end

function Scheduler.update(dt)
  Scheduler._time = Scheduler._time + dt

  local thingsToCall = {}
  for time, funcs in pairs(Scheduler._schedule) do
    if time <= Scheduler._time then
      for i, func in ipairs(funcs) do
        table.insert(thingsToCall, func)
      end
      Scheduler._schedule[time] = {}
    end
  end

  for _, f in pairs(thingsToCall) do
    f()
  end
end

return Scheduler
