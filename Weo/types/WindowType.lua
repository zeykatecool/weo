---@meta


---@class EmptySignal : Signal
---@field Connect fun(self, callback: fun()): table connection
---@field Fire fun(self): nil

---@class ReturnXY : Signal
---@field Connect fun(self, callback: fun(Position: Vector2)): table connection
---@field Fire fun(self, Position: Vector2): nil

---@class ReturnXYB : Signal
---@field Connect fun(self, callback: fun(Position:Vector2,buttons:{left:boolean,middle:boolean,right:boolean,control:boolean,shift:boolean})): table connection
---@field Fire fun(self, Position:Vector2, buttons:{left:boolean,middle:boolean,right:boolean,control:boolean,shift:boolean}): nil

---@class ReturnBXY : Signal
---@field Connect fun(self, callback: fun(buttons:{left:boolean,middle:boolean,right:boolean},Position : Vector2)): table connection
---@field Fire fun(self, buttons:{left:boolean,middle:boolean,right:boolean,},Position : Vector2): nil

---@class ReturnWidthHeight : Signal
---@field Connect fun(self, callback: fun(width: number, height: number)): table connection
---@field Fire fun(self, width: number, height: number): nil

--- https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
---@class ReturnKey : Signal
---@field Connect fun(self, callback: fun(key: string)): table connection
---@field Fire fun(self, key: string): nil

---@class ReturnDrop : Signal
---@field Connect fun(self, callback: fun(kind : "text"|"files"|"unkown",content: string|table|nil)): table connection
---@field Fire fun(self, kind : "text"|"files"|"unkown",content: string|table|nil): nil

---@class Theme : Signal
---@field Connect fun(self, callback: fun(theme: string)): table connection
---@field Fire fun(self, theme: string): nil



---@class Window
---https://luart.org/doc/ui/Window.html
---@field style string READONLY: Style of the Window.
---@field title string Title of the Window.
---@field x number Horizontal position of the Window.
---@field y number Vertical position of the Window.
---@field width number Width of the Window.
---@field height number Height of the Window.
---@field cursor Enum.CursorStyle Mouse cursor image when hovering over the Window.
---@field align Enum.WindowAlign Align the Window relative to its parent.
---@field enabled boolean Whether the Window responds to events.
---@field visible boolean Whether the Window appears onscreen.
---@field allowdrop boolean Whether the Window is a drag and drop target.
---@field transparency number Window's transparency intensity.
---@field menu any Menu (LuaRT Element) for the Window.
---@field childs table READONLY: List of child widgets of the Window.
---@field parent Window|nil READONLY: Parent of the Window. Check `Weo.Core` for parent handling.
---@field monitor {name : string,primary : boolean,width : number,height : number} READONLY: Monitor in which the Window is located.
---@field topmost boolean Whether the Window stays above others.
---@field fullscreen boolean Whether the Window is fullscreen.
---@field bgcolor number Background color of the Window.
---@field traytooltip string Tooltip for the tray icon.
---@field tray table Weo TrayObject of the Window.
---@field icon string|any Path to the Window icon.
---@field center fun(self: Window) Center the Window on its parent.
---@field show fun(self: Window) Show the Window.
---@field hide fun(self: Window) Hide the Window.
---@field showmodal fun(self: Window,child: Window) Show Window as modal.
---@field minimize fun(self: Window) Minimize the Window to taskbar.
---@field maximize fun(self: Window) Maximize the Window to full Desktop.
---@field restore fun(self: Window) Restore Window size and position.
---@field startmoving fun(self: Window) Start dragging the Window.
---@field popup fun(self: Window,menu) Show a popup menu at mouse position.
---@field shortcut fun(self: Window,key:string,callback:function,ctrl:boolean,shift:boolean,alt:boolean) Set a keyboard shortcut.
---@field loadicon fun(self: Window,path:string,index:number): boolean Load the Window icon.
---@field notify fun(self: Window,title:string,message:string,iconstyle: Enum.IconStyle): boolean Send a Windows notification.
---@field loadtrayicon fun(self: Window,path:string,index:number): boolean Load the Window tray icon.
---@field status fun(self: Window,...) Display messages in the status bar.
---@field tofront fun(self: Window) Bring the Window to front.
---@field toback fun(self: Window) Send the Window to back.
---@field Shown EmptySignal Fires when the Window is shown
---@field Hidden EmptySignal Fires when the Window is hidden
---@field Closed EmptySignal Fires when the Window is closed
---@field Moved ReturnXY Fires when the Window moves
---@field Resized ReturnWidthHeight Fires when the Window is resized
---@field MouseButton1Click ReturnXY Fires when the Window is clicked
---@field MouseButton2Click ReturnXY Fires on right-click
---@field MouseHover ReturnXYB Fires on mouse hover
---@field KeyDown ReturnKey Fires when a key is pressed
---@field Created EmptySignal Fires when the Window is created
---@field TrayClicked EmptySignal Fires on tray icon click
---@field TrayDoubleClicked EmptySignal Fires on tray icon double-click
---@field TrayMouseHover EmptySignal Fires when hovering tray icon
---@field TrayMouse2Click EmptySignal Fires on tray icon right-click
---@field MouseButtonDown ReturnBXY Fires when a mouse button is pressed
---@field MouseButtonUp ReturnBXY Fires when a mouse button is released
---@field Minimized EmptySignal Fires when Window is minimized
---@field Maximized EmptySignal Fires when Window is maximized
---@field Restored EmptySignal Fires when Window is restored
---@field ContentDropped ReturnDrop Fires when Window receives drag-and-drop
---@field ThemeChanged Theme Fires when Windows theme changes
