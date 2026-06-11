-- if jit then jit.off() end
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
  love.graphics.setFont(love.graphics.newFont(40))
  -- love.event.quit()
  game = Game.new(0) -- Was maybe 25% more boids with separate x & y.
end

local fps = 0.0

function love.draw()
  game:draw()
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
  love.graphics.print("Boids: " .. #game.boids, 10, 50)
  local score = math.pow(#game.boids, 2) / 1000
  love.graphics.print(string.format("Score: %.1f", score), 10, 90)
end

---@param dt number
function love.update(dt)
  game:update(dt)
  fps = 0.9 * fps + 0.1 / dt
  if fps > 40 then
    game:addBoid()
  end
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
  local pos = v2.mul(v2.init(love.math.random), self.size)
  -- Velocity.
  local vel = v2.addNum(v2.init(love.math.random), -0.5)
  v2.normalize(vel, vel)
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
  local half = v2.mulNum(size, 0.5)
  local delta = v2.add(boidToward, v2.mulNum(boidFrom, -1.0), target)
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
    local pos = v2.addNum(boid.pos, -1.0)
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
    local distance = v2.norm(delta)
    if distance < reach then
      local w = 1.0 - distance / reach
      local wdv = math.pow(w, 5.0)
      v2.add(meanDelta, v2.mulNum(delta, wdv), meanDelta)
      v2.add(meanTrend, v2.mulNum(otherBoid.vel, wdv), meanTrend)
      weight = weight + wdv
      -- Spread.
      local ws = math.pow(w, 10.0)
      v2.add(meanSpread, v2.mulNum(delta, -ws), meanSpread)
      spreadWeight = spreadWeight + ws
    end
  end
  -- Mix together.
  if weight ~= 0.0 then
    local vel = v2.mulNum(boid.vel, 1.0, boid.vel)
    -- TODO Adjust impact by update time duration.
    v2.add(vel, v2.mulNum(meanDelta, 0.01 / weight, meanDelta), vel)
    v2.add(vel, v2.mulNum(meanTrend, 0.03 / weight, meanTrend), vel)
    v2.add(vel, v2.mulNum(meanSpread, 0.02 / spreadWeight, meanSpread), vel)
    v2.normalize(vel, vel)
  end
end

---@param dt number
function Game:update(dt)
  local speed = self.speed
  for _, boid in ipairs(self.boids) do
    updateBoidVel(self, boid)
    v2.add(boid.pos, v2.mulNum(boid.vel, speed * dt), boid.pos)
    self:wrap(boid.pos)
  end
end

---@param pos v2.Vec2 Modified in place.
---@return v2.Vec2
function Game:wrap(pos)
  return v2.fmod(v2.add(pos, self.size, pos), self.size, pos)
end
