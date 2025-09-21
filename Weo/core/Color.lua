function hex(d)
    if type(d) ~= "string" then
        return d
    end
    if d:find("#") == 1 then
        d = d:sub(2)
    end
    local h = "0x"..d
    if #d == 6 then
        return tonumber(h)
    else
        return 0x000000
    end
end

function hexA(d)
    if type(d) ~= "string" then
        return d
    end
     if d:find("#") == 1 then
        d = d:sub(2)
    end
    local h = "0x"..d
    if #d == 6 then
        h = h .. "FF"
        return tonumber(h)
    end
    if #d == 8 then
        return tonumber(h)
    else
        return 0x000000FF
    end
end

---Get a color.
---@class Color
Color = {}

local function randomHEXAColor()
    local r,g,b = math.random(0,255),math.random(0,255),math.random(0,255)
    return (r << 24) | (g << 16) | (b << 8) | 255
end

---Color from RGBA.
---@param R number
---@param G number
---@param B number
---@param A number
---@return number
function Color.fromRGBA(R,G,B,A)
    if type(R) ~= "number" or type(G) ~= "number" or type(B) ~= "number" or type(A) ~= "number" then
        return randomHEXAColor()
    end
    return (R << 24) | (G << 16) | (B << 8) | math.floor(A)
end

---Color from HEX.
---@param hex string
---@return number
function Color.fromHEX(hex)
    if type(hex) ~= "string" then
        return hexA(randomHEXAColor())
    end
    return hexA(hex)
end

---Color to LuaRT understand.
---@param hex_OR_rgba any
---@return number?
function Color.toLuaRTUnderstand(hex_OR_rgba)
    if type(hex_OR_rgba) ~= "string" then
        return hex_OR_rgba
    end
    if hex_OR_rgba:find("#") == 1 then
        hex_OR_rgba = hex_OR_rgba:sub(2)
    end
    local h = "0x"..hex_OR_rgba
    return tonumber(h)
end


function getAbsolutePositionAndSize(element)
    local parent = element.parent
    local parentPos, parentSize

    if parent then
        if parent.WeoController and parent.WeoController.Type == "Frame" then
            parentPos, parentSize = getAbsolutePositionAndSize(parent)
        elseif parent.IsRenderSurface then
            parentPos = Vector2.new(0, 0)
            parentSize = Vector2.new(parent.width, parent.height)
        else
            parentPos = Vector2.new(0, 0)
            parentSize = Vector2.new(0, 0)
        end
    else
        parentPos = Vector2.new(0, 0)
        parentSize = Vector2.new(0, 0)
    end

    local posX = parentPos.x + element.position.X.Scale * parentSize.x + element.position.X.Offset
    local posY = parentPos.y + element.position.Y.Scale * parentSize.y + element.position.Y.Offset
    local width = element.size.X.Scale * parentSize.x + element.size.X.Offset
    local height = element.size.Y.Scale * parentSize.y + element.size.Y.Offset

    return Vector2.new(posX, posY), Vector2.new(width, height)
end

function getParentUntilRenderSurface(Element)
    local parent = Element.parent
    while parent and not parent.IsRenderSurface do
        parent = parent.parent
    end
    return parent
end

---Create a linear gradient.
---@param Element any
---@param Colors table Color values from `0` to `1`. e.g. `{[0] = Color.fromHEX("#FF0000FF"),[0.1] = Color.fromHEX("#00FF00FF"),[0.2] = Color.fromHEX("#0000FFFF")...}`
---@param StartPoint Vector2
---@param EndPoint Vector2
---@return LinearGradient
function Color.LinearGradient(Element, Colors, StartPoint, EndPoint, Opacity)
    local Canvas = getParentUntilRenderSurface(Element)
    local pos, size = getAbsolutePositionAndSize(Element)
    local Gradient = Canvas:LinearGradient(Colors)
    Gradient.start = { pos.x + StartPoint.x * size.x, pos.y + StartPoint.y * size.y }
    Gradient.stop  = { pos.x + EndPoint.x * size.x, pos.y + EndPoint.y * size.y }
    Gradient._normalizedStart = StartPoint
    Gradient._normalizedStop = EndPoint
    Gradient.opacity = Opacity or 1
    return Gradient
end


---Create a radial gradient.
---@param Element any
---@param Colors table Color values from `0` to `1`. e.g. `{[0] = Color.fromHEX("#FF0000FF"),[0.1] = Color.fromHEX("#00FF00FF"),[0.2] = Color.fromHEX("#0000FFFF")...}`
---@param Center Vector2
---@param Radius Vector2
---@return RadialGradient
function Color.RadialGradient(Element, Colors, Center, Radius, Opacity)
    local Canvas = getParentUntilRenderSurface(Element)
    local pos, size = getAbsolutePositionAndSize(Element)
    local Gradient = Canvas:RadialGradient(Colors)
    Gradient.center = { pos.x + Center.x * size.x, pos.y + Center.y * size.y }
    Gradient.radius = { Radius.x * size.x, Radius.y * size.y }
    Gradient._normalizedCenter = Center
    Gradient._normalizedRadius = Radius
    Gradient.opacity = Opacity or 1
    return Gradient
end
