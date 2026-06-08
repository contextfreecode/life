local mod = {}

---@alias v2.Vec2 [number, number]

---@param a v2.Vec2
---@param b v2.Vec2
---@param target? v2.Vec2
---@return v2.Vec2
function mod.add(a, b, target)
  local result = target or {0.0, 0.0}
  result[1] = a[1] + b[1]
  result[2] = a[2] + b[2]
  return result
end

---@param vec v2.Vec2
---@param num number
---@param target? v2.Vec2
---@return v2.Vec2
function mod.addNum(vec, num, target)
  local result = target or {0.0, 0.0}
  result[1] = vec[1] + num
  result[2] = vec[2] + num
  return result
end

---@param fun fun(): number
---@param target? v2.Vec2
---@return v2.Vec2
function mod.init(fun, target)
  if target then
    target[1] = fun()
    target[2] = fun()
  else
    target = {fun(), fun()}
  end
  return target
end

---@param a v2.Vec2
---@param b v2.Vec2
---@param target? v2.Vec2
---@return v2.Vec2
function mod.fmod(a, b, target)
  local result = target or {0.0, 0.0}
  result[1] = math.fmod(a[1], b[1])
  result[2] = math.fmod(a[2], b[2])
  return result
end

---@param a v2.Vec2
---@param b v2.Vec2
---@param target? v2.Vec2
---@return v2.Vec2
function mod.mul(a, b, target)
  local result = target or {0.0, 0.0}
  result[1] = a[1] * b[1]
  result[2] = a[2] * b[2]
  return result
end

---@param vec v2.Vec2
---@param num number
---@param target? v2.Vec2
---@return v2.Vec2
function mod.mulNum(vec, num, target)
  local result = target or {0.0, 0.0}
  result[1] = vec[1] * num
  result[2] = vec[2] * num
  return result
end

---@param vec v2.Vec2
---@return number
function mod.norm(vec)
  return math.sqrt(vec[1] * vec[1] + vec[2] * vec[2])
end

---@param vec v2.Vec2
---@param target? v2.Vec2
---@return v2.Vec2
function mod.normalize(vec, target)
  return mod.mulNum(vec, 1.0 / mod.norm(vec), target)
end

---@param target? v2.Vec2
---@return v2.Vec2
function mod.zero(target)
  if target then
    target[1] = 0.0
    target[2] = 0.0
  else
    target = {0.0, 0.0}
  end
  return target
end

return mod
