local Vector = {}
Vector.mt = {}

function Vector.New(x, y)
  local v = {}
  v.x = x or 0
  v.y = y or 0
  setmetatable(v, Vector.mt)
  return v
end

function Vector.add(a, b)
  return Vector.New((a.x + b.x), (a.y + b.y))
end

function Vector.subtract(a, b)
  return Vector.New((a.x - b.x), (a.y - b.y))
end

function Vector.negate(a)
  return Vector.New(-a.x, -a.y)
end

function Vector.multiply(v, c)
  return Vector.New(v.x*c, v.y*c)
end

function Vector:sqrLength()
  return self.x * self.x + self.y * self.y
end

function Vector:length()
  return math.sqrt(self:sqrLength())
end

function Vector:normalized()
  local x = self.x / self:length()
  local y = self.y / self:length()
  return Vector.New(x, y) 
end
      

Vector.mt.__add = Vector.add
Vector.mt.__sub = Vector.subtract
Vector.mt.__unm = Vector.negate
Vector.mt.__mul = Vector.multiply
Vector.mt.__index = Vector

return Vector

