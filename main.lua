---@class life.Game
---@field boids life.Boid[][][]
---@field reachFraction number
---@field reach number
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
  game = Game.new()
  game.sizeX, game.sizeY = love.graphics.getDimensions()
  game:buildGrid()
  for _ = 1, 1000 do
    game:addBoid()
  end
end

function love.draw()
  game:draw()
  love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

---@param dt number
function love.update(dt)
  game:update(dt)
end

function Game.new()
  return setmetatable({
    boids = {},
    reachFraction = 0.1,
    reach = 0,
    sizeX = 0,
    sizeY = 0,
  }, Game)
end

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
  local vx = 2 * love.math.random() - 1
  local vy = 2 * love.math.random() - 1
  vx, vy = normalize(vx, vy)
  ---@type life.Boid
  local boid = {
    vx = vx,
    vy = vy,
    x = x,
    y = y,
  }
  -- Insert.
  local binX = math.floor(x / self.reach) + 1
  local binY = math.floor(y / self.reach) + 1
  table.insert(self.boids[binX][binY], boid)
end

function Game:buildGrid()
  local reach = self.reachFraction * math.max(self.sizeX, self.sizeY)
  self.reach = reach
  local maxBinX = math.floor((self.sizeX - 1) / reach) + 1
  local maxBinY = math.floor((self.sizeY - 1) / reach) + 1
  for _ = 1, maxBinX do
    ---@type life.Boid[][]
    local column = {}
    for _ = 1, maxBinY do
      table.insert(column, {})
    end
    table.insert(self.boids, column)
  end
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
  for _, column in ipairs(self.boids) do
    for _, cell in ipairs(column) do
      for _, boid in ipairs(cell) do
        love.graphics.rectangle("fill", boid.x - 1, boid.y - 1, 3, 3)
      end
    end
  end
end

function Game:rebin()
  for binX, column in ipairs(self.boids) do
    for binY, cell in ipairs(column) do
      for index, boid in ipairs(cell) do
        local newBinX = math.floor(boid.x / self.reach) + 1
        local newBinY = math.floor(boid.y / self.reach) + 1
        if not (binX == newBinX and binY == newBinY) then
          table.insert(self.boids[newBinX][newBinY], boid)
          cell[index] = cell[#cell]
          table.remove(cell)
        end
      end
    end
  end
end

---@param dt number
function Game:update(dt)
  local reach = self.reach
  local speed = reach
  for binX, column in ipairs(self.boids) do
    for binY, cell in ipairs(column) do
      for _, boid in ipairs(cell) do
        -- Adjust boid values.
        local x, y = boid.x, boid.y
        local vx, vy = boid.vx, boid.vy
        local mdx, mdy = 0.0, 0.0 -- mean delta toward neighbors
        local msx, msy = 0.0, 0.0 -- mean spread against neighbors
        local mvx, mvy = 0.0, 0.0 -- mean velocity of neighbors
        local weight = 0.0
        local spreadWeight = 0.0
        for otherBinDx = -1, 1 do
          local otherBinX = (binX + otherBinDx - 1) % #self.boids + 1
          local otherColumn = self.boids[otherBinX]
          for otherBinDy = -1, 1 do
            local otherBinY = (binY + otherBinDy - 1) % #otherColumn + 1
            local otherCell = otherColumn[otherBinY]
            for _, otherBoid in ipairs(otherCell) do
              local dx, dy = self:delta(otherBoid, boid)
              local distance = normOf(dx, dy)
              if distance < reach then
                local w = 1.0 - distance / reach
                mdx, mdy = mdx + dx * w, mdy + dy * w
                mvx, mvy = mvx + otherBoid.vx * w, mvy + otherBoid.vy * w
                weight = weight + w
                -- Spread.
                local sw = math.pow(w, 5.0)
                msx, msy = msx - dx * sw, msy - dy * sw
                spreadWeight = spreadWeight + sw
              end
            end
          end
        end
        -- Mix together.
        if weight ~= 0.0 then
          mdx, mdy = mdx / weight, mdy / weight
          mvx, mvy = mvx / weight, mvy / weight
          msx, msy = msx / spreadWeight, msy / spreadWeight
          local w0, wv, wd, ws = 0.9, 0.1, 0.01, 0.02
          vx, vy = normalize(
            w0 * vx + wv * mvx + wd * mdx + ws * msx,
            w0 * vy + wv * mvy + wd * mdy + ws * msy
          )
        end
        -- Update boid fields from new values.
        boid.x, boid.y = self:wrap(
          x + speed * vx * dt,
          y + speed * vy * dt
        )
        boid.vx, boid.vy = vx, vy
      end
    end
  end
end

---@param x number
---@param y number
---@return number, number
function Game:wrap(x, y)
  return math.fmod(x + self.sizeX, self.sizeX),
      math.fmod(y + self.sizeY, self.sizeY)
end
