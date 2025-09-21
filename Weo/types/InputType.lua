---@meta

---@class InputData
---@field InputType Enum.InputType
---@field InputKey string|nil
---@field InputCode number|nil
---@field InputButton string|nil

---@class InputBegan : Signal
---@field Connect fun(self, callback: fun(input: InputData)): table connection
---@field Fire fun(self, input: InputData): nil

---@class InputEnded : Signal
---@field Connect fun(self, callback: fun(input: InputData)): table connection
---@field Fire fun(self, input: InputData): nil

---@class Input
---@field InputBegan InputBegan
---@field InputEnded InputEnded
