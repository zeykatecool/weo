--- Quick.lua
--- This file is for understanding how Weo works.
--- Also a quick test if installation is successful.

--- Press E to test TweenService.

local Weo = require("Weo.core.Weo")
local window = Window.new {
    style = Enum.WindowStyle.Dialog,
    title = "Weo",
    width = 640,
    height = 480,
    allowdrop = true,
}

window.MouseButton1Click:Connect(function(Position)
    window:status("X: " .. Position.x .. " Y: " .. Position.y, "LMB")
end)

window.MouseButton2Click:Connect(function(Position)
    window:status("X: " .. Position.x .. " Y: " .. Position.y, "RMB")
end)

Input.InputBegan:Connect(function(input)
    if input.InputType == Enum.InputType.Keyboard then
        if input.InputCode == Enum.VirtualKeyCodes.Key.ESCAPE then
            UpdateService:Kill()
        end
    end
end)



local Render = RenderSurface.new(window, {
    bgcolor = Color.fromHEX("#1A1616FF"),
    visible = true,
})

local fatherFrame = Frame.new(Render, {
    size = UDim2.new(0, 100, 0, 100),
    position = UDim2.new(0.3, 0, 0.1, 0),
    bgcolor = Color.fromHEX("#7A7A7AFF"),
    visible = true,
    borderRadius = 15,
    zIndex = 0,
    padding = {
        top = 10,
        bottom = 10,
        left = 10,
        right = 10,
    },
    cursor = Enum.CursorStyle.Cross,
})

local label = Label.new(Render, {
    position = UDim2.new(0, 0, 0, 0),
    bgcolor = Color.fromHEX("#7A7A7AFF"),
    visible = true,
    borderRadius = 15,
    zIndex = 0,
    cursor = Enum.CursorStyle.Forbidden,
    text = "Lorem Ipsum",
    parent = fatherFrame,
    fontsize = 10,
})

label.MouseHover:Connect(function(Vector, b)
    print("X: " .. Vector.x .. " Y: " .. Vector.y, "Hover")
end)

Input.InputBegan:Connect(function(input)
    if input.InputType == Enum.InputType.Keyboard then
        if input.InputCode == Enum.VirtualKeyCodes.Key.ESCAPE then
            UpdateService:Kill()
        end
        if input.InputCode == Enum.VirtualKeyCodes.Key.E then
            local t = TweenService:Create(label, TweenInfo.new(1,Enum.EasingStyle.EaseInOutElastic), {
                fontsize = 55,
            })
            local F = TweenService:Create(fatherFrame, TweenInfo.new(1,Enum.EasingStyle.EaseInOutElastic), {
                size = UDim2.new(0, 350, 0, 200),
            })
            t.Completed:Connect(function()
                F:Play()
            end)
            t:Play()
        end
    end
end)

UpdateService.Heartbeat:Connect(function(DeltaTime)
    window:status("FPS: " .. math.floor(1 / DeltaTime))
end)

UpdateService:Run(100)
