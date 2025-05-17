-- Button class for the menus
local fontManager = require "src.fontManager"

local Button = {}
Button.__index = Button

-- Create a new button
function Button.new(x, y, width, height, text, callback)
    local self = setmetatable({}, Button)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text
    self.callback = callback
    self.hovered = false
    
    -- Default colors
    self.normalColor = {0.4, 0.4, 0.5, 1}
    self.hoverColor = {0.5, 0.5, 0.6, 1}
    self.textColor = {1, 1, 1, 1}
    
    return self
end

-- Update the button state
function Button:update(dt)
    local mx, my = love.mouse.getPosition()
    self.hovered = mx >= self.x and mx <= self.x + self.width and
                   my >= self.y and my <= self.y + self.height
end

-- Draw the button
function Button:draw()
    -- Draw the button background
    love.graphics.setColor(self.hovered and self.hoverColor or self.normalColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 8, 8)
    
    -- Draw the button border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 8, 8)
      -- Draw the text
    love.graphics.setColor(self.textColor)
    
    -- Use Unicode-capable font
    local font = fontManager.getFont(16) -- Use consistent font size
    love.graphics.setFont(font)
    
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(self.text, textX, textY)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Check if button is clicked
function Button:click(x, y)
    if x >= self.x and x <= self.x + self.width and
       y >= self.y and y <= self.y + self.height then
        if self.callback then
            self.callback()
        end
        return true
    end
    return false
end

return Button
