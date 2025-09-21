Task = {}
Task.__index = Task

---@class Task
---@field Running boolean
---@field Coroutine thread
---@field Kill fun(self)
---@field Pause fun(self)
---@field Resume fun(self)

---Creates a new non-blocking task.
---@param fn fun():nil
---@return Task
function Task.new(fn)
    local self = setmetatable({}, Task)
    self.Running = true
    self.Coroutine = coroutine.create(function()
        fn()
        self.Running = false
    end)

    function self:Kill()
        self.Running = false
    end

    function self:Pause()
        self.Running = false
    end

    function self:Resume()
        self.Running = true
    end

    UpdateService.Heartbeat:Connect(function(dt)
        if self.Running then
            local success, msg = coroutine.resume(self.Coroutine, dt)
            if not success then
                warn("Task error: " .. msg)
                self.Running = false
            end
        end
    end)
    return self
end

--- Wait inside a task.
---@param second number
---@return nil
function Task.wait(second)
    local start = 0
    while start < second do
        local dt = coroutine.yield()
        start = start + dt
    end
end

return Task
