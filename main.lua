local v2 = require("v2")

---@class life.Game
---@field boids life.Boid[]
---@field reach number
---@field speed number
---@field size v2.Vec2
local Game = {}
Game.__index = Game

---@class life.Boid
---@field vel v2.Vec2
---@field pos v2.Vec2

---@type life.Game
local game

function love.load()
  love.window.setMode(0, 0, { fullscreen = true })
  love.window.setTitle("Boids")
  love.graphics.setBackgroundColor({ 0.17, 0.17, 0.22 })
  love.graphics.setColor({ 0.91, 0.91, 0.91 })
  -- love.event.quit()
  game = Game.new(450) -- Was more like 550 with separate x & y.
end

function love.draw()
  game:draw()
  love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

---@param dt number
function love.update(dt)
  game:update(dt)
end

---@param boidCount integer
function Game.new(boidCount)
  local size = { love.graphics.getDimensions() }
  local size_max = math.max(size[1], size[2])
  local game = setmetatable({
    boids = {},
    reach = 0.05 * size_max,
    size = size,
    speed = 0.1 * size_max,
  }, Game)
  for _ = 1, boidCount do
    game:addBoid()
  end
  return game
end

function Game:addBoid()
  -- Location.
  local pos = v2.mul({ love.math.random(), love.math.random() }, self.size)
  -- Velocity.
  local vel = v2.addScalar({ love.math.random(), love.math.random() }, -0.5)
  vel = v2.normalize(vel)
  ---@type life.Boid
  local boid = { pos = pos, vel = vel }
  table.insert(self.boids, boid)
end

---@param boidToward life.Boid
---@param boidFrom life.Boid
---@param target? v2.Vec2
---@return v2.Vec2
function Game:delta(boidToward, boidFrom, target)
  -- Gather locals.
  local size = self.size
  local half = v2.mulScalar(size, 0.5)
  local delta = v2.add(boidToward, v2.mulScalar(boidFrom, -1.0), target)
  -- Wrap delta.
  if delta[1] < -half[1] then
    delta[1] = delta[1] + size[1]
  elseif delta[1] > half[1] then
    delta[1] = delta[1] - size[1]
  end
  if delta[2] < -half[2] then
    delta[2] = delta[2] + size[2]
  elseif delta[2] > half[2] then
    delta[2] = delta[2] - size[2]
  end
  return delta
end

function Game:draw()
  for _, boid in ipairs(self.boids) do
    local pos = v2.addScalar(boid.pos, -1.0)
    love.graphics.rectangle("fill", pos[1], pos[2], 3, 3)
  end
end

---@param game life.Game
---@param boid life.Boid
local function updateBoidVel(game, boid)
  local reach = game.reach
  local delta = v2.zero()
  local meanDelta = v2.zero()
  local meanTrend = v2.zero()
  local meanSpread = v2.zero()
  local weight = 0.0
  local spreadWeight = 0.0
  for _, otherBoid in ipairs(game.boids) do
    game:delta(otherBoid.pos, boid.pos, delta)
    local distance = v2.normOf(delta)
    if distance < reach then
      local w = 1.0 - distance / reach
      local wdv = math.pow(w, 5.0)
      v2.add(meanDelta, v2.mulScalar(delta, wdv), meanDelta)
      v2.add(meanTrend, v2.mulScalar(otherBoid.vel, wdv), meanTrend)
      weight = weight + wdv
      -- Spread.
      local ws = math.pow(w, 10.0)
      v2.add(meanSpread, v2.mulScalar(delta, -ws), meanSpread)
      spreadWeight = spreadWeight + ws
    end
  end
  -- Mix together.
  if weight ~= 0.0 then
    local vel = v2.mulScalar(boid.vel, 1.0, boid.vel)
    -- TODO Adjust impact by update time duration.
    v2.add(vel, v2.mulScalar(meanDelta, 0.01 / weight, meanDelta), vel)
    v2.add(vel, v2.mulScalar(meanTrend, 0.03 / weight, meanTrend), vel)
    v2.add(vel, v2.mulScalar(meanSpread, 0.02 / spreadWeight, meanSpread), vel)
    v2.normalize(vel, vel)
  end
end

---@param dt number
function Game:update(dt)
  local speed = self.speed
  for _, boid in ipairs(self.boids) do
    updateBoidVel(self, boid)
    v2.add(boid.pos, v2.mulScalar(boid.vel, speed * dt), boid.pos)
    self:wrap(boid.pos)
  end
end

---@param pos v2.Vec2 Modified in place.
---@return v2.Vec2
function Game:wrap(pos)
  return v2.fmod(v2.add(pos, self.size, pos), self.size, pos)
end
