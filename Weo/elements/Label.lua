Label = {}
Label.__index = Label
local Signal = require("Weo.class.Signal")

---Creates a new Label on a RenderSurface.
---@param RenderSurface RenderSurface This is not PARENT property,parent setting is in LabelProperties.
---@param LabelProperties {opacity : number|nil,class : table<string|nil>|nil,padding: {left : number,top : number,right : number,bottom : number},cursor : Enum.CursorStyle,font: string,text : string,fontsize : number,fontstyle : Enum.FontStyle,fontweight : number,textcolor : number|LinearGradient|RadialGradient,parent: any,position : UDim2, bgcolor : number|LinearGradient|RadialGradient, visible : boolean,borderRadius : number,zIndex : number}
---@return Label
function Label.new(RenderSurface, LabelProperties)
    assert(RenderSurface, "A RenderSurface is required to create a Label.")
    assert(LabelProperties, "LabelProperties table is required to create a Label.")

    local WEO_LABEL_CONTROLLER = {
        parent = LabelProperties.parent or RenderSurface,
        position = LabelProperties.position or UDim2.new(0, 0, 0, 0),
        size = UDim2.new(0, 0, 0, 0), --readonly since text is measured on drawing and can't be changed
        absolute = { position = Vector2.new(0, 0), size = Vector2.new(0, 0) },
        visible = LabelProperties.visible ~= false,
        zIndex = LabelProperties.zIndex or 0,
        RenderSurface = RenderSurface or error("A RenderSurface is required to create a Label."),
        font = LabelProperties.font or "Arial",
        fontsize = LabelProperties.fontsize or 12,
        fontstyle = LabelProperties.fontstyle or "normal",
        fontweight = LabelProperties.fontweight or 200,
        textcolor = LabelProperties.textcolor or 0xFFFFFFFF,
        text = LabelProperties.text or "Lorem Ipsum",
        cursor = LabelProperties.cursor or Enum.CursorStyle.Arrow,
        padding = LabelProperties.padding or { left = 0, top = 0, right = 0, bottom = 0 },
        class = LabelProperties.class or {},
        opacity = LabelProperties.opacity or false,
        _wasVisible = nil,
        WeoController = { MouseHovering = false, Childs = {}, Type = "Label", WCSS_Theme = nil },
    }

    WEO_LABEL_CONTROLLER.MouseButton1Click = Signal.new()
    WEO_LABEL_CONTROLLER.MouseButton2Click = Signal.new()
    WEO_LABEL_CONTROLLER.MouseHover = Signal.new()
    WEO_LABEL_CONTROLLER.MouseButtonDown = Signal.new()
    WEO_LABEL_CONTROLLER.MouseButtonUp = Signal.new()
    WEO_LABEL_CONTROLLER.MouseWheel = Signal.new()
    WEO_LABEL_CONTROLLER.MouseLeave = Signal.new()
    WEO_LABEL_CONTROLLER.Shown = Signal.new()
    WEO_LABEL_CONTROLLER.Hidden = Signal.new()
    WEO_LABEL_CONTROLLER.Destroyed = Signal.new()

    local R = WEO_LABEL_CONTROLLER.RenderSurface
    local WHT = R:measure(WEO_LABEL_CONTROLLER.text)
    WEO_LABEL_CONTROLLER.size = UDim2.new(0, WHT.width, 0, WHT.height)
    WEO_LABEL_CONTROLLER.absolute.size = Vector2.new(WHT.width, WHT.height)

    local function getAbsolutePositionAndSize(element, visited)
        visited = visited or {}
        if visited[element] then
            return Vector2.new(0, 0), Vector2.new(0, 0)
        end
        visited[element] = true

        local parent = element.parent
        local parentPos, parentSize = Vector2.new(0, 0), Vector2.new(0, 0)

        if element.WeoController and element.WeoController.Type == "Label" then
            if type(parent) == "table" then
                if parent.WeoController and parent.WeoController.Type == "Frame" then
                    -- Parent Frame'in pozisyon ve boyutunu al
                    parentPos, parentSize = getAbsolutePositionAndSize(parent, visited)
                    -- Parent Frame'in padding'ini uygula
                    parentPos = parentPos + Vector2.new(parent.padding.left or 0, parent.padding.top or 0)
                    parentSize = parentSize - Vector2.new(
                        (parent.padding.left or 0) + (parent.padding.right or 0),
                        (parent.padding.top or 0) + (parent.padding.bottom or 0)
                    )
                elseif parent.IsRenderSurface then
                    parentPos = Vector2.new(parent.x or 0, parent.y or 0)
                    parentSize = Vector2.new(parent.width or 0, parent.height or 0)
                else
                    parentPos, parentSize = getAbsolutePositionAndSize(parent, visited)
                end
            else
                -- Parent yoksa RenderSurface boyutunu kullan
                parentSize = Vector2.new(element.RenderSurface.width or 0, element.RenderSurface.height or 0)
            end

            -- Label için pozisyon hesaplama
            local posX = parentPos.x + (element.position.X.Scale or 0) * parentSize.x + (element.position.X.Offset or 0)
            local posY = parentPos.y + (element.position.Y.Scale or 0) * parentSize.y + (element.position.Y.Offset or 0)

            local measured = element.RenderSurface:measure(element.text)
            return Vector2.new(posX, posY), Vector2.new(measured.width, measured.height)
        end

        -- Frame elementi için (önceki kod)
        if type(parent) == "table" then
            if parent.WeoController and parent.WeoController.Type == "Frame" then
                parentPos, parentSize = getAbsolutePositionAndSize(parent, visited)
                parentPos = parentPos + Vector2.new(parent.padding.left or 0, parent.padding.top or 0)
                parentSize = parentSize - Vector2.new(
                    (parent.padding.left or 0) + (parent.padding.right or 0),
                    (parent.padding.top or 0) + (parent.padding.bottom or 0)
                )
            elseif parent.IsRenderSurface then
                parentPos = Vector2.new(parent.x or 0, parent.y or 0)
                parentSize = Vector2.new(parent.width or 0, parent.height or 0)
            end
        end

        local posX = parentPos.x + (element.position.X.Scale or 0) * parentSize.x + (element.position.X.Offset or 0)
        local posY = parentPos.y + (element.position.Y.Scale or 0) * parentSize.y + (element.position.Y.Offset or 0)

        local width = (element.size.X.Scale or 0) * parentSize.x + (element.size.X.Offset or 0)
        local height = (element.size.Y.Scale or 0) * parentSize.y + (element.size.Y.Offset or 0)

        return Vector2.new(posX, posY), Vector2.new(width, height)
    end

    function WEO_LABEL_CONTROLLER:hide()
        self.visible = false
    end

    function WEO_LABEL_CONTROLLER:show()
        self.visible = true
    end

    table.find = function(table, value)
        for i, v in pairs(table) do
            if v == value then
                return i
            end
        end
    end

    function WEO_LABEL_CONTROLLER:Destroy()
        if self._destroyed then return end
        WEO_LABEL_CONTROLLER._destroyed = true
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

    if WEO_LABEL_CONTROLLER.cursor then
        WEO_LABEL_CONTROLLER.MouseHover:Connect(function(Vector, b)
            RenderSurface.cursor = WEO_LABEL_CONTROLLER.cursor
        end)
        WEO_LABEL_CONTROLLER.MouseLeave:Connect(function(Vector, b)
            RenderSurface.cursor = Enum.CursorStyle.Arrow
        end)
    end

    function WEO_LABEL_CONTROLLER:draw(f)
        if f then f(self) end

        if self.visible then
            if not self._wasVisible then self.Shown:Fire() end
        else
            if self._wasVisible then self.Hidden:Fire() end
        end
        self._wasVisible = self.visible
        if not self.visible then return end

        for k, v in pairs(WEO_LABEL_CONTROLLER.class) do
            local StyleName = v
            local CurrentElementType = self.WeoController.Type
            local S = Styles[CurrentElementType][StyleName]
            for a, b in pairs(S) do
                WEO_LABEL_CONTROLLER[a] = b
            end
        end

        -- RenderSurface'deki getAbsolutePositionAndSize ile aynı logic kullan
        local parentPos = Vector2.new(0, 0)
        local parentSize = Vector2.new(0, 0)

        if self.parent then
            if self.parent.IsRenderSurface then
                parentPos = Vector2.new(self.parent.x or 0, self.parent.y or 0)
                parentSize = Vector2.new(self.parent.width or 0, self.parent.height or 0)
            else
                -- Parent Frame için recursive hesaplama
                local function calculateParent(element)
                    local p = element.parent
                    local pPos, pSize = Vector2.new(0, 0), Vector2.new(0, 0)

                    if p then
                        if p.IsRenderSurface then
                            pPos = Vector2.new(p.x or 0, p.y or 0)
                            pSize = Vector2.new(p.width or 0, p.height or 0)
                        else
                            pPos, pSize = calculateParent(p)
                            if p.padding then
                                pPos.x = pPos.x + (p.padding.left or 0)
                                pPos.y = pPos.y + (p.padding.top or 0)
                                pSize.x = pSize.x - ((p.padding.left or 0) + (p.padding.right or 0))
                                pSize.y = pSize.y - ((p.padding.top or 0) + (p.padding.bottom or 0))
                            end
                        end
                    end

                    local posX = pPos.x +
                        ((element.position and element.position.X and element.position.X.Scale) or 0) * pSize.x +
                        ((element.position and element.position.X and element.position.X.Offset) or 0)
                    local posY = pPos.y +
                        ((element.position and element.position.Y and element.position.Y.Scale) or 0) * pSize.y +
                        ((element.position and element.position.Y and element.position.Y.Offset) or 0)
                    local width = ((element.size and element.size.X and element.size.X.Scale) or 0) * pSize.x +
                        ((element.size and element.size.X and element.size.X.Offset) or 0)
                    local height = ((element.size and element.size.Y and element.size.Y.Scale) or 0) * pSize.y +
                        ((element.size and element.size.Y and element.size.Y.Offset) or 0)

                    return Vector2.new(posX, posY), Vector2.new(width, height)
                end

                parentPos, parentSize = calculateParent(self.parent)
                if self.parent.padding then
                    parentPos.x = parentPos.x + (self.parent.padding.left or 0)
                    parentPos.y = parentPos.y + (self.parent.padding.top or 0)
                    parentSize.x = parentSize.x - ((self.parent.padding.left or 0) + (self.parent.padding.right or 0))
                    parentSize.y = parentSize.y - ((self.parent.padding.top or 0) + (self.parent.padding.bottom or 0))
                end
            end
        end

        local posX = parentPos.x + (self.position.X.Scale or 0) * parentSize.x + (self.position.X.Offset or 0)
        local posY = parentPos.y + (self.position.Y.Scale or 0) * parentSize.y + (self.position.Y.Offset or 0)

        local oldFonts = {
            font = RenderSurface.font,
            fontsize = RenderSurface.fontsize,
            fontstyle = RenderSurface.fontstyle,
            fontweight = RenderSurface.fontweight
        }

        RenderSurface.font = self.font
        RenderSurface.fontsize = self.fontsize
        RenderSurface.fontstyle = self.fontstyle
        RenderSurface.fontweight = self.fontweight

        local measured = RenderSurface:measure(self.text)

        self.absolute.position = Vector2.new(posX, posY)
        self.absolute.size = Vector2.new(measured.width, measured.height)

         R = WEO_LABEL_CONTROLLER.RenderSurface
         WHT = R:measure(WEO_LABEL_CONTROLLER.text)
        WEO_LABEL_CONTROLLER.size = UDim2.new(0, WHT.width, 0, WHT.height)
        WEO_LABEL_CONTROLLER.absolute.size = Vector2.new(WHT.width, WHT.height)

        if type(self.bgcolor) == "LinearGradient" then
            local Gradient = self.bgcolor
            local pos, size = Vector2.new(posX, posY), Vector2.new(measured.width, measured.height)
            local StartPoint, EndPoint = Gradient._normalizedStart, Gradient._normalizedStop
            Gradient.start = { pos.x + StartPoint.x * size.x, pos.y + StartPoint.y * size.y }
            Gradient.stop = { pos.x + EndPoint.x * size.x, pos.y + EndPoint.y * size.y }
        elseif type(self.bgcolor) == "RadialGradient" then
            local Gradient = self.bgcolor
            local pos, size = Vector2.new(posX, posY), Vector2.new(measured.width, measured.height)
            local Center, Radius = Gradient._normalizedCenter, Gradient._normalizedRadius
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

        RenderSurface:print(self.text, posX, posY, applyOpacityToColor(self.textcolor, self.opacity))

        RenderSurface.font = oldFonts.font
        RenderSurface.fontsize = oldFonts.fontsize
        RenderSurface.fontstyle = oldFonts.fontstyle
        RenderSurface.fontweight = oldFonts.fontweight
    end

    table.insert(RenderSurface.RenderElements, WEO_LABEL_CONTROLLER)

    if WEO_LABEL_CONTROLLER.parent and WEO_LABEL_CONTROLLER.parent.WeoController then
        table.insert(WEO_LABEL_CONTROLLER.parent.WeoController.Childs, WEO_LABEL_CONTROLLER)
    end

    return WEO_LABEL_CONTROLLER
end

return Label
