local Stack = {}

function Stack.New(free)
  local q = {_stack=nil, _free = free or function() end}
  q.size = 0
  setmetatable(q, {__index=Stack})
  return q
end

function Stack:push(elem)
  local new = {prev=self._stack, val=elem}

  self._stack = new
  self.size = self.size + 1
end

function Stack:pop()
  if not self._stack then
    return nil
  end

  local elem = self._stack
  self._stack = self._stack.prev
  self.size = self.size - 1
  return elem.val
end

function Stack:peek()
  if not self._stack then 
    return nil
  end
  return self._stack.val
end

function Stack:forEach(func) 
  local q = self._stack
  while q do
    func(q.val)
    q = q.prev
  end
end

function Stack:clear(free)
  self:forEach(function(del)
    self._free(del)
  end)
  self._stack = nil
end

return Stack

