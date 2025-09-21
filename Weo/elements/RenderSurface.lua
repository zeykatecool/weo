local Signal = require("Weo.class.Signal")
local UI = require("ui")
local Vector2 = require("Weo.class.Vector2")
require "canvas"

local function mousePosition(window)
    local x, y = UI.mousepos()
    if not window then return { x = x, y = y } end
    if window.style == Enum.WindowStyle.Raw then
        return { x = x - window.x, y = y - window.y }
    end
    local TITLEBAR_HEIGHT = 32
    return { x = x - window.x, y = y - window.y - TITLEBAR_HEIGHT }
end

local function getAbsolutePositionAndSize(element)
    -- Eğer element bir RenderSurface ise
    if element.IsRenderSurface then
        return Vector2.new(element.x or 0, element.y or 0), Vector2.new(element.width or 0, element.height or 0)
    end

    local parent = element.parent
    local parentPos, parentSize = Vector2.new(0, 0), Vector2.new(0, 0)

    if parent then
        if parent.IsRenderSurface then
            -- Parent bir RenderSurface ise
            parentPos = Vector2.new(parent.x or 0, parent.y or 0)
            parentSize = Vector2.new(parent.width or 0, parent.height or 0)
        else
            -- Parent normal bir element ise
            parentPos, parentSize = getAbsolutePositionAndSize(parent)
            if parent.padding then
                parentPos.x = parentPos.x + (parent.padding.left or 0)
                parentPos.y = parentPos.y + (parent.padding.top or 0)
                parentSize.x = parentSize.x - ((parent.padding.left or 0) + (parent.padding.right or 0))
                parentSize.y = parentSize.y - ((parent.padding.top or 0) + (parent.padding.bottom or 0))
            end
        end
    end

    local pxScale = (element.position and element.position.X and element.position.X.Scale) or 0
    local pxOffset = (element.position and element.position.X and element.position.X.Offset) or 0
    local pyScale = (element.position and element.position.Y and element.position.Y.Scale) or 0
    local pyOffset = (element.position and element.position.Y and element.position.Y.Offset) or 0
    local sxScale = (element.size and element.size.X and element.size.X.Scale) or 0
    local sxOffset = (element.size and element.size.X and element.size.X.Offset) or 0
    local syScale = (element.size and element.size.Y and element.size.Y.Scale) or 0
    local syOffset = (element.size and element.size.Y and element.size.Y.Offset) or 0

    local posX = parentPos.x + pxScale * parentSize.x + pxOffset
    local posY = parentPos.y + pyScale * parentSize.y + pyOffset
    local width = sxScale * parentSize.x + sxOffset
    local height = syScale * parentSize.y + syOffset

    return Vector2.new(posX, posY), Vector2.new(width, height)
end



local function isMouseOnElementHitbox(Element, renderSurface, localMouseX, localMouseY)
    if not localMouseX or not localMouseY then
        local M = mousePosition(renderSurface.window)
        localMouseX, localMouseY = M.x, M.y
        -- RenderSurface pozisyonunu doğru al
        localMouseX = localMouseX - (renderSurface.x or 0)
        localMouseY = localMouseY - (renderSurface.y or 0)
    end

    local pos, size = getAbsolutePositionAndSize(Element)
    local x, y, w, h = pos.x, pos.y, size.x, size.y
    local radius = Element.borderRadius or 0

    if radius > 0 then
        local function cornerCheck(cx, cy)
            local dx, dy = localMouseX - cx, localMouseY - cy
            return dx * dx + dy * dy <= radius * radius
        end

        if localMouseX < (x + radius) and localMouseY < (y + radius) then return cornerCheck(x + radius, y + radius) end
        if localMouseX > (x + w - radius) and localMouseY < (y + radius) then return cornerCheck(x + w - radius, y +
            radius) end
        if localMouseX < (x + radius) and localMouseY > (y + h - radius) then return cornerCheck(x + radius, y + h -
            radius) end
        if localMouseX > (x + w - radius) and localMouseY > (y + h - radius) then return cornerCheck(x + w - radius,
                y + h - radius) end
    end

    return localMouseX >= x and localMouseX <= (x + w) and localMouseY >= y and localMouseY <= (y + h)
end

local function getTopElementUnderMouse(renderSurface, localMouseX, localMouseY)
    if not localMouseX or not localMouseY then
        local M = mousePosition(renderSurface.window)
        localMouseX, localMouseY = M.x, M.y
        -- RenderSurface pozisyonunu doğru al
        localMouseX = localMouseX - (renderSurface.x or 0)
        localMouseY = localMouseY - (renderSurface.y or 0)
    end

    local function find(elements)
        local top, topZ = nil, -math.huge
        for _, el in ipairs(elements) do
            if el.visible and isMouseOnElementHitbox(el, renderSurface, localMouseX, localMouseY) then
                local candidate = el
                if el.RenderElements and #el.RenderElements > 0 then
                    local childTop = find(el.RenderElements)
                    if childTop then candidate = childTop end
                end
                if (candidate.zIndex or 0) >= topZ then
                    top = candidate
                    topZ = candidate.zIndex or 0
                end
            end
        end
        return top
    end

    return find(renderSurface.RenderElements)
