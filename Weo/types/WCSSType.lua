---@alias WCSS_Frame { 
---     bgcolor: number|LinearGradient|RadialGradient|nil,
---     visible: boolean|nil, 
---     borderRadius: number|nil, 
---     zIndex: number|nil,
---     opacity: number|nil,
---     padding : number|nil,
---     paddingLeft : number|nil,
---     paddingRight : number|nil,
---     paddingTop : number|nil,
---     paddingBottom : number|nil,
---     borderColor : number|LinearGradient|RadialGradient|nil,
---     borderThickness : number|nil,
---     cursor : Enum.CursorStyle|nil,
---}

---@alias WCSS_Label { 
---     visible: boolean|nil, 
---     zIndex: number|nil, 
---     opacity: number|nil,
---     padding : number|nil,
---     paddingLeft : number|nil,
---     paddingRight : number|nil,
---     paddingTop : number|nil,
---     paddingBottom : number|nil,
---     font: string|nil,
---     fontsize : number|nil,
---     fontstyle : Enum.FontStyle|nil,
---     fontweight : number|nil,
---     textcolor : number|LinearGradient|RadialGradient|nil,
---     cursor : Enum.CursorStyle|nil,
---}


---@alias WCSS_Spec {
---     Frame: table<string, WCSS_Frame>, 
---     Label: table<string, WCSS_Label>,
--- } 


