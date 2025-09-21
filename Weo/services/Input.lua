local Signal = require("Weo.class.Signal")
---@class Input
Input = {
    Initialized = false,
}
Input.InputBegan = Signal.new()
Input.InputEnded = Signal.new()
local Enum = require("Weo.core.Enum")
local keyboard = require("keyboard")
local prevKeys = {}
for _, group in pairs({ Enum.VirtualKeyCodes.Mouse, Enum.VirtualKeyCodes.Key }) do
    for keyName, _ in pairs(group) do
        prevKeys[keyName] = false
    end
end

function Input:Update(dt)
    for groupName, group in pairs({ Mouse = Enum.VirtualKeyCodes.Mouse, Key = Enum.VirtualKeyCodes.Key }) do
        for keyName, _ in pairs(group) do
            local down = keyboard.isdown(keyName)
            local prev = prevKeys[keyName]

            if down and not prev then
                Input.InputBegan:Fire({
                    InputType = (groupName == "Key") and "Keyboard" or "Mouse",
                    InputKey = (groupName == "Key") and keyName or nil,
                    InputCode = (groupName == "Key") and group[keyName] or nil,
                    InputButton = (groupName == "Mouse") and keyName or nil,
                })
            elseif not down and prev then
                Input.InputEnded:Fire({
                    InputType = (groupName == "Key") and "Keyboard" or "Mouse",
                    InputKey = (groupName == "Key") and keyName or nil,
                    InputCode = (groupName == "Key") and group[keyName] or nil,
                    InputButton = (groupName == "Mouse") and keyName or nil,
                })
            end

            prevKeys[keyName] = down
        end
    end
end

---Checks if a key is down.
---@param key string|number
function Input.IsKeyDown(key)
    if type(key) == "string" then
        key = string.byte(key)
    end
    return keyboard.isdown(key)
end

---Checks if a key is up.
---@param key string|number
function Input.IsKeyUp(key)
    if type(key) == "string" then
        key = string.byte(key)
    end
    return not keyboard.isdown(key)
end

local UI = require("ui")

---Returns the current mouse position, relative to the window if AccordToWindow is true
---@param AccordToWindow Window|nil
---@return {x : number, y : number}
function Input.MousePosition(AccordToWindow)
       local x, y = UI.mousepos()

    if not AccordToWindow then
        return {x = x, y = y}
    end

    if  AccordToWindow.style == Enum.WindowStyle.Raw then
        return {
            x = x - AccordToWindow.x,
            y = y - AccordToWindow.y
        }
    end

    local TITLEBAR_HEIGHT = 32
    return {
        x = x - AccordToWindow.x,
        y = y - AccordToWindow.y - TITLEBAR_HEIGHT
    }
end

return Input
