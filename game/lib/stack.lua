local Stack = {}

function Stack.new(free)
  local q = {_stack=nil, _free = free or function() end}
  q._stack_bottom = nil
  q.size = 0
  setmetatable(q, {__index=Stack})
  return q
end

function Stack:push(elem)
  local new = {prev=self._stack, next=nil, val=elem}
  new.val._ref = new

  if not self._stack_bottom then
    self._stack_bottom = new
  end

  if self._stack then
    self._stack.next = new
  end
  self._stack = new
  self.size = self.size + 1
end

function Stack:pop()
  if not self._stack then
    return nil
  end

  local elem = self._stack
  self._stack = self._stack.prev
  if self._stack then
    self._stack.next = nil
  end
  self.size = self.size - 1
  return elem.val
end

function Stack:forEach(func) 
  local q = self._stack_bottom
  while q do
    func(q.val)
    q = q.next
  end
end

function Stack:clear(free)
  self:forEach(function(del)
    self._free(del)
  end)
  self._stack = nil
end

return Stack

