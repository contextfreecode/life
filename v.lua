local mod = {}

---@alias v.Vec2 [number, number]

---@param a v.Vec2
---@param b v.Vec2
---@return v.Vec2
function mod.add(a, b)
  return { a[1] + b[1], a[2] + b[2] }
end

---@param result v.Vec2
---@param a v.Vec2
---@param b v.Vec2
---@return v.Vec2
function mod.addInto(result, a, b)
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
---@return v.Vec2
function mod.mul(a, b)
  return { a[1] * b[1], a[2] * b[2] }
end

---@param vec v.Vec2
---@param scalar number
---@return v.Vec2
function mod.mulScalar(vec, scalar)
  return { vec[1] * scalar, vec[2] * scalar }
end

---@param result v.Vec2
---@param vec v.Vec2
---@param scalar number
---@return v.Vec2
function mod.mulScalarInto(result, vec, scalar)
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
---@return v.Vec2
function mod.normalize(vec)
  return mod.mulScalar(vec, 1.0 / mod.normOf(vec))
end

return mod
