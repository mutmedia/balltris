local List = require 'lib/doubly_linked_list'

local Scheduler = {
  _schedule = {},
  _time = 0,
}

function Scheduler.add(func, dt)
  local time = Scheduler._time + dt
  if not Scheduler._schedule[time] then
    Scheduler._schedule[time] = {} 
  end
  table.insert(Scheduler._schedule[time], func)
end

function Scheduler.update(dt)
  Scheduler._time = Scheduler._time + dt
  for time, funcs in pairs(Scheduler._schedule) do
    if time <= Scheduler._time then
      for i, func in ipairs(funcs) do
        func()
      end
      Scheduler._schedule[time] = {}
    end
  end
end

return Scheduler
