local Vector = {}
Vector.mt = {}

function Vector.new(params)
  local v = {}
  v.x = params.x
  v.y = params.y
  setmetatable(v, Vector.mt)
  return v
end

function Vector.add(a, b)
  return Vector.new{x=(a.x + b.x), y=(a.y + b.y)}
end

function Vector.subtract(a, b)
  return Vector.new{x=(a.x - b.x), y=(a.y - b.y)}
end

function Vector.negate(a)
  return Vector.new{x=-a.x, y=-a.y}
end

function Vector.multiply(v, c)
  return Vector.new{x=v.x*c, y=v.y*c}
end

Vector.mt.__add = Vector.add
Vector.mt.__sub = Vector.subtract
Vector.mt.__unm = Vector.negate
Vector.mt.__mul = Vector.multiply

return Vector

