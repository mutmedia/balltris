local Set = {}

function Set.New(list)
  local s = {}
  setmetatable(s, {__index = Set})
  if list then
    for _, l in ipairs(list) do s[l] = true end
  end
  s._count = 0
  return s
end

function Set:add(element)
  if element then
    self[element] = true
    self._count = self._count + 1
  end
end

function Set:remove(element)
  if self[element] then
    self[element] = nil
    self._count = self._count -1
  end
end

function Set:contains(element)
  return self[element] and true or false
end

function Set:count()
  return self._count
end

return Set
