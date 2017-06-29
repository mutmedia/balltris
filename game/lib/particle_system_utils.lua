local ParticleSystemUtils = {}
local Vector = require 'lib/vector2d'


function MixColors(color1, color2, k)
local mix = {
      (1-k) * color1[1] + k * color2[1],
      (1-k) * color1[2] + k * color2[2],
      (1-k) * color1[3] + k * color2[3],
    }
    if color1[4] and color2[4] then
      mix[4] = (1-k) * color1[4] + k * color2[4]
    end
    return mix
  end


function ParticleSystemUtils.RGBGradient(initialColor, finalColor)
  return function(k)
    return MixColors(initialColor, finalColor, k)
  end
end

function ParticleSystemUtils.MultiRGBGradient(n, colors)
  return function(k)
    local i = math.floor(k * (n-1)) + 1
    local k2 = (k*(n-1) - (i - 1))
    return MixColors(colors[i], colors[i+1], k2)
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

