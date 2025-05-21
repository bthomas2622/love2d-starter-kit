-- Slider class for settings menu
local love = require("love")
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"

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
    self.onChange = onChange
    self.dragging = false
    self.guiScale = guiScale or 1
    self.lastValue = value -- To track value changes for sound effects

    -- Colors
    self.barColor = {0.4, 0.4, 0.5, 1}
    self.handleColor = {0.8, 0.8, 0.9, 1}
    self.textColor = {1, 1, 1, 1}

    -- Font sized for the virtual canvas
    self.font = fontManager.getFont(16)

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
function Slider:mousepressed(x, y)
    -- x and y are already in virtual canvas coordinates
    local sliderArea = 20 -- Extra clickable area around slider to make it easier to grab
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

    if self.dragging then
        -- Get the mouse position in virtual canvas coordinates
        local mx, my = love.mouse.getPosition()
        local scale, offsetX, offsetY = love.getScreenTransform()

        if scale and scale ~= 0 then -- Prevent division by zero
            local virtualMouseX = (mx - offsetX) / scale
            self:updateValue(virtualMouseX)
        end
    end
end

-- Draw the slider
function Slider:draw()
    -- Use font sized for virtual canvas
    love.graphics.setFont(self.font)
    
    -- Draw the label
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.label, self.x, self.y - self.font:getHeight() - 5)
    
    -- Calculate scaled visual properties
    local cornerRadius = 4 * self.guiScale
    local handleWidth = 10 * self.guiScale
    local handleHeight = self.height + 4

    -- Draw the bar background
    love.graphics.setColor(self.barColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, cornerRadius, cornerRadius)
    
    -- Draw the filled part
    love.graphics.setColor(0.6, 0.6, 0.7, 1)
    local fillWidth = self.width * self:getPosition()
    love.graphics.rectangle("fill", self.x, self.y, fillWidth, self.height, cornerRadius, cornerRadius)
    
    -- Draw the border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setLineWidth(1 * self.guiScale)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, cornerRadius, cornerRadius)
    love.graphics.setLineWidth(1) -- Reset line width
    
    -- Draw the handle
    love.graphics.setColor(self.handleColor)
    local handleX = self.x + self.width * self:getPosition() - (handleWidth / 2)
    love.graphics.rectangle("fill", handleX, self.y - 2, handleWidth, handleHeight, 3, 3)
    
    -- Draw the value text (as a percentage)
    local percent = math.floor(self:getPosition() * 100)
    love.graphics.setColor(self.textColor)
    love.graphics.print(percent .. "%", self.x + self.width + 10, self.y)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return Slider
