TweenService = {}
TweenService.__index = TweenService
local Signal = require("Weo.class.Signal")

local activeTweens = {}

local function linear(t) return t end
local function lerp(a,b,t) return a + (b-a)*t end

local function lerpUDim2(a,b,t)
    return UDim2.new(
        lerp(a.X.Scale,b.X.Scale,t), lerp(a.X.Offset,b.X.Offset,t),
        lerp(a.Y.Scale,b.Y.Scale,t), lerp(a.Y.Offset,b.Y.Offset,t)
    )
end

local function lerpVector2(a,b,t)
    return {x=lerp(a.x,b.x,t), y=lerp(a.y,b.y,t)}
end

local function lerpColorNumber(startHex, goalHex, t)
    local startR = (startHex >> 24) & 0xFF
    local startG = (startHex >> 16) & 0xFF
    local startB = (startHex >> 8) & 0xFF
    local startA = startHex & 0xFF

    local goalR = (goalHex >> 24) & 0xFF
    local goalG = (goalHex >> 16) & 0xFF
    local goalB = (goalHex >> 8) & 0xFF
    local goalA = goalHex & 0xFF

    local R = math.floor(lerp(startR, goalR, t))
    local G = math.floor(lerp(startG, goalG, t))
    local B = math.floor(lerp(startB, goalB, t))
    local A = math.floor(lerp(startA, goalA, t))

    return (R << 24) | (G << 16) | (B << 8) | A
end


local Styles = {
    linear = function(t) return t end,

    easeInQuad = function(t) return t * t end,
    easeOutQuad = function(t) return t * (2 - t) end,
    easeInOutQuad = function(t)
        t = t * 2
        if t < 1 then return 0.5 * t * t end
        t = t - 1
        return -0.5 * (t * (t - 2) - 1)
    end,

    easeInCubic = function(t) return t * t * t end,
    easeOutCubic = function(t) return 1 + (t - 1)^3 end,
    easeInOutCubic = function(t)
        t = t * 2
        if t < 1 then return 0.5 * t^3 end
        t = t - 2
        return 0.5 * (t^3 + 2)
    end,

    easeInQuart = function(t) return t^4 end,
    easeOutQuart = function(t) return 1 - (t - 1)^4 end,
    easeInOutQuart = function(t)
        t = t * 2
        if t < 1 then return 0.5 * t^4 end
        t = t - 2
        return -0.5 * (t^4 - 2)
    end,

    easeInQuint = function(t) return t^5 end,
    easeOutQuint = function(t) return 1 + (t - 1)^5 end,
    easeInOutQuint = function(t)
        t = t * 2
        if t < 1 then return 0.5 * t^5 end
        t = t - 2
        return 0.5 * (t^5 + 2)
    end,

    easeInSine = function(t) return 1 - math.cos(t * math.pi / 2) end,
    easeOutSine = function(t) return math.sin(t * math.pi / 2) end,
    easeInOutSine = function(t) return -(math.cos(math.pi * t) - 1) / 2 end,

    easeInExpo = function(t) return (t == 0) and 0 or 2^(10 * (t - 1)) end,
    easeOutExpo = function(t) return (t == 1) and 1 or 1 - 2^(-10 * t) end,
    easeInOutExpo = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        t = t * 2
        if t < 1 then return 0.5 * 2^(10 * (t - 1)) end
        return 0.5 * (2 - 2^(-10 * (t - 1)))
    end,

    easeInCirc = function(t) return 1 - math.sqrt(1 - t * t) end,
    easeOutCirc = function(t) return math.sqrt(1 - (t - 1)^2) end,
    easeInOutCirc = function(t)
        t = t * 2
        if t < 1 then return -0.5 * (math.sqrt(1 - t * t) - 1) end
        t = t - 2
        return 0.5 * (math.sqrt(1 - t * t) + 1)
    end,

    easeInBack = function(t, s)
        s = s or 1.70158
        return t * t * ((s + 1) * t - s)
    end,
    easeOutBack = function(t, s)
        s = s or 1.70158
        t = t - 1
        return t * t * ((s + 1) * t + s) + 1
    end,
    easeInOutBack = function(t, s)
        s = (s or 1.70158) * 1.525
        t = t * 2
        if t < 1 then return 0.5 * (t * t * ((s + 1) * t - s)) end
        t = t - 2
        return 0.5 * (t * t * ((s + 1) * t + s) + 2)
    end,

    easeInElastic = function(t)
        if t == 0 or t == 1 then return t end
        return -2^(10 * (t - 1)) * math.sin((t - 1.075) * (2 * math.pi) / 0.3)
    end,
    easeOutElastic = function(t)
        if t == 0 or t == 1 then return t end
        return 2^(-10 * t) * math.sin((t - 0.075) * (2 * math.pi) / 0.3) + 1
    end,
    easeInOutElastic = function(t)
        if t == 0 or t == 1 then return t end
        t = t * 2
        if t < 1 then
            return -0.5 * (2^(10 * (t - 1)) * math.sin((t - 1.1125) * (2 * math.pi) / 0.45))
        end
        return 0.5 * (2^(-10 * (t - 1)) * math.sin((t - 1.1125) * (2 * math.pi) / 0.45)) + 1
    end,

    easeInBounce = function(t) return 1 - Styles.easeOutBounce(1 - t) end,
    easeOutBounce = function(t)
        if t < (1 / 2.75) then
            return 7.5625 * t * t
        elseif t < (2 / 2.75) then
            t = t - (1.5 / 2.75)
            return 7.5625 * t * t + 0.75
        elseif t < (2.5 / 2.75) then
            t = t - (2.25 / 2.75)
            return 7.5625 * t * t + 0.9375
        else
            t = t - (2.625 / 2.75)
            return 7.5625 * t * t + 0.984375
        end
    end,
    easeInOutBounce = function(t)
        if t < 0.5 then return Styles.easeInBounce(t * 2) * 0.5 end
        return Styles.easeOutBounce(t * 2 - 1) * 0.5 + 0.5
    end,
}


