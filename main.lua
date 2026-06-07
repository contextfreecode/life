local v = require("v")

---@class life.Game
---@field boids life.Boid[]
---@field reach number
---@field speed number
---@field size v.Vec2
local Game = {}
Game.__index = Game

---@class life.Boid
---@field vel v.Vec2
---@field pos v.Vec2

---@type life.Game
local game

function love.load()
  love.window.setMode(0, 0, { fullscreen = true })
  love.window.setTitle("Boids")
  love.graphics.setBackgroundColor({ 0.17, 0.17, 0.22 })
  love.graphics.setColor({ 0.91, 0.91, 0.91 })
  -- love.event.quit()
  game = Game.new(450)
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
  local size = {love.graphics.getDimensions()}
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
  local pos = v.mul({ love.math.random(), love.math.random() }, self.size)
  -- Velocity.
  local vel = v.addScalar({ love.math.random(), love.math.random() }, -0.5)
  vel = v.normalize(vel)
  ---@type life.Boid
  local boid = { pos = pos, vel = vel }
  table.insert(self.boids, boid)
end

---@param boidToward life.Boid
---@param boidFrom life.Boid
---@return v.Vec2
function Game:delta(boidToward, boidFrom)
  -- Gather locals.
  local size = self.size
  local half = v.mulScalar(size, 0.5)
  local delta = v.add(boidToward, v.mulScalar(boidFrom, -1.0))
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
    local pos = v.addScalar(boid.pos, -1.0)
    love.graphics.rectangle("fill", pos[1], pos[2], 3, 3)
  end
end

---@param game life.Game
---@param boid life.Boid
local function updateBoidVel(game, boid)
  local reach = game.reach
  local vel = boid.vel
  local mean_delta = {0.0, 0.0}
  local mean_trend = {0.0, 0.0}
  local mean_spread = {0.0, 0.0}
  local weight = 0.0
  local spreadWeight = 0.0
  for _, otherBoid in ipairs(game.boids) do
    local delta = game:delta(otherBoid.pos, boid.pos)
    local distance = v.normOf(delta)
    if distance < reach then
      local w = 1.0 - distance / reach
      local wdv = math.pow(w, 5.0)
      v.addInto(mean_delta, mean_delta, v.mulScalar(delta, wdv))
      v.addInto(mean_trend, mean_trend, v.mulScalar(otherBoid.vel, wdv))
      weight = weight + wdv
      -- Spread.
      local ws = math.pow(w, 10.0)
      v.addInto(mean_spread, mean_spread, v.mulScalar(delta, -ws))
      spreadWeight = spreadWeight + ws
    end
  end
  -- Mix together.
  if weight ~= 0.0 then
    vel = v.mulScalar(boid.vel, 1.0)
    -- TODO Adjust impact by update time duration.
    v.mulScalarInto(mean_delta, mean_delta, 0.01 / weight)
    v.mulScalarInto(mean_trend, mean_trend, 0.03 / weight)
    v.mulScalarInto(mean_spread, mean_spread, 0.02 / spreadWeight)
    v.addInto(vel, vel, mean_delta)
    v.addInto(vel, vel, mean_trend)
    v.addInto(vel, vel, mean_spread)
    boid.vel = v.normalize(vel)
  end
end

---@param dt number
function Game:update(dt)
  local speed = self.speed
  for _, boid in ipairs(self.boids) do
    updateBoidVel(self, boid)
    boid.pos = self:wrap(v.add(boid.pos, v.mulScalar(boid.vel, speed * dt)))
  end
end

---@param pos v.Vec2
---@return v.Vec2
function Game:wrap(pos)
  pos = v.add(pos, self.size)
  return { math.fmod(pos[1], self.size[1]), math.fmod(pos[2], self.size[2]) }
end
