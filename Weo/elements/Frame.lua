Frame = {}
Frame.__index = Frame
local Signal = require("Weo.class.Signal")

local function drawRectangle(canvas, x, y, width, height, radiusx, radiusy, brush)
    canvas:fillroundrect(x, y, x + width, y + height, radiusx, radiusy, brush)
end



---Creates a new Frame,on a RenderSurface.
---@param RenderSurface RenderSurface This is not PARENT property,parent setting is in FrameProperties.
---@param FrameProperties {opacity : number|nil,class : table<string>|nil,padding : {left : number,top : number,right : number,bottom : number},cursor : Enum.CursorStyle,borderColor : number|LinearGradient|RadialGradient,borderThickness : number,parent: any,position : UDim2, size : UDim2,bgcolor : number|LinearGradient|RadialGradient, visible : boolean,borderRadius : number,zIndex : number} The Frame's properties.
---@return Frame
function Frame.new(RenderSurface, FrameProperties)
    assert(RenderSurface, "A RenderSurface is required to create a Frame.")
    assert(FrameProperties, "A FrameProperties table is required to create a Frame.")

    local WEO_FRAME_CONTROLLER = {
        parent = FrameProperties.parent or RenderSurface,
        position = FrameProperties.position or UDim2.new(0, 0, 0, 0),
        absolute = {
            position = Vector2.new(0, 0),
            size = Vector2.new(0, 0),
        },
        size = FrameProperties.size or UDim2.new(1, 0, 1, 0),
        bgcolor = FrameProperties.bgcolor or Color.fromHEX("#FFFFFFFF"),
        visible = FrameProperties.visible == nil and true or FrameProperties.visible == true and true or false,
        borderRadius = FrameProperties.borderRadius or 0,
        zIndex = FrameProperties.zIndex or 0,
        RenderSurface = RenderSurface or error("A RenderSurface is required to create a Frame."),
        borderColor = FrameProperties.borderColor or 0xFFFFFFFF,
        borderThickness = FrameProperties.borderThickness or 0,
        cursor = FrameProperties.cursor or Enum.CursorStyle.Arrow,
        padding = FrameProperties.padding or { left = 0, top = 0, right = 0, bottom = 0 },
        class = FrameProperties.class or {},
        opacity = FrameProperties.opacity or false,
        _wasVisible = nil,
        WeoController = {
            MouseHovering = false,
            Childs = {},
            Type = "Frame",
            WCSS_Theme = nil,
        }
    }


-- Frame.lua'da getAbsolutePositionAndSize fonksiyonunu şu şekilde güncelleyin:

local function getAbsolutePositionAndSize(element, visited)
    visited = visited or {}
    if visited[element] then
        return Vector2.new(0, 0), Vector2.new(0, 0)
    end
    visited[element] = true

    local parent = element.parent
    local parentPos, parentSize = Vector2.new(0, 0), Vector2.new(0, 0)

    if type(parent) == "table" then
        if parent.WeoController and parent.WeoController.Type == "Frame" then
            parentPos, parentSize = getAbsolutePositionAndSize(parent, visited)
            -- Padding'i pozisyona ekle, boyuttan çıkar
            parentPos = parentPos + Vector2.new(parent.padding.left, parent.padding.top)
            parentSize = parentSize - Vector2.new(
                parent.padding.left + parent.padding.right, 
                parent.padding.top + parent.padding.bottom
            )
        elseif parent.IsRenderSurface then
            parentPos = Vector2.new(parent.x or 0, parent.y or 0)
            parentSize = Vector2.new(parent.width or 0, parent.height or 0)
        end
    else
        -- Parent yoksa veya RenderSurface ise
        if element.RenderSurface then
            parentSize = Vector2.new(element.RenderSurface.width or 0, element.RenderSurface.height or 0)
        end
    end

    -- Scale ve Offset hesaplaması
    local posX = parentPos.x + (element.position.X.Scale or 0) * parentSize.x + (element.position.X.Offset or 0)
    local posY = parentPos.y + (element.position.Y.Scale or 0) * parentSize.y + (element.position.Y.Offset or 0)

    local width = (element.size.X.Scale or 0) * parentSize.x + (element.size.X.Offset or 0)
    local height = (element.size.Y.Scale or 0) * parentSize.y + (element.size.Y.Offset or 0)

    return Vector2.new(posX, posY), Vector2.new(width, height)