TweenInfo = {}
TweenInfo.__index = TweenInfo

---@class TweenInfo
---Creates a new tween info.
---@field Time number The duration of the tween.
---@field EasingStyle string The easing function.
---@return {Time: number, EasingStyle: Enum.EasingStyle}
function TweenInfo.new(Time, EasingStyle)
    return setmetatable({
        Time = Time or 1,
        EasingStyle = Styles[EasingStyle] or Styles.linear
    }, TweenInfo)
end

---@class Tween
local Tween = {}
Tween.__index = Tween

---Creates a new tween.
---@param object any The object to tween.
---@param tweenInfo TweenInfo The tween info.
---@param goal table The goal values.
function Tween.new(object, tweenInfo, goal)
    local self = setmetatable({
        Object = object,
        Goal = goal,
        Time = tweenInfo.Time,
        Easing = tweenInfo.EasingStyle,
        Elapsed = 0,
        StartValues = {},
        Completed = Signal.new(),
        Playing = false
    }, Tween)

    for prop, val in pairs(goal) do
        self.StartValues[prop] = object[prop]
    end

    return self
end

---Starts the tween.
function Tween:Play()
    if not self.Playing then
        self.Elapsed = 0
        self.Playing = true
        table.insert(activeTweens, self)
    end
end

---Stops the tween.
function Tween:Stop()
    if self.Playing then
        self.Playing = false
        for i=#activeTweens,1,-1 do
            if activeTweens[i] == self then
                table.remove(activeTweens,i)
            end
        end
    end
end

function TweenService:Update(dt)
    for i = #activeTweens,1,-1 do
        local tween = activeTweens[i]
        if tween.Playing then
            tween.Elapsed = tween.Elapsed + dt
            local t = math.min(tween.Elapsed / tween.Time, 1)
            local eased = tween.Easing(t)

            for prop, goalVal in pairs(tween.Goal) do
                local startVal = tween.StartValues[prop]

                if type(goalVal) == "number" then
                    if goalVal > 0xFFFFFF then
                        tween.Object[prop] = lerpColorNumber(startVal, goalVal, eased)
                    else
                        tween.Object[prop] = lerp(startVal, goalVal, eased)
                    end
                elseif type(goalVal) == "table" then
                    if goalVal.X and goalVal.Y then
                        tween.Object[prop] = lerpUDim2(startVal, goalVal, eased)
                    elseif startVal.x and startVal.y then
                        tween.Object[prop] = lerpVector2(startVal, goalVal, eased)
                    else
                        tween.Object[prop] = goalVal
                    end
                end
            end

            if t >= 1 then
                tween.Completed:Fire()
                tween:Stop()
            end
        end
    end
end

---Creates a new tween.
---@param object any The object to tween.
---@param tweenInfo TweenInfo The tween info.
---@param goal table The goal values.
function TweenService:Create(object, tweenInfo, goal)
    return Tween.new(object, tweenInfo, goal)
end

return TweenService
