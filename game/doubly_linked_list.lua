local List = {}

function List.new(free)
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
  if not self.toDelete then
    self.toDelete = List.new()
  end
  self.toDelete:add(elem._ref)
end

function List:Clean(free)
  if not self.toDelete then
    return
  end
  self.toDelete:forEach(function(del)
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
  self.toDelete = nil
end

function List:Clear()
  self:forEach(function(del)
    self:SetToDelete(del)
  end)
  self.list = nil
end

return List
