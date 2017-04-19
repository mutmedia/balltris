local RandomBag = {}

function RandomBag.new(numElems, modifier)
  local rb = {}
  rb.size = numElems
  rb.modifier = modifier
  for i=1, rb.size do
    rb[i] = 1
  end
  setmetatable(rb, {__index = RandomBag})
  rb:normalize()
  return rb
end

function RandomBag:get()
  local randomnum = math.random()
  local acc = 0
  for i=1, self.size do
    acc = acc + self[i]
    if acc > randomnum then
      return i
    end
  end
end

function RandomBag:normalize()
  local sum = 0
  for i=1, self.size do
    sum = sum + self[i]
  end
  for i=1, self.size do
    self[i] = self[i]/sum
  end
end

function RandomBag:update(num)
  self[num] = self[num] * self.modifier
  self:normalize()
end

return RandomBag

