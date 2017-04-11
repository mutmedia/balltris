local List = {}

function List.new()
  local l = {list=nil}
  setmetatable(l, {__index=List})
  return l
end

function List:add(elem)
  local new = {next=self.list, prev=nil, val=elem}
  new.val.ref = new
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
  self.toDelete:add(elem.ref)
end

function List:Clean(free)
  if not self.toDelete then
    return
  end
  local free = free or function () end
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

    free(del.val)
    del = nil
  end)
  self.toDelete = nil
end

function List:Clear()
  self.list = nil
end

return List
