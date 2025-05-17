-- Slider class for settings menu
local fontManager = require "src.fontManager"

local Slider = {}
Slider.__index = Slider

-- Create a new slider
function Slider.new(x, y, width, height, min, max, value, label, onChange)
    local self = setmetatable({}, Slider)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.min = min or 0
    self.max = max or 1
    self.value = value or self.min
    self.label = label or ""
    self.onChange = onChange
    self.dragging = false
    
    -- Colors
    self.barColor = {0.4, 0.4, 0.5, 1}
    self.handleColor = {0.8, 0.8, 0.9, 1}
    self.textColor = {1, 1, 1, 1}
    
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
    end
end

-- Handle mouse press
function Slider:mousepressed(x, y)
    if x >= self.x and x <= self.x + self.width and
       y >= self.y and y <= self.y + self.height + 20 then
        self.dragging = true
        self:updateValue(x)
        return true
    end
    return false
end

-- Handle mouse release
function Slider:mousereleased(x, y)
    self.dragging = false
end

-- Update the slider when dragging
function Slider:updateValue(mouseX)
    local pos = (mouseX - self.x) / self.width
    pos = math.max(0, math.min(1, pos))
    self:setFromPosition(pos)
end

-- Update the slider
function Slider:update(dt)
    if self.dragging then
        self:updateValue(love.mouse.getX())
    end
end

-- Draw the slider
function Slider:draw()
    -- Use Unicode font for all text
    local font = fontManager.getFont(16)
    love.graphics.setFont(font)
    
    -- Draw the label
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.label, self.x, self.y - 20)
    
    -- Draw the bar
    love.graphics.setColor(self.barColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 4, 4)
    
    -- Draw the filled part
    love.graphics.setColor(0.6, 0.6, 0.7, 1)
    local fillWidth = self.width * self:getPosition()
    love.graphics.rectangle("fill", self.x, self.y, fillWidth, self.height, 4, 4)
    
    -- Draw the border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 4, 4)
    
    -- Draw the handle
    love.graphics.setColor(self.handleColor)
    local handleX = self.x + self.width * self:getPosition() - 5
    love.graphics.rectangle("fill", handleX, self.y - 2, 10, self.height + 4, 3, 3)
    
    -- Draw the value text (as a percentage)
    local percent = math.floor(self:getPosition() * 100)
    love.graphics.setColor(self.textColor)
    love.graphics.print(percent .. "%", self.x + self.width + 10, self.y)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return Slider
