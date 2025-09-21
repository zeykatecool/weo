---@class Signal<T>
---@field _connections table
Signal = {}
Signal.__index = Signal

---@generic T
---@return Signal<T>
--- Creates a new Signal.
function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    return self
end

---@generic T
---@param callback fun(...:T)
---@return table connection
--- Connects a callback to the Signal.
function Signal:Connect(callback)
    local connection = {Connected = true, Callback = callback}
    table.insert(self._connections, connection)
    function connection:Disconnect()
        self.Connected = false
        for i, conn in ipairs(self._connections) do
            if conn == connection then
                table.remove(self._connections, i)
                break
            end
        end
    end
    return connection
end


---@generic T
---@param ... T
--- Fires the Signal.
function Signal:Fire(...)
    for _, conn in ipairs(self._connections) do
        if conn.Connected and conn.Callback then
            conn.Callback(...)
        end
    end
end

---Stop listening to the signals.
---This will remove all connections!
function Signal:KillAll()
    for _, conn in ipairs(self._connections) do
        conn:Disconnect()
    end
end

---Stops listening to the `Signal`.
function Signal:Kill(Connection)
    Connection:Disconnect()
end

return Signal
