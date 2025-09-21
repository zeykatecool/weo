Theme = {}
Theme.__index = Theme
Styles = {}


local Schema = {
    Frame = {
        ["*"] = {
            bgcolor = "number",
            visible = "boolean",
            borderRadius = "number",
            zIndex = "number",
            opacity = "number",
            padding = "number",
            paddingLeft = "number",
            paddingRight = "number",
            paddingTop = "number",
            paddingBottom = "number",
            borderColor = "number",
            borderThickness = "number",
            cursor = "string",
        },
    },
    Label = {
        ["*"] = {
            bgcolor = "number",
            visible = "boolean",
            borderRadius = "number",
            zIndex = "number",
            opacity = "number",
            padding = "number",
            paddingLeft = "number",
            paddingRight = "number",
            paddingTop = "number",
            paddingBottom = "number",
            font = "string",
            fontsize = "number",
            fontstyle = "string",
            fontweight = "number",
            textcolor = "number",
            cursor = "string",
        },
    },
}



function Theme.load(ThemeFile)
    if type(ThemeFile) == "string" then
        local F = loadfile(ThemeFile)
        if F then
            return F()
        else
            error("WCSS: Could not load theme file: " .. ThemeFile)
        end
    end
end

local function checkType(value, expectedType)
    if expectedType == "number" then
        return type(value) == "number"
    elseif expectedType == "boolean" then
        return type(value) == "boolean"
    elseif expectedType == "string" then
        return type(value) == "string"
    end
    return false
end

local function validateStyle(componentType, styleName, styleTable)
    local rules = Schema[componentType]
    if not rules then
        error("WCSS: No schema defined for component type: " .. tostring(componentType))
    end

    local ruleSet = rules[styleName] or rules["*"]
    if not ruleSet then
        error("WCSS: No rules for style '" .. styleName .. "' in component " .. componentType)
    end

    for key, val in pairs(styleTable) do
        local expectedType = ruleSet[key]
        if not expectedType then
            error("WCSS: Unexpected property '" .. key .. "' in style '" .. styleName .. "' of component '" .. componentType .. "'")
        end
        if not checkType(val, expectedType) then
            error("WCSS: Property '" .. key .. "' in style '" .. styleName .. "' of component '" .. componentType .. "' must be " .. expectedType .. ", got " .. type(val))
        end
    end
end

---@param WCSS_Table WCSS_Spec
function WCSS(WCSS_Table)
    for componentType, styles in pairs(WCSS_Table) do
        Styles[componentType] = {}
        for styleName, styleTable in pairs(styles) do
            validateStyle(componentType, styleName, styleTable)
            Styles[componentType][styleName] = styleTable
        end
    end
end

---@param r number
---@param g number
---@param b number
---@param a number
---@return number
--- Create a rgba color.
function rgba(r, g, b, a)
    if r <= 1 then r = r * 255 end
    if g <= 1 then g = g * 255 end
    if b <= 1 then b = b * 255 end
    if a <= 1 then a = a * 255 end

    r = math.floor(r)
    g = math.floor(g)
    b = math.floor(b)
    a = math.floor(a)

    return Color.fromRGBA(r,g,b,a)
end


---@param r number
---@param g number
---@param b number
---@return number
--- Create a rgb color.
function rgb(r, g, b)
    return rgba(r, g, b, 255)
end


return Theme, Styles