local Queue = {}

function Queue.New(free)
  local q = {_queue=nil, _free = free or function() end}
  q._queue_front = nil 
  q.size = 0
  setmetatable(q, {__index=Queue})
  return q
end

function Queue:enqueue(elem)
  local new = {prev=nil, val=elem}
  new.val._ref = new

  if self._queue then
    self._queue.prev = new
  end

  if not self._queue_front then
    self._queue_front = new
  end

  self._queue = new
  self.size = self.size + 1
end

function Queue:dequeue()
  if not self._queue_front then
    return nil
  end

  local elem = self._queue_front
  self._queue_front = self._queue_front.prev
  self.size = self.size - 1
  return elem.val
end

function Queue:forEach(func) 
  local q = self._queue_front
  while q do
    func(q.val)
    q = q.prev
  end
end

function Queue:clear(free)
  self:forEach(function(del)
    self._free(del)
  end)
  self._queue = nil
end

return Queue

