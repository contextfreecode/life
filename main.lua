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
---@return number, number
local function normalize(x, y)
  local norm = math.sqrt(x * x + y * y)
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
  local speed = 30
  for binX, column in ipairs(self.boids) do
    for binY, cell in ipairs(column) do
      for _, boid in ipairs(cell) do
        -- Adjust boid values.
        local x, y = boid.x, boid.y
        local vx, vy = boid.vx, boid.vy
        for otherBinDx = -1, 1 do
          local otherBinX = (binX + otherBinDx - 1) % #self.boids + 1
          local otherColumn = self.boids[otherBinX]
          for otherBinDy = -1, 1 do
            local otherBinY = (binY + otherBinDy - 1) % #otherColumn + 1
            local otherCell = otherColumn[otherBinY]
            for _, otherBoid in ipairs(otherCell)do
              -- TODO Adjust velocity for avoidance
              -- TODO Adjust velocity for alignment
              -- TODO Adjust velocity for centering
            end
          end
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
  return math.fmod(x, self.sizeX), math.fmod(y, self.sizeY)
end
