local List = require 'lib/doubly_linked_list'
local Vector = require 'lib/vector2d'
local ParticleSystemUtils = require'lib/particle_system_utils'
local ParticleSystem = {}
ParticleSystem._systems = List.New()


function ParticleSystem.New(params)
  local ps = {}

  -- attributes
  ps.duration = params.duration or 0
  ps.particleLifeTime = params.particleLifeTime or 0
  ps.particleAcceleration = params.particleAcceleration or Vector.New()
  ps.rateOverTime = params.rateOverTime or 10

  -- functions
  ps.scaleOverLifeTime = params.scaleOverLifeTime or function(k) return 1-k end
  ps.colorOverLifeTime = params.colorOverLifeTime or ParticleSystemUtils.RGBGradient({1, 1, 1, 1}, {0, 0, 0, 0})
  ps.getInitialPosition = params.getInitialPosition or function() return Vector.New() end
  ps.getInitialVelocity = params.getInitialVelocity or ParticleSystemUtils.RandomRadialUnitVector
  ps.particleDraw = params.particleDraw or ParticleSystemUtils.CircularParticlesDraw(10)

  -- private data
  ps._particles = List.New()
  ps._time = 0
  ps._over = false

  setmetatable(ps, {__index=ParticleSystem})
  ParticleSystem._systems:add(ps)
  return ps
end

function ParticleSystem.Update(dt)
  ParticleSystem._systems:forEach(function(ps)
    ps:_update(dt)
    if ps._over then
      ParticleSystem._systems:SetToDelete(ps)
    end
  end)
  ParticleSystem._systems:Clean()
end

function ParticleSystem.Draw()
  ParticleSystem._systems:forEach(function(ps)
    ps:_draw()
  end)
end

function ParticleSystem:_spawnParticle(time)
  local particle = {}
  particle.position = self.getInitialPosition(time)
  particle.velocity = self.getInitialVelocity(particle.position, time)
  particle.color = self.colorOverLifeTime(0)
  particle.scale = self.scaleOverLifeTime(0)
  particle.lifeTime = 0
  self._particles:add(particle)
end

function ParticleSystem:_draw()
  if self._over then return end
  if self.drawCondition and not self.drawCondition() then return end
  self._particles:forEach(function(p)
    -- Draw particle

    self.particleDraw(p.color, p.position, 0, p.scale) -- 0 is rotation not yet implemented
  end)
end

function ParticleSystem:_update(dt)
  if self._time >= self.duration + self.particleLifeTime then
    self._over = true
    self._particles:Clear()
    self._particles:Clean()
    return
  end
  if self._over then return end
  -- Spawn new particles
  if self._particles:Count()/self._time < self.rateOverTime and self._time < self.duration then
    self:_spawnParticle(self._time)
  end

  -- Update and draw existing particles
  self._particles:forEach(function(p)
    p.lifeTime = p.lifeTime + dt
    if p.lifeTime >= self.particleLifeTime then
      self._particles:SetToDelete(p)
      return
    end

    -- Update particle positions
    p.velocity = p.velocity + self.particleAcceleration * dt
    p.position = p.position + p.velocity * dt
    p.scale = self.scaleOverLifeTime(p.lifeTime/self.particleLifeTime)
    p.color = self.colorOverLifeTime(p.lifeTime/self.particleLifeTime)

  end)

  self._time = self._time + dt
  self._particles:Clean()
end

return ParticleSystem
