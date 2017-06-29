local ParticleSystemUtils = {}
local Vector = require 'lib/vector2d'

function ParticleSystemUtils.RGBGradient(initialColor, finalColor)
  return function(k)
    local mix = {
      (1-k) * initialColor[1] + k * finalColor[1],
      (1-k) * initialColor[2] + k * finalColor[2],
      (1-k) * initialColor[3] + k * finalColor[3],
    }
    if initialColor[4] and finalColor[4] then
      mix[4] = (1-k) * initialColor[4] + k * finalColor[4]
    end
    return mix
  end
end

function ParticleSystemUtils.RandomRadialUnitVector()
  local angle = 2 * math.pi * math.random()
  return Vector.New(math.cos(angle), math.sin(angle))
end

function ColorDraw(func)
  return function(color, position, rotation, scale)
    love.graphics.setColor(color)
    func(position, rotation, scale)
  end
end

function ParticleSystemUtils.CircularParticlesDraw(radius)
  return ColorDraw(function(position, rotation, scale)
    love.graphics.circle(
      'fill',
      position.x,
      position.y,
      scale * radius)
  end)
end

function ParticleSystemUtils.SquareParticlesDraw(side)
  return ColorDraw(function(position, rotation, scale)
    local s = side * scale
    love.graphics.rectangle(
      'fill',
      position.x - s/2,
      position.y - s/2,
      s,
      s)
  end)
end




return ParticleSystemUtils