end

RenderSurface = {}
RenderSurface.__index = RenderSurface

function RenderSurface.new(Window, RenderSurfaceProperties)
    assert(Window, "A Window is required.")
    assert(RenderSurfaceProperties, "A RenderSurfaceProperties table is required.")
    assert(RenderSurfaceProperties.bgcolor, "A bgcolor is required.")
    local Canvas = UI.Canvas(Window)
    Canvas.align = "all"
    for k, v in pairs(RenderSurfaceProperties) do Canvas[k] = v end
    Canvas.parent = Window
    Canvas.IsRenderSurface = true
    Canvas.window = Window
    Window.bgcolor = Canvas.bgcolor or 0xFFFFFFFF
    Canvas.RenderElements = {}

    Canvas.Shown = Signal.new()
    Canvas.Hidden = Signal.new()
    Canvas.MouseButton1Click = Signal.new()
    Canvas.MouseButton2Click = Signal.new()
    Canvas.MouseHover = Signal.new()
    Canvas.Created = Signal.new()
    Canvas.MouseButtonDown = Signal.new()
    Canvas.MouseButtonUp = Signal.new()
    Canvas.MouseWheel = Signal.new()
    Canvas.MouseLeave = Signal.new()

    local __lastHover = nil
    function Canvas:onHover(x, y, b)
        local Vector = Vector2.new(x, y)
        self.MouseHover:Fire(Vector, b)
        local top = getTopElementUnderMouse(self, x, y)
        if top ~= __lastHover then
            if __lastHover and __lastHover.MouseLeave then
                __lastHover.MouseLeave:Fire(Vector, b)
                if __lastHover.WeoController then __lastHover.WeoController.MouseHovering = false end
            end
            if top and top.MouseHover then
                top.MouseHover:Fire(Vector, b)
                if top.WeoController then top.WeoController.MouseHovering = true end
            end
            __lastHover = top
        else
            if top and top.MouseHover then
                top.MouseHover:Fire(Vector, b)
            end
        end
    end

    function Canvas:onClick(x, y)
        local Vector = Vector2.new(x, y)
        local top = getTopElementUnderMouse(self, x, y)
        if top and top.MouseButton1Click then top.MouseButton1Click:Fire(Vector) end
        self.MouseButton1Click:Fire(Vector)
    end

    function Canvas:onMouseDown(x, y, b)
        local Vector = Vector2.new(x, y)
        local top = getTopElementUnderMouse(self, x, y)
        if top and top.MouseButtonDown then top.MouseButtonDown:Fire(Vector, b) end
        self.MouseButtonDown:Fire(Vector, b)
    end

    function Canvas:onMouseUp(x, y, b)
        local Vector = Vector2.new(x, y)
        local top = getTopElementUnderMouse(self, x, y)
        if top and top.MouseButtonUp then top.MouseButtonUp:Fire(Vector, b) end
        self.MouseButtonUp:Fire(Vector, b)
    end

    function Canvas:onContext(x, y)
        local Vector = Vector2.new(x, y)
        local top = getTopElementUnderMouse(self, x, y)
        if top and top.MouseButton2Click then top.MouseButton2Click:Fire(Vector) end
        self.MouseButton2Click:Fire(Vector)
    end

    function Canvas:onMouseWheel(delta, b)
        local M = mousePosition(self.window)
        local mx, my = M.x, M.y
        local rsPos = getAbsolutePositionAndSize(self)
        mx = mx - rsPos.x
        my = my - rsPos.y
        local top = getTopElementUnderMouse(self, mx, my)
        if top and top.MouseWheel then top.MouseWheel:Fire(delta, b) end
        self.MouseWheel:Fire(delta, b)
    end

    function Canvas:onLeave()
        self.MouseLeave:Fire()
        if __lastHover and __lastHover.MouseLeave then
            __lastHover.MouseLeave:Fire(Vector2.new(-1, -1), false)
            if __lastHover.WeoController then __lastHover.WeoController.MouseHovering = false end
            __lastHover = nil
        end
    end

    function Canvas:Refresh(force)
        if force then
            UpdateService.Heartbeat:Connect(function(DeltaTime) self:onPaint() end)
        else
            self:onPaint()
        end
    end

    function Canvas:onPaint()
        self:begin()
        self:clear()
        local elements = {}
        for _, el in pairs(self.RenderElements) do table.insert(elements, el) end
        table.sort(elements, function(a, b) return (a.zIndex or 0) < (b.zIndex or 0) end)
        for _, el in ipairs(elements) do if el.draw then el:draw() end end
        self:flip()
    end

    function Canvas:onShow() self.Shown:Fire() end

    function Canvas:onHide() self.Hidden:Fire() end

    function Canvas:onCreate() self.Created:Fire() end

    return Canvas
end
