Vector2 = {}
Vector2.__index = Vector2


local function isVector2(obj)
    return type(obj) == "table" and type(obj.x) == "number" and type(obj.y) == "number"
end

---Creates a new Vector2.
---@param x number The X component.
---@param y number The Y component.
---@return Vector2
function Vector2.new(x, y)
    if type(x) ~= "number" or type(y) ~= "number" then
        error("Vector2.new: x and y must be numbers")
    end
    
    local self = setmetatable({}, Vector2)
    self.x = x
    self.y = y
    return self
end

---Adds two Vector2 values.
---@param a Vector2
---@param b Vector2
---@return Vector2
function Vector2.__add(a, b)
    if not isVector2(a) or not isVector2(b) then
        error("Vector2 addition: both operands must be Vector2")
    end
    return Vector2.new(a.x + b.x, a.y + b.y)
end

---Subtracts two Vector2 values.
---@param a Vector2
---@param b Vector2
---@return Vector2
function Vector2.__sub(a, b)
    if not isVector2(a) or not isVector2(b) then
        error("Vector2 subtraction: both operands must be Vector2")
    end
    return Vector2.new(a.x - b.x, a.y - b.y)
end

---Multiplies Vector2 by a number or number by Vector2.
---@param a Vector2|number
---@param b Vector2|number
---@return Vector2
function Vector2.__mul(a, b)
    if type(a) == "number" and isVector2(b) then
        return Vector2.new(a * b.x, a * b.y)
    elseif isVector2(a) and type(b) == "number" then
        return Vector2.new(a.x * b, a.y * b)
    else
        error("Vector2 multiplication: supports only Vector2 * number or number * Vector2")
    end
end

---Divides Vector2 by a number.
---@param v Vector2
---@param n number
---@return Vector2
function Vector2.__div(v, n)
    if not isVector2(v) then
        error("Vector2 division: left operand must be Vector2")
    end
    if type(n) ~= "number" then
        error("Vector2 division: right operand must be number")
    end
    if n == 0 then
        error("Vector2 division: cannot divide by zero")
    end
    return Vector2.new(v.x / n, v.y / n)
end

---Checks equality of two Vector2 values.
---@param a Vector2
---@param b Vector2
---@return boolean
function Vector2.__eq(a, b)
    if not isVector2(a) or not isVector2(b) then
        return false
    end
    return a.x == b.x and a.y == b.y
end

---Returns a string representation.
---@param self Vector2
---@return string
function Vector2:__tostring()
    return string.format("Vector2(%.3f, %.3f)", self.x, self.y)
end

---Linearly interpolates between two Vector2 values.
---@param other Vector2
---@param alpha number
---@return Vector2
function Vector2:Lerp(other, alpha)
    if not isVector2(other) then
        error("Vector2:Lerp - other must be Vector2")
    end
    if type(alpha) ~= "number" then
        error("Vector2:Lerp - alpha must be number")
    end
    

    alpha = math.max(0, math.min(1, alpha))
    
    local function lerp(a, b, t)
        return a + (b - a) * t
    end
    return Vector2.new(
        lerp(self.x, other.x, alpha),
        lerp(self.y, other.y, alpha)
    )
end


---Returns the magnitude (length) of the vector.
---@return number
function Vector2:Magnitude()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

---Returns the squared magnitude.
---@return number
function Vector2:MagnitudeSquared()
    return self.x * self.x + self.y * self.y
end

---Returns the normalized vector.
---@return Vector2
function Vector2:Normalize()
    local magSquared = self:MagnitudeSquared()
    if magSquared == 0 then 
        return Vector2.new(0, 0) 
    end
    
    local mag = math.sqrt(magSquared)
    return Vector2.new(self.x / mag, self.y / mag)
end

---Returns the dot product of two vectors.
---@param other Vector2
---@return number
function Vector2:Dot(other)
    if not isVector2(other) then
        error("Vector2:Dot - other must be Vector2")
    end
    return self.x * other.x + self.y * other.y
end

---Returns the distance between two vectors.
---@param other Vector2
---@return number
function Vector2:Distance(other)
    if not isVector2(other) then
        error("Vector2:Distance - other must be Vector2")
    end
    return (self - other):Magnitude()
end

---Returns the squared distance between two vectors.
---@param other Vector2
---@return number
function Vector2:DistanceSquared(other)
    if not isVector2(other) then
        error("Vector2:DistanceSquared - other must be Vector2")
    end
    return (self - other):MagnitudeSquared()
end

return Vector2