---@meta

---@class DeltaTime : Signal
---@field Connect fun(self, callback: fun(DeltaTime: number)): table connection
---@field Fire fun(self, DeltaTime: number): nil

---@class UpdateService
---@field Heartbeat DeltaTime
---@field Kill fun(self)
---@field Run fun(self)