-- Dropdown menu class for settings
local fontManager = require "src.fontManager"

local Dropdown = {}
Dropdown.__index = Dropdown

-- Create a new dropdown
function Dropdown.new(x, y, width, height, options, selectedIndex, label, onChange)
    local self = setmetatable({}, Dropdown)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.options = options or {}
    self.selectedIndex = selectedIndex or 1
    self.label = label or ""
    self.onChange = onChange
    self.open = false
    self.direction = "down"  -- Default direction: down. Can be "up" or "down"
    
    -- Scrolling support
    self.scrollOffset = 0
    self.maxVisibleOptions = 10  -- Default: show up to 10 options (can be overridden)
    
    -- Colors
    self.backgroundColor = {0.4, 0.4, 0.5, 1}
    self.hoverColor = {0.5, 0.5, 0.6, 1}
    self.textColor = {1, 1, 1, 1}
    
    -- Track hover states
    self.hoveredOption = nil
    
    return self
end

-- Get the currently selected option
function Dropdown:getSelectedOption()
    return self.options[self.selectedIndex]
end

-- Handle mouse press
function Dropdown:mousepressed(x, y)
    -- Check if clicked on the dropdown header
    if x >= self.x and x <= self.x + self.width and
       y >= self.y and y <= self.y + self.height then
        self.open = not self.open
        if self.open then
            -- Reset scroll offset when opening the dropdown
            self.scrollOffset = 0
            
            -- If the current selection is far down the list, scroll to it
            if self.selectedIndex > self.maxVisibleOptions then
                self.scrollOffset = self.selectedIndex - math.ceil(self.maxVisibleOptions / 2)
                self.scrollOffset = math.min(self.scrollOffset, #self.options - self.maxVisibleOptions)
            end
        end
        return true
    end
    
    -- If dropdown is open, check for option clicks
    if self.open then
        -- Calculate how many options to show
        local visibleCount = math.min(#self.options, self.maxVisibleOptions)
        local startIndex = self.scrollOffset + 1
        local endIndex = math.min(startIndex + visibleCount - 1, #self.options)
        
        -- Check each visible option
        for i = startIndex, endIndex do
            local relativeIndex = i - startIndex
            local optionY
            
            -- Calculate option position based on direction
            if self.direction == "up" then
                -- For upward dropdown, options go above the header
                optionY = self.y - (visibleCount - relativeIndex) * self.height
            else
                -- For downward dropdown, options go below the header
                optionY = self.y + self.height + relativeIndex * self.height
            end
            
            if x >= self.x and x <= self.x + self.width and
               y >= optionY and y <= optionY + self.height then
                
                if i ~= self.selectedIndex then
                    self.selectedIndex = i
                    if self.onChange then
                        self.onChange(self.selectedIndex, self.options[i])
                    end
                end
                
                self.open = false
                return true
            end
        end
        
        -- Check for scroll indicators
        if #self.options > self.maxVisibleOptions then
            -- Calculate container dimensions
            local containerY, containerHeight
            if self.direction == "up" then
                containerHeight = visibleCount * self.height
                containerY = self.y - containerHeight
            else
                containerHeight = visibleCount * self.height
                containerY = self.y + self.height
            end
              -- Check if clicked on the scroll container but not on an option
            if x >= self.x and x <= self.x + self.width and
               y >= containerY and y <= containerY + containerHeight then
                -- Clicked in the dropdown area but not on an option
                return true
            end
        end
    end
    
    -- Click outside the dropdown, close it
    self.open = false
    return false
end

-- Update the dropdown
function Dropdown:update(dt)
    local mx, my = love.mouse.getPosition()
    
    -- Reset hovered state
    self.hoveredOption = nil
    
    -- Check if mouse is hovering over any option
    if self.open then
        -- Calculate how many options to show
        local visibleCount = math.min(#self.options, self.maxVisibleOptions)
        local startIndex = self.scrollOffset + 1
        local endIndex = math.min(startIndex + visibleCount - 1, #self.options)
        
        -- Calculate container dimensions for mouse wheel detection
        local containerY, containerHeight
        if self.direction == "up" then
            containerHeight = visibleCount * self.height
            containerY = self.y - containerHeight
        else
            containerHeight = visibleCount * self.height
            containerY = self.y + self.height
        end
        
        -- Check if mouse is over the dropdown container
        local isMouseOverContainer = mx >= self.x and mx <= self.x + self.width and
                                   my >= containerY and my <= containerY + containerHeight
        
        -- Check each visible option
        for i = startIndex, endIndex do
            local relativeIndex = i - startIndex
            local optionY
            
            -- Calculate option position based on direction
            if self.direction == "up" then
                -- For upward dropdown, options go above the header
                optionY = self.y - (visibleCount - relativeIndex) * self.height
            else
                -- For downward dropdown, options go below the header
                optionY = self.y + self.height + relativeIndex * self.height
            end
            
            if mx >= self.x and mx <= self.x + self.width and
               my >= optionY and my <= optionY + self.height then
                self.hoveredOption = i
                break
            end
        end
    end
end

-- Handle mouse wheel for scrolling
function Dropdown:wheelmoved(x, y)
    if self.open and #self.options > self.maxVisibleOptions then
        -- Scroll up or down
        if y > 0 then
            -- Scroll up
            self.scrollOffset = math.max(0, self.scrollOffset - 1)
        elseif y < 0 then
            -- Scroll down
            local maxScroll = #self.options - self.maxVisibleOptions
            self.scrollOffset = math.min(maxScroll, self.scrollOffset + 1)
        end
        return true
    end
    return false
end

-- Draw the dropdown
function Dropdown:draw()
    -- Use Unicode font for all text
    local font = fontManager.getFont(16)
    love.graphics.setFont(font)
    
    -- Draw the label
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.label, self.x, self.y - 20)
    
    -- Draw the dropdown header
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 4, 4)
      -- Draw the selected option
    local selectedOption = self:getSelectedOption()
    if selectedOption then
        love.graphics.setColor(self.textColor)
        local textX = self.x + 10
        local textY = self.y + (self.height - font:getHeight()) / 2
        
        local text = selectedOption.label or selectedOption
        local textWidth = font:getWidth(text)
        
        -- Clip text if it's too long for the dropdown
        if textWidth > self.width - 30 then
            -- Draw ellipsis if text is too long
            love.graphics.setScissor(self.x + 5, self.y, self.width - 30, self.height)
            love.graphics.print(text, textX, textY)
            love.graphics.setScissor()
        else
            love.graphics.print(text, textX, textY)
        end
    end
    
    -- Draw the dropdown arrow
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.polygon(
        "fill", 
        self.x + self.width - 20, self.y + self.height / 2 - 3,
        self.x + self.width - 10, self.y + self.height / 2 - 3,
        self.x + self.width - 15, self.y + self.height / 2 + 3
    )
    
    -- Draw the border
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 4, 4)    -- If the dropdown is open, draw the options
    if self.open then
        -- Calculate how many options to show
        local visibleCount = math.min(#self.options, self.maxVisibleOptions)
        local startIndex = self.scrollOffset + 1
        local endIndex = math.min(startIndex + visibleCount - 1, #self.options)
        
        -- Calculate container dimensions
        local containerY, containerHeight
        
        if self.direction == "up" then
            containerHeight = visibleCount * self.height
            containerY = self.y - containerHeight
        else
            containerHeight = visibleCount * self.height
            containerY = self.y + self.height
        end
        
        -- Draw a container background/shadow to make options stand out
        love.graphics.setColor(0.1, 0.1, 0.15, 0.8) -- Darker shadow
        love.graphics.rectangle("fill", self.x - 4, containerY - 4, self.width + 8, containerHeight + 8, 6, 6)
        
        -- Draw scroll indicators if needed
        if #self.options > self.maxVisibleOptions then
            -- Up indicator (if not at the top)
            if self.scrollOffset > 0 then
                love.graphics.setColor(1, 1, 1, 0.7)
                love.graphics.polygon(
                    "fill",
                    self.x + self.width - 15, containerY + 10,
                    self.x + self.width - 20, containerY + 15,
                    self.x + self.width - 10, containerY + 15
                )
            end
            
            -- Down indicator (if not at the bottom)
            if endIndex < #self.options then
                love.graphics.setColor(1, 1, 1, 0.7)
                love.graphics.polygon(
                    "fill",
                    self.x + self.width - 15, containerY + containerHeight - 10,
                    self.x + self.width - 20, containerY + containerHeight - 15,
                    self.x + self.width - 10, containerY + containerHeight - 15
                )
            end
        end
        
        -- Draw each visible option
        for i = startIndex, endIndex do
            local option = self.options[i]
            local relativeIndex = i - startIndex
            local optionY
            
            -- Calculate option position based on direction
            if self.direction == "up" then
                -- For upward dropdown, options go above the header
                optionY = self.y - (visibleCount - relativeIndex) * self.height
            else
                -- For downward dropdown, options go below the header
                optionY = self.y + self.height + relativeIndex * self.height
            end
            
            -- Draw background (highlight if hovered or selected)
            if i == self.hoveredOption then
                love.graphics.setColor(self.hoverColor)
            elseif i == self.selectedIndex then
                love.graphics.setColor(0.5, 0.5, 0.7, 1)
            else
                love.graphics.setColor(self.backgroundColor)
            end
            
            love.graphics.rectangle("fill", self.x, optionY, self.width, self.height)            -- Draw option text
            love.graphics.setColor(self.textColor)
            local textX = self.x + 10
            
            -- Use Unicode font consistently
            local font = fontManager.getFont(16)
            love.graphics.setFont(font)
            
            local textY = optionY + (self.height - font:getHeight()) / 2
            
            local text = option.label or option
            local textWidth = font:getWidth(text)
            
            -- Clip text if it's too long for the dropdown
            if textWidth > self.width - 20 then
                -- Draw with scissor to clip text
                love.graphics.setScissor(self.x + 5, optionY, self.width - 20, self.height)
                love.graphics.print(text, textX, textY)
                love.graphics.setScissor()
            else
                love.graphics.print(text, textX, textY)
            end
            
            -- Draw option border
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.rectangle("line", self.x, optionY, self.width, self.height)
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return Dropdown
