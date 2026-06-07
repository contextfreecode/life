---@class life.Game
---@field boids life.Boid[]
---@field reach number
---@field speed number
---@field sizeX number
---@field sizeY number
local Game = {}
Game.__index = Game

---@class life.Boid
---@field vx number
---@field vy number
---@field x number
---@field y number

---@type life.Game
local game

function love.load()
  love.window.setMode(0, 0, { fullscreen = true })
  love.window.setTitle("Boids")
  love.graphics.setBackgroundColor({ 0.17, 0.17, 0.22 })
  love.graphics.setColor({ 0.91, 0.91, 0.91 })
  -- love.event.quit()
  game = Game.new(550)
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
  local sizeX, sizeY = love.graphics.getDimensions()
  local size_max = math.max(sizeX, sizeY)
  local game = setmetatable({
    boids = {},
    reach = 0.05 * size_max,
    sizeX = sizeX,
    sizeY = sizeY,
    speed = 0.1 * size_max,
  }, Game)
  for _ = 1, boidCount do
    game:addBoid()
  end
  return game
end

-- Needing to predeclare local functions is some stress.

---@param x number
---@param y number
---@return number
local function normOf(x, y)
  return math.sqrt(x * x + y * y)
end

---@param x number
---@param y number
---@return number, number
local function normalize(x, y)
  local norm = normOf(x, y)
  return x / norm, y / norm
end

function Game:addBoid()
  -- Location.
  local x, y = self:wrap(
    self.sizeX * love.math.random(),
    self.sizeY * love.math.random()
  )
  -- Velocity.
  local vx = love.math.random() - 0.5
  local vy = love.math.random() - 0.5
  vx, vy = normalize(vx, vy)
  ---@type life.Boid
  local boid = {
    vx = vx,
    vy = vy,
    x = x,
    y = y,
  }
  -- Insert.
  table.insert(self.boids, boid)
end

---@param boidToward life.Boid
---@param boidFrom life.Boid
---@return number, number
function Game:delta(boidToward, boidFrom)
  -- Gather locals.
  local x2, y2 = boidToward.x, boidToward.y
  local x1, y1 = boidFrom.x, boidFrom.y
  local sizeX, sizeY = self.sizeX, self.sizeY
  local halfX, halfY = sizeX / 2, sizeY / 2
  local dx, dy = x2 - x1, y2 - y1
  -- Wrap delta.
  if dx < -halfX then
    dx = dx + sizeX
  elseif dx > halfX then
    dx = dx - sizeX
  end
  if dy < -halfY then
    dy = dy + sizeY
  elseif dy > halfY then
    dy = dy - sizeY
  end
  return dx, dy
end

function Game:draw()
  for _, boid in ipairs(self.boids) do
    love.graphics.rectangle("fill", boid.x - 1, boid.y - 1, 3, 3)
  end
end

---@param boid life.Boid
local function updateBoidVel(game, boid)
  local reach = game.reach
  local vx, vy = boid.vx, boid.vy
  local mdx, mdy = 0.0, 0.0 -- mean delta toward neighbors
  local msx, msy = 0.0, 0.0 -- mean spread against neighbors
  local mvx, mvy = 0.0, 0.0 -- mean velocity of neighbors
  local weight = 0.0
  local spreadWeight = 0.0
  for _, otherBoid in ipairs(game.boids) do
    local dx, dy = game:delta(otherBoid, boid)
    local distance = normOf(dx, dy)
    if distance < reach then
      local w = 1.0 - distance / reach
      local wdv = math.pow(w, 5.0)
      mdx, mdy = mdx + dx * wdv, mdy + dy * wdv
      mvx, mvy = mvx + otherBoid.vx * wdv, mvy + otherBoid.vy * wdv
      weight = weight + wdv
      -- Spread.
      local sw = math.pow(w, 10.0)
      msx, msy = msx - dx * sw, msy - dy * sw
      spreadWeight = spreadWeight + sw
    end
  end
  -- Mix together.
  if weight ~= 0.0 then
    mdx, mdy = mdx / weight, mdy / weight
    mvx, mvy = mvx / weight, mvy / weight
    msx, msy = msx / spreadWeight, msy / spreadWeight
    local w0, wv, wd, ws = 1.0, 0.03, 0.01, 0.02
    boid.vx, boid.vy = normalize(
      w0 * vx + wv * mvx + wd * mdx + ws * msx,
      w0 * vy + wv * mvy + wd * mdy + ws * msy
    )
  end
end

---@param dt number
function Game:update(dt)
  local speed = self.speed
  for _, boid in ipairs(self.boids) do
    updateBoidVel(self, boid)
    boid.x, boid.y = self:wrap(
      boid.x + speed * boid.vx * dt,
      boid.y + speed * boid.vy * dt
    )
  end
end

---@param x number
---@param y number
---@return number, number
function Game:wrap(x, y)
  return math.fmod(x + self.sizeX, self.sizeX),
      math.fmod(y + self.sizeY, self.sizeY)
end
