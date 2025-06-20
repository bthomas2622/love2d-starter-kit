-- Slider class for settings menu
local love = require("love")
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local gameConfig = require("src.constants.gameConfig")

local Slider = {}
Slider.__index = Slider

-- Create a new slider
function Slider.new(x, y, width, height, min, max, value, label, onChange, guiScale)
    local self = setmetatable({}, Slider)
    self.x = x            -- Position on the virtual canvas
    self.y = y            -- Position on the virtual canvas
    self.width = width    -- Width on the virtual canvas
    self.height = height  -- Height on the virtual canvas
    self.min = min or 0
    self.max = max or 1
    self.value = value or self.min    self.label = label or ""
    self.onChange = onChange    self.dragging = false
    self.guiScale = guiScale or 1
    self.lastValue = value -- To track value changes for sound effects
    self.hovered = false -- Track if the mouse is hovering over the slider
    self.lastHoverState = false -- Track previous hover state to detect changes    -- Colors
    self.barColor = gameConfig.UI.SLIDER.BAR_COLOR
    self.handleColor = gameConfig.UI.SLIDER.HANDLE_COLOR
    self.textColor = gameConfig.UI.SLIDER.TEXT_COLOR

    -- Font sized for the virtual canvas
    self.font = fontManager.getFont(gameConfig.UI.SLIDER.FONT_SIZE)

    return self
end

-- Get the normalized position (0-1) based on value
function Slider:getPosition()
    return (self.value - self.min) / (self.max - self.min)
end

-- Set value from normalized position (0-1)
function Slider:setFromPosition(pos)
    local newValue = self.min + pos * (self.max - self.min)
    newValue = math.max(self.min, math.min(self.max, newValue))
    
    if newValue ~= self.value then
        self.value = newValue
        if self.onChange then
            self.onChange(self.value)
        end
        soundManager.playSound("menuMove")
    end
end

-- Handle mouse click (alias for mousepressed for compatibility)
function Slider:click(x, y)
    return self:mousepressed(x, y)
end

-- Handle mouse press
function Slider:mousepressed(x, y)    -- x and y are already in virtual canvas coordinates
    local sliderArea = gameConfig.UI.SLIDER.CLICK_AREA_PADDING -- Extra clickable area around slider to make it easier to grab
    if x >= self.x - sliderArea and x <= self.x + self.width + sliderArea and
       y >= self.y - sliderArea and y <= self.y + self.height + sliderArea then
        self.dragging = true
        self:updateValue(x)
        return true
    end
    return false
end

-- Handle mouse release
function Slider:mousereleased(x, y)
    if self.dragging then
    end
    self.dragging = false
end

-- Update the slider when dragging
function Slider:updateValue(mouseX)
    local pos = (mouseX - self.x) / self.width
    pos = math.max(0, math.min(1, pos))
    self:setFromPosition(pos)
end

-- Update the slider
function Slider:update(dt, guiScale)
    if guiScale and self.guiScale ~= guiScale then
        self.guiScale = guiScale
        -- Font is already sized for virtual canvas - no need to update
    end

    -- Check for hover state
    local rawMouseX, rawMouseY = love.mouse.getPosition()
    local scale, offsetX, offsetY = love.getScreenTransform()

    if scale and scale ~= 0 then -- Prevent division by zero
        local mx = (rawMouseX - offsetX) / scale
        local my = (rawMouseY - offsetY) / scale
          -- Check if mouse is hovering over the slider
        local sliderArea = gameConfig.UI.SLIDER.CLICK_AREA_PADDING -- Extra area around slider to make it easier to detect
        local currentlyHovered = mx >= self.x - sliderArea and mx <= self.x + self.width + sliderArea and
                               my >= self.y - sliderArea and my <= self.y + self.height + sliderArea
        
        -- Play sound when we first hover over the slider
        if currentlyHovered and not self.lastHoverState then
            soundManager.playSound("menuMove")
        end
        
        -- Update tracking states
        self.lastHoverState = currentlyHovered
        self.hovered = currentlyHovered
        
        -- Handle dragging
        if self.dragging then
            self:updateValue(mx)
        end
    end
end

-- Draw the slider
function Slider:draw()
    -- Use font sized for virtual canvas
    love.graphics.setFont(self.font)
      -- Draw the label
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.label, self.x, self.y - self.font:getHeight() - gameConfig.UI.SLIDER.LABEL_Y_OFFSET)
    
    -- Calculate scaled visual properties
    local cornerRadius = gameConfig.UI.SLIDER.CORNER_RADIUS_SCALE * self.guiScale
    local handleWidth = gameConfig.UI.SLIDER.HANDLE_WIDTH_SCALE * self.guiScale
    local handleHeight = self.height + gameConfig.UI.SLIDER.HANDLE_HEIGHT_OFFSET

    -- Draw the bar background
    love.graphics.setColor(self.barColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, cornerRadius, cornerRadius)
      -- Draw the filled part
    love.graphics.setColor(gameConfig.UI.SLIDER.FILL_COLOR)
    local fillWidth = self.width * self:getPosition()
    love.graphics.rectangle("fill", self.x, self.y, fillWidth, self.height, cornerRadius, cornerRadius)
    
    -- Draw the border
    love.graphics.setColor(gameConfig.UI.SLIDER.BORDER_COLOR)
    love.graphics.setLineWidth(1 * self.guiScale)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, cornerRadius, cornerRadius)
    love.graphics.setLineWidth(1) -- Reset line width
      -- Draw the handle
    love.graphics.setColor(self.handleColor)
    local handleX = self.x + self.width * self:getPosition() - (handleWidth / 2)
    love.graphics.rectangle("fill", handleX, self.y - 2, handleWidth, handleHeight, gameConfig.UI.SLIDER.HANDLE_CORNER_RADIUS, gameConfig.UI.SLIDER.HANDLE_CORNER_RADIUS)
    
    -- Draw the value text (as a percentage)
    local percent = math.floor(self:getPosition() * 100)
    love.graphics.setColor(self.textColor)
    love.graphics.print(percent .. "%", self.x + self.width + 10, self.y)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Check if mouse is over the slider
function Slider:isMouseOver(mx, my)
    -- mx, my are in virtual canvas coordinates
    return mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
end

return Slider
