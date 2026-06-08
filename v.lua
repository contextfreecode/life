local mod = {}

---@alias v.Vec2 [number, number]

---@param a v.Vec2
---@param b v.Vec2
---@param target? v.Vec2
---@return v.Vec2
function mod.add(a, b, target)
  local result = target or {0.0, 0.0}
  result[1] = a[1] + b[1]
  result[2] = a[2] + b[2]
  return result
end

---@param vec v.Vec2
---@param scalar number
---@return v.Vec2
function mod.addScalar(vec, scalar)
  return { vec[1] + scalar, vec[2] + scalar }
end

---@param a v.Vec2
---@param b v.Vec2
---@param target? v.Vec2
---@return v.Vec2
function mod.fmod(a, b, target)
  local result = target or {0.0, 0.0}
  result[1] = math.fmod(a[1], b[1])
  result[2] = math.fmod(a[2], b[2])
  return result
end

---@param a v.Vec2
---@param b v.Vec2
---@return v.Vec2
function mod.mul(a, b)
  return { a[1] * b[1], a[2] * b[2] }
end

---@param vec v.Vec2
---@param scalar number
---@param target? v.Vec2
---@return v.Vec2
function mod.mulScalar(vec, scalar, target)
  local result = target or {0.0, 0.0}
  result[1] = vec[1] * scalar
  result[2] = vec[2] * scalar
  return result
end

---@param vec v.Vec2
---@return number
function mod.normOf(vec)
  return math.sqrt(vec[1] * vec[1] + vec[2] * vec[2])
end

---@param vec v.Vec2
---@param target? v.Vec2
---@return v.Vec2
function mod.normalize(vec, target)
  return mod.mulScalar(vec, 1.0 / mod.normOf(vec), target)
end

---@param target? v.Vec2
---@return v.Vec2
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
