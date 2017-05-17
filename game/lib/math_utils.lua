local utils = {}

function utils.isInsideRect(x, y, x0, y0, x1, y1)
  return x >= x0 and x <= x1 and y >= y0 and y <= y1
end

function utils.clamp(val, min, max)
  if val > max then 
    return max
  elseif val < min then
    return min
  else
    return val
  end
end

math.clamp = utils.clamp
math.isInsideRect = utils.isInsideRect



