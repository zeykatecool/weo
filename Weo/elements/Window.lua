local Signal = require("Weo.class.Signal")
local UI = require("ui")
local Vector2 = require("Weo.class.Vector2")
Window = {}
Notify = {}
local function mousePosition(window)
    local x, y = UI.mousepos()

    if not window then
        return { x = x, y = y }
    end


    if window.style == Enum.WindowStyle.Raw then
        return {
            x = x - window.x,
            y = y - window.y
        }
    end


    local TITLEBAR_HEIGHT = 32
    return {
        x = x - window.x,
        y = y - window.y - TITLEBAR_HEIGHT
    }
end


---Creates a new window.
---@param WindowProperties {icon : string|any,title : string, style : Enum.WindowStyle, width : number, height : number, allowdrop : boolean, cursor : Enum.CursorStyle,x : number,y : number,enabled : boolean,visible : boolean,transparency : number,childs : table,parent : Window|nil,monitor : table,topmost : boolean,fullscreen : boolean,font : string,fontstyle : string,fontsize : number,bgcolor : number,traytooltip : string}
---@return Window
function Window.new(WindowProperties)
    assert(type(WindowProperties) == "table", "WindowProperties must be a table")
    assert(type(WindowProperties.title) == "string", "WindowProperties.title must be a string")
    assert(type(WindowProperties.style) == "string", "WindowProperties.style must be a string")
    assert(type(WindowProperties.width) == "number", "WindowProperties.width must be a number")
    assert(type(WindowProperties.height) == "number", "WindowProperties.height must be a number")

    local Window = UI.Window(WindowProperties.title, WindowProperties.style, WindowProperties.width,
        WindowProperties.height)
    for key, value in pairs(WindowProperties) do
        Window[key] = value
    end
    Window.style = WindowProperties.style

    if WindowProperties.icon then
        Window:loadicon(WindowProperties.icon)
    end

    local function parentH()
        if Window.parent == Window then
            return "root"
        else
            return Window.parent
        end
    end

    Window.parent = parentH()

    Window:show()

    Window.Shown = Signal.new()
    Window.Hidden = Signal.new()
    Window.Closed = Signal.new()
    Window.Moved = Signal.new()
    Window.Resized = Signal.new()
    Window.MouseButton1Click = Signal.new()
    Window.MouseButton2Click = Signal.new()
    Window.MouseHover = Signal.new()
    Window.KeyDown = Signal.new()
    Window.Created = Signal.new()
    Window.TrayClicked = Signal.new()
    Window.TrayDoubleClicked = Signal.new()
    Window.TrayMouseHover = Signal.new()
    Window.TrayMouse2Click = Signal.new()
    Window.MouseButtonDown = Signal.new()
    Window.MouseButtonUp = Signal.new()
    Window.Minimized = Signal.new()
    Window.Maximized = Signal.new()
    Window.Restored = Signal.new()
    Window.ContentDropped = Signal.new()
    Window.ThemeChanged = Signal.new()

    function Window:onShow()
        self.Shown:Fire()
    end

    function Window:onHide()
        self.Hidden:Fire()
    end

    function Window:onClose()
        self.Closed:Fire()
        Weo.Alive = false
    end

    function Window:onMove()
        x, y = self.x, self.y
        local MovedVector = Vector2.new(x, y)
        self.Moved:Fire(MovedVector)
    end

    function Window:onResize()
        width, height = self.width, self.height
        self.Resized:Fire(width, height)
    end

    function Window:onClick(x, y)
        local Vector = Vector2.new(x, y)
        self.MouseButton1Click:Fire(Vector)
    end

    function Window:onContext()
        local M = mousePosition(self)
        local x, y = M.x, M.y
        local Vector = Vector2.new(x, y)
        self.MouseButton2Click:Fire(Vector)
    end

    function Window:onHover(x, y, b)
        local Vector = Vector2.new(x, y)
        self.MouseHover:Fire(Vector, b)
    end

    function Window:onKey(key)
        self.KeyDown:Fire(key)
    end

    function Window:onCreate()
        self.Created:Fire()
    end

    function Window:onTrayClick()
        self.TrayClicked:Fire()
        self.tray.MouseButton1Click:Fire()
    end

    function Window:onTrayDoubleClick()
        self.TrayDoubleClicked:Fire()
        self.tray.DoubleClicked:Fire()
    end

    function Window:onTrayHover()
        self.TrayMouseHover:Fire()
        self.tray.MouseHover:Fire()
    end

    function Window:onTrayContext()
        self.TrayMouse2Click:Fire()
        self.tray.MouseButton2Click:Fire()
    end

    function Window:onMouseDown(button, x, y)
        local Vector = Vector2.new(x, y)
        self.MouseButtonDown:Fire(Vector, button)
    end

    function Window:onMouseUp(button, x, y)
        local Vector = Vector2.new(x, y)
        self.MouseButtonUp:Fire(Vector, button)
    end

    function Window:onMinimize()
        self.Minimized:Fire()
    end

    function Window:onMaximize()
        self.Maximized:Fire()
    end

    function Window:onRestore()
        self.Restored:Fire()
    end

    function Window:onDrop(kind, content)
        self.ContentDropped:Fire(kind, content)
    end

    function Window:onThemeChange(isDark)
        local theme = isDark and "dark" or "light"
        self.ThemeChanged:Fire(theme)
    end

    return Window
end
