local List = {}

function List.New(free)
  local l = {list=nil, __free = free or function() end}
  setmetatable(l, {__index=List})
  return l
end

function List:add(elem)
  local new = {next=self.list, prev=nil, val=elem}
  new.val._ref = new
  if self.list then
    self.list.prev = new
  end
  self.list = new
end

function List:forEach(func) 
  local l = self.list
  while l do
    func(l.val)
    l = l.next
  end
end

function List:SetToDelete(elem)
  if not self._toDelete then
    self._toDelete = List.New()
  end
  self._toDelete:add(elem._ref)
end

function List:Clean(free)
  if not self._toDelete then
    return
  end
  self._toDelete:forEach(function(del)
    if del == self.list then
      self.list = del.next
    end
    if del.next then
      del.next.prev = del.prev
    end
    if del.prev then
      del.prev.next = del.next
    end

    self.__free(del.val)
    del = nil
  end)
  self._toDelete = nil
end

function List:Clear()
  self:forEach(function(del)
    self:SetToDelete(del)
  end)
  self:Clean()
  self.list = nil
end

function List:Count()
  local c = 0
  self:forEach(function()
    c = c + 1
  end)
  return c
end

return List
