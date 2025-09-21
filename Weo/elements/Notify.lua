local Signal = require("Weo.class.Signal")
Notify = {}
---Send a Windows notification.
---@param Window Window
---@param NotifyProperties {title: string, message: string, iconstyle: Enum.IconStyle}
---@return Notify
function Notify.new(Window, NotifyProperties)
    local self = {}
    self.title = NotifyProperties.title
    self.message = NotifyProperties.message
    self.iconstyle = NotifyProperties.iconstyle
    self.Clicked = Signal.new()

    ---Send the notification.
    ---@return boolean
    function self:send()
        return Window:notify(self.title, self.message, self.iconstyle)
    end

    local function onWindowNotifyClick()
        self.Clicked:Fire(Window)
    end

    if not Window._NotifyConnections then
        Window._NotifyConnections = {}
        function Window:onNotificationClick()
            for _, conn in ipairs(Window._NotifyConnections) do
                conn()
            end
        end
    end

    table.insert(Window._NotifyConnections, onWindowNotifyClick)

    return self
end
