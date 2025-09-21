UDim2 = {}
UDim2.__index = UDim2

local function isUDim2(v)
    return getmetatable(v) == UDim2
end

---Creates a new UDim2.
---@param xScale number The X dimension scale.
---@param xOffset number The X dimension offset.
---@param yScale number The Y dimension scale.
---@param yOffset number The Y dimension offset.
---@return UDim2
function UDim2.new(xScale, xOffset, yScale, yOffset)
    if type(xScale) ~= "number" or type(xOffset) ~= "number" or type(yScale) ~= "number" or type(yOffset) ~= "number" then
        error("UDim2.new: xScale, xOffset, yScale, yOffset must be numbers")
    end
    local self = setmetatable({}, UDim2)
    self.X = { Scale = xScale, Offset = xOffset }
    self.Y = { Scale = yScale, Offset = yOffset }
    return self
end

---Adds two UDim2 values.
---@param a UDim2
---@param b UDim2
---@return UDim2|nil
function UDim2.__add(a, b)
    if not isUDim2(a) or not isUDim2(b) then
        error("UDim2 subtraction: both operands must be UDim2")
    end
    return UDim2.new(
        a.X.Scale + b.X.Scale, a.X.Offset + b.X.Offset,
        a.Y.Scale + b.Y.Scale, a.Y.Offset + b.Y.Offset
    )
end

---Subtracts two UDim2 values.
---@param a UDim2
---@param b UDim2
---@return UDim2|nil
function UDim2.__sub(a, b)
    if not isUDim2(a) or not isUDim2(b) then
        error("UDim2 subtraction: both operands must be UDim2")
    end
    return UDim2.new(
        a.X.Scale - b.X.Scale, a.X.Offset - b.X.Offset,
        a.Y.Scale - b.Y.Scale, a.Y.Offset - b.Y.Offset
    )
end

---Checks equality of two UDim2 values.
---@param a UDim2
---@param b UDim2
---@return boolean
function UDim2.__eq(a, b)
    return a.X.Scale == b.X.Scale and a.X.Offset == b.X.Offset
       and a.Y.Scale == b.Y.Scale and a.Y.Offset == b.Y.Offset
end

---Returns a string representation.
---@param self UDim2
---@return string
function UDim2:__tostring()
    return string.format("UDim2(X: {Scale=%f, Offset=%f}, Y: {Scale=%f, Offset=%f})",
        self.X.Scale, self.X.Offset, self.Y.Scale, self.Y.Offset)
end

---Linearly interpolates between two UDim2 values.
---@param self UDim2
---@param other UDim2
---@param alpha number 0..1
---@return UDim2
function UDim2:Lerp(other, alpha)
    if not isUDim2(other) then
        error("UDim2:Lerp - other must be UDim2")
    end
    if type(alpha) ~= "number" then
        error("UDim2:Lerp - alpha must be number")
    end
    alpha = math.max(0, math.min(1, alpha))
    local function lerp(a, b, t)
        return a + (b - a) * t
    end
    return UDim2.new(
        lerp(self.X.Scale, other.X.Scale, alpha),
        lerp(self.X.Offset, other.X.Offset, alpha),
        lerp(self.Y.Scale, other.Y.Scale, alpha),
        lerp(self.Y.Offset, other.Y.Offset, alpha)
    )
end


return UDim2