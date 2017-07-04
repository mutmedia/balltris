local Set = {}

function Set.New(list)
  local s = {}
  setmetatable(s, {__index = Set})
  if list then
    for _, l in ipairs(list) do s[l] = true end
  end
  return s
end

function Set:add(element)
  if element then
    self[element] = true
  end
end

function Set:remove(element)
  self[element] = nil
end

function Set:contains(element)
  return self[element] and true or false
end

return Set
