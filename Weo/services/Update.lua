UpdateService = {}
local Signal = require("Weo.class.Signal")
local sys = require("sys")
local UI = require("ui")
local Input = require("Weo.services.Input")
local Tween = require("Weo.services.Tween")
UpdateService.__index = UpdateService

---@class Heartbeat : Signal
---@field Fire fun(self, dt: number): nil
---@field Connect fun(self, callback: fun(DeltaTime: number)): table connection

---@type Heartbeat
UpdateService.Heartbeat = Signal.new()

function UpdateService:Kill()
    Weo.Alive = false
end


---@param targetFPS number
function UpdateService:Run(targetFPS)
    targetFPS = targetFPS or 60
    local frameDuration = 1 / targetFPS
    local lastTime = sys.clock() / 1000

    async(function()
        while Weo.Alive do
            local frameStart = sys.clock() / 1000
            local DeltaTime = frameStart - lastTime
            lastTime = frameStart

            self.Heartbeat:Fire(DeltaTime)
            UI.update()
            Input:Update(DeltaTime)
            Tween:Update(DeltaTime)

            local frameEnd = sys.clock() / 1000
            local elapsed = frameEnd - frameStart
            local remaining = frameDuration - elapsed

            if remaining > 0 then
                sleep(math.floor(remaining * 1000))
            end
        end
    end)

    waitall()
end

return UpdateService