end



    function WEO_FRAME_CONTROLLER:draw(f)
        if f then
            f(self)
        end

        if self.visible then
            if not self._wasVisible then
                self.Shown:Fire()
            end
        else
            if self._wasVisible then
                self.Hidden:Fire()
            end
        end
        self._wasVisible = self.visible

        if not self.visible then return end

        local Apos, Asize = getAbsolutePositionAndSize(self)
        self.absolute.position = Apos
        self.absolute.size = Asize

        for k,v in pairs(WEO_FRAME_CONTROLLER.class) do
            local StyleName = v
            local CurrentElementType = self.WeoController.Type
            --print(StyleName)

            local S = Styles[CurrentElementType][StyleName]

            for a,b in pairs(S) do
                WEO_FRAME_CONTROLLER[a] = b    
            end

        end


        if type(self.bgcolor) == "LinearGradient" then
            local Gradient             = self.bgcolor
            local pos, size            = getAbsolutePositionAndSize(self)
            local StartPoint, EndPoint = self.bgcolor._normalizedStart, self.bgcolor._normalizedStop
            Gradient.start             = { pos.x + StartPoint.x * size.x, pos.y + StartPoint.y * size.y }
            Gradient.stop              = { pos.x + EndPoint.x * size.x, pos.y + EndPoint.y * size.y }
        elseif type(self.bgcolor) == "RadialGradient" then
            local Gradient = self.bgcolor
            local pos, size = getAbsolutePositionAndSize(self)
            local Center, Radius = self.bgcolor._normalizedCenter, self.bgcolor._normalizedRadius
            Gradient.center = { pos.x + Center.x * size.x, pos.y + Center.y * size.y }
            Gradient.radius = { Radius.x * size.x, Radius.y * size.y }
        end

        local function applyOpacityToColor(color, opacity)
            if not opacity then return color end
            local r = (color >> 24) & 0xFF
            local g = (color >> 16) & 0xFF
            local b = (color >> 8) & 0xFF
            local a = color & 0xFF
            a = math.floor(a * opacity)
            return (r << 24) + (g << 16) + (b << 8) + a
        end


        local pos, size = getAbsolutePositionAndSize(self)
        drawRectangle(
            self.RenderSurface,
            pos.x,
            pos.y,
            size.x,
            size.y,
            self.borderRadius or 0,
            self.borderRadius or 0,
            applyOpacityToColor(self.bgcolor, self.opacity)
        )
    end

    WEO_FRAME_CONTROLLER.MouseButton1Click = Signal.new()
    WEO_FRAME_CONTROLLER.MouseButton2Click = Signal.new()
    WEO_FRAME_CONTROLLER.MouseHover = Signal.new()
    WEO_FRAME_CONTROLLER.MouseButtonDown = Signal.new()
    WEO_FRAME_CONTROLLER.MouseButtonUp = Signal.new()
    WEO_FRAME_CONTROLLER.MouseWheel = Signal.new()
    WEO_FRAME_CONTROLLER.MouseLeave = Signal.new()
    WEO_FRAME_CONTROLLER.Shown = Signal.new()
    WEO_FRAME_CONTROLLER.Hidden = Signal.new()
    WEO_FRAME_CONTROLLER.Destroyed = Signal.new()

    function WEO_FRAME_CONTROLLER:hide()
        self.visible = false
    end

    function WEO_FRAME_CONTROLLER:show()
        self.visible = true
    end

    table.find = function(table, value)
        for i, v in pairs(table) do
            if v == value then
                return i
            end
        end
    end

    function WEO_FRAME_CONTROLLER:Destroy()
        if self._destroyed then return end
        WEO_FRAME_CONTROLLER._destroyed = true
        self.Destroyed:Fire()
        if self.WeoController and self.WeoController.Childs then
            for i = #self.WeoController.Childs, 1, -1 do
                local child = self.WeoController.Childs[i]
                if child.Destroy then
                    child:Destroy()
                end
            end
            self.WeoController.Childs = {}
        end


        local idx = table.find(RenderSurface.RenderElements, self)
        if idx then
            table.remove(RenderSurface.RenderElements, idx)
        end


        local parent = self.parent
        while parent and not parent.IsRenderSurface do
            if parent.WeoController and parent.WeoController.Childs then
                local idx2 = table.find(parent.WeoController.Childs, self)
                if idx2 then
                    table.remove(parent.WeoController.Childs, idx2)
                end
            end
            parent = parent.parent
        end

    end

    if WEO_FRAME_CONTROLLER.cursor then
        WEO_FRAME_CONTROLLER.MouseHover:Connect(function(Vector, b)
            RenderSurface.cursor = WEO_FRAME_CONTROLLER.cursor
        end)
        WEO_FRAME_CONTROLLER.MouseLeave:Connect(function(Vector, b)
            RenderSurface.cursor = Enum.CursorStyle.Arrow
        end)
    end


    table.insert(RenderSurface.RenderElements, WEO_FRAME_CONTROLLER)

    if WEO_FRAME_CONTROLLER.parent and WEO_FRAME_CONTROLLER.parent.WeoController then
        table.insert(WEO_FRAME_CONTROLLER.parent.WeoController.Childs, WEO_FRAME_CONTROLLER)
    end


    return WEO_FRAME_CONTROLLER
end
