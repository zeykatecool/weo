---@diagnostic disable: undefined-field
Weo = {
    Alive = true,
}
require("Weo.core.Color")
local Signal = require("Weo.class.Signal")
Weo.__index = Weo

local UI = require "ui"
require "canvas"

function print(...)
    require "console".writeln(...)
end

--- Returns the absolute position and size of an element relative to the root RenderSurface.
--- @param element any
--- @return {position : Vector2,size : Vector2}
function Weo.getAbsolutePositionAndSize(element, visited)
    visited = visited or {}
    if visited[element] then
        return { position = Vector2.new(0, 0), size = Vector2.new(0, 0) }
    end
    visited[element] = true

    local parent = element.parent
    local parentPos, parentSize = Vector2.new(0, 0), Vector2.new(0, 0)

    if type(parent) == "table" then
        if parent.WeoController and parent.WeoController.Type == "Frame" then
            local parentAbs = Weo.getAbsolutePositionAndSize(parent, visited)
            parentPos, parentSize = parentAbs.position, parentAbs.size
        elseif parent.IsRenderSurface then
            parentPos = Vector2.new(parent.x or 0, parent.y or 0)
            parentSize = Vector2.new(parent.width or 0, parent.height or 0)
        end
    end

    local posX = parentPos.x + (element.position.X.Scale or 0) * parentSize.x + (element.position.X.Offset or 0)
    local posY = parentPos.y + (element.position.Y.Scale or 0) * parentSize.y + (element.position.Y.Offset or 0)
    local width = (element.size.X.Scale or 0) * parentSize.x + (element.size.X.Offset or 0)
    local height = (element.size.Y.Scale or 0) * parentSize.y + (element.size.Y.Offset or 0)

    return { position = Vector2.new(posX, posY), size = Vector2.new(width, height) }
end


---@class ReturnTKV
---@field key any
---@field value any
---@field table table

---@class TableChangeSignal
---@field Connect fun(self, callback: fun(key: any, oldValue: any, newValue: any)): table connection
---@field Fire fun(self, key: any, oldValue: any, newValue: any): nil

---@class TableChange
---@field Changed TableChangeSignal
---@field [any] any

--- Returns a table that tracks changes.
---@param tbl table
---@return TableChange
function Weo.watchTable(tbl)
    local Changed = Signal.new()

    local proxy = {}
    proxy.Changed = Changed

    setmetatable(proxy, {
        __index = tbl,
        __newindex = function(t, k, v)
            local old = tbl[k]
            if old ~= v then
                tbl[k] = v
                Changed:Fire(k, old, v)
            end
        end
    })

    return proxy
end

require "Weo.services.Update"
require "Weo.services.Input"
require "Weo.services.Tween"
require "Weo.services.Theme"

require "Weo.core.Color"
require "Weo.core.Enum"

require "Weo.elements.Window"
require "Weo.elements.RenderSurface"
require "Weo.elements.Frame"
require "Weo.elements.Notify"
require "Weo.elements.Label"

require "Weo.class.Udim2"
require "Weo.class.Vector2"
require "Weo.class.Task"




return Weo
