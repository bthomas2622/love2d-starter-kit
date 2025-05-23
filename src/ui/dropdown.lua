-- Dropdown menu class for settings
local love = require("love")
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local gameConfig = require("src.constants.gameConfig")

local Dropdown = {}
Dropdown.__index = Dropdown

-- Create a new dropdown
function Dropdown.new(x, y, width, height, options, selectedIndex, label, onChange, scale)
    local self = setmetatable({}, Dropdown)
    self.baseX = x
    self.baseY = y
    self.baseWidth = width
    self.baseHeight = height    self.options = options or {}
    self.selectedIndex = selectedIndex or 1
    self.label = label or ""
    self.onChange = onChange
    self.open = false
    self.direction = "down"  -- Default direction: down. Can be "up" or "down"
    self.currentScale = scale or 1  -- Ensure we have a default scale

    -- Actual draw positions and dimensions (relative to scaled canvas)
    self.x = self.baseX
    self.y = self.baseY
    self.width = self.baseWidth
    self.height = self.baseHeight    -- Scrolling support
    self.scrollOffset = 0
    self.maxVisibleOptions = gameConfig.UI.DROPDOWN.MAX_VISIBLE_OPTIONS

    -- Colors
    self.backgroundColor = gameConfig.UI.DROPDOWN.BACKGROUND_COLOR
    self.hoverColor = gameConfig.UI.DROPDOWN.HOVER_COLOR
    self.textColor = gameConfig.UI.DROPDOWN.TEXT_COLOR
    self.hoveredOption = nil
    -- Use fixed font sizes for the virtual canvas - scaling is handled by Love's transform
    self.font = fontManager.getFont(gameConfig.UI.DROPDOWN.FONT_SIZE) -- Standard font size
    self.labelFont = fontManager.getFont(gameConfig.UI.DROPDOWN.LABEL_FONT_SIZE) -- Slightly smaller for label
    self.lastHoveredOption = nil -- Track to play sound on hover change
    
    -- Track main dropdown hover state (for when dropdown is closed)
    self.hovered = false
    self.lastHoverState = false

    return self
end

function Dropdown:getSelectedOption()
    return self.options[self.selectedIndex]
end

function Dropdown:close()
    self.open = false
end

function Dropdown:toggle()
    self.open = not self.open
    if self.open then
        self.scrollOffset = 0
        if self.selectedIndex > self.maxVisibleOptions then
            self.scrollOffset = self.selectedIndex - math.ceil(self.maxVisibleOptions / 2)
            self.scrollOffset = math.min(self.scrollOffset, #self.options - self.maxVisibleOptions)
        end
    end
end

function Dropdown:selectPrevious()
    if self.open and #self.options > 0 then
        local hoveredOrSelected = self.hoveredOption or self.selectedIndex
        local newIndex = hoveredOrSelected - 1
        
        -- Handle wrap-around
        if newIndex < 1 then
            newIndex = #self.options
        end
        
        self.hoveredOption = newIndex
    end
end

function Dropdown:selectNext()
    if self.open and #self.options > 0 then
        local hoveredOrSelected = self.hoveredOption or self.selectedIndex
        local newIndex = hoveredOrSelected + 1
        
        -- Handle wrap-around
        if newIndex > #self.options then
            newIndex = 1
        end
        
        self.hoveredOption = newIndex
    end
end

function Dropdown:selectCurrent()
    if self.open and self.hoveredOption then
        self.selectedIndex = self.hoveredOption
        if self.onChange then
            self.onChange(self.selectedIndex, self.options[self.selectedIndex])
        end
        self.open = false
    end
end

function Dropdown:mousepressed(x, y) -- x, y are transformed
    if x >= self.x and x <= self.x + self.width and
       y >= self.y and y <= self.y + self.height then
        soundManager.playSound("menuSelect")
        self.open = not self.open
        if self.open then
            self.scrollOffset = 0
            if self.selectedIndex > self.maxVisibleOptions then
                self.scrollOffset = self.selectedIndex - math.ceil(self.maxVisibleOptions / 2)
                self.scrollOffset = math.min(self.scrollOffset, #self.options - self.maxVisibleOptions)
            end
        end
        return true
    end

    if self.open then
        local visibleCount = math.min(#self.options, self.maxVisibleOptions)
        local startIndex = self.scrollOffset + 1
        local endIndex = math.min(startIndex + visibleCount - 1, #self.options)
        local optionDrawHeight = self.height -- Use baseHeight for consistent option height

        for i = startIndex, endIndex do
            local relativeIndex = i - startIndex
            local optionY
            if self.direction == "up" then
                optionY = self.y - (visibleCount - relativeIndex) * optionDrawHeight
            else
                optionY = self.y + self.height + relativeIndex * optionDrawHeight
            end
            
            if x >= self.x and x <= self.x + self.width and
               y >= optionY and y <= optionY + optionDrawHeight then
                if i ~= self.selectedIndex then
                    soundManager.playSound("menuSelect")
                    self.selectedIndex = i
                    if self.onChange then
                        self.onChange(self.selectedIndex, self.options[i])
                    end
                end
                self.open = false
                return true
            end
        end

        local containerY, containerHeight
        if self.direction == "up" then
            containerHeight = visibleCount * optionDrawHeight
            containerY = self.y - containerHeight
        else
            containerHeight = visibleCount * optionDrawHeight
            containerY = self.y + self.height
        end
        if x >= self.x and x <= self.x + self.width and
           y >= containerY and y <= containerY + containerHeight then
            return true
        end
    end

    self.open = false
    return false
end

-- Check if dropdown is clicked - wrapper around mousepressed for consistency with Button API
function Dropdown:click(x, y)
    return self:mousepressed(x, y)
end

function Dropdown:update(dt, scale) -- Receive current overall scalefunction Dropdown:update(dt, scale) -- Receive current overall scale
    if scale and self.currentScale ~= scale then
        self.currentScale = scale
    -- Use fixed font sizes for the virtual canvas, don't multiply by scale
        -- The Love2D transform will handle the scaling
        self.font = fontManager.getFont(gameConfig.UI.DROPDOWN.FONT_SIZE)
        self.labelFont = fontManager.getFont(gameConfig.UI.DROPDOWN.LABEL_FONT_SIZE)
        -- Maintain internal scale for detail elements that need additional scaling
    end

    -- Always ensure currentScale is valid
    self.currentScale = self.currentScale or 1

    local mx, my = love.mouse.getPosition() -- Raw screen coordinates
    local s, ox, oy = love.getScreenTransform()
    
    -- Check for hover state on main dropdown (when closed)
    if s and s ~= 0 then
        local tmx = (mx - ox) / s
        local tmy = (my - oy) / s
        
        -- Only check main dropdown hover when closed
        if not self.open then
            local currentlyHovered = tmx >= self.x and tmx <= self.x + self.width and
                                   tmy >= self.y and tmy <= self.y + self.height
            
            -- Play sound when first hovering over dropdown
            if currentlyHovered and not self.lastHoverState then
                soundManager.playSound("menuMove")
            end
            
            -- Update tracking states
            self.lastHoverState = currentlyHovered
            self.hovered = currentlyHovered
        end
    end
    local s, ox, oy, baseW, baseH = love.getScreenTransform()
    local tmx = (mx - ox) / s
    local tmy = (my - oy) / s
    local oldHoveredOption = self.hoveredOption
    self.hoveredOption = nil
    if self.open then
        local visibleCount = math.min(#self.options, self.maxVisibleOptions)
        local startIndex = self.scrollOffset + 1
        local endIndex = math.min(startIndex + visibleCount - 1, #self.options)
        local optionDrawHeight = self.height

        for i = startIndex, endIndex do
            local relativeIndex = i - startIndex
            local optionY
            if self.direction == "up" then
                optionY = self.y - (visibleCount - relativeIndex) * optionDrawHeight
            else
                optionY = self.y + self.height + relativeIndex * optionDrawHeight
            end
            if tmx >= self.x and tmx <= self.x + self.width and
               tmy >= optionY and tmy <= optionY + optionDrawHeight then
                self.hoveredOption = i
                if oldHoveredOption ~= self.hoveredOption then
                    soundManager.playSound("menuMove")
                end
                break
            end
        end
    end
end

function Dropdown:isMouseOver(x, y)
    -- Check if mouse is over the main dropdown area
    if x >= self.x and x <= self.x + self.width and
       y >= self.y and y <= self.y + self.height then
        return true
    end
    
    -- If dropdown is open, also check if mouse is over the dropdown menu area
    if self.open then
        local visibleCount = math.min(#self.options, self.maxVisibleOptions)
        local optionDrawHeight = self.height
        local containerY, containerHeight
        
        if self.direction == "up" then
            containerHeight = visibleCount * optionDrawHeight
            containerY = self.y - containerHeight
        else
            containerHeight = visibleCount * optionDrawHeight
            containerY = self.y + self.height
        end
        
        if x >= self.x and x <= self.x + self.width and
           y >= containerY and y <= containerY + containerHeight then
            return true
        end
    end
    
    return false
end

function Dropdown:wheelmoved(x_delta, y_delta, rawMouseX, rawMouseY)
    if self.open and #self.options > self.maxVisibleOptions then
        -- Check if mouse is over the dropdown options area using transformed coordinates
        local s, ox, oy = love.getScreenTransform()
        
        -- Handle different ways mouse position might be passed
        local mx, my
        if rawMouseY == nil and type(rawMouseX) == "number" then
            -- rawMouseX is actually x_delta and rawMouseY is actually y_delta
            -- Get current mouse position
            mx, my = love.mouse.getPosition()
        else
            mx, my = rawMouseX, rawMouseY
        end
        
        -- Transform raw screen coordinates to virtual canvas coordinates
        local tmx = (mx - ox) / s
        local tmy = (my - oy) / s

        local visibleCount = math.min(#self.options, self.maxVisibleOptions)
        local optionDrawHeight = self.height
        local containerY, containerHeight
        if self.direction == "up" then
            containerHeight = visibleCount * optionDrawHeight
            containerY = self.y - containerHeight
        else
            containerHeight = visibleCount * optionDrawHeight
            containerY = self.y + self.height
        end

        if tmx >= self.x and tmx <= self.x + self.width and
           tmy >= containerY and tmy <= containerY + containerHeight then
            if y_delta > 0 then
                self.scrollOffset = math.max(0, self.scrollOffset - 1)
            elseif y_delta < 0 then
                local maxScroll = #self.options - self.maxVisibleOptions
                self.scrollOffset = math.min(maxScroll, self.scrollOffset + 1)
            end
            return true -- Event handled
        end
    end
    return false -- Event not handled
end

-- Add keyboard navigation support for dropdown
function Dropdown:keypressed(key)
    if not self.open then return end
    if key == "up" then
        self:selectPrevious()
    elseif key == "down" then
        self:selectNext()
    elseif key == "return" or key == "kpenter" then
        self:selectCurrent()
    elseif key == "escape" then
        self:close()
    end
end

function Dropdown:draw()
    -- Get the current scale from love.getScreenTransform
    local scale = self.currentScale or 1 -- Default to 1 if nil
    local s, ox, oy, bw, bh = love.getScreenTransform()
    if s then scale = s end
    
    -- Ensure currentScale is always valid
    self.currentScale = self.currentScale or 1
    
    -- Draw the label above the dropdown (not affected by scissor)
    love.graphics.setFont(self.labelFont)
    love.graphics.setColor(self.textColor)
    love.graphics.print(self.label, self.x, self.y - self.labelFont:getHeight() - (4 * self.currentScale))    -- Draw the dropdown background
    love.graphics.setColor(self.backgroundColor)
    local cornerRadius = 4 * (self.currentScale or 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, cornerRadius, cornerRadius)

    -- Draw the selected option text
    love.graphics.setFont(self.font)
    local selectedOption = self:getSelectedOption()    if selectedOption then
        love.graphics.setColor(self.textColor)
        local safeScale = self.currentScale or 1
        local textX = self.x + (10 * safeScale)
        local textY = self.y + (self.height - self.font:getHeight()) / 2
        local text = selectedOption.label or selectedOption
        
        -- Calculate scissor rectangle in screen coordinates properly
        local cx, cy = love.graphics.transformPoint(self.x, self.y)
        local cw = self.width * scale
        local ch = self.height * scale
        
        -- Apply scissor in screen coordinates, accounting for padding
        love.graphics.setScissor(
            cx + (5 * safeScale) * scale, 
            cy, 
            cw - (30 * safeScale) * scale, 
            ch
        )
        love.graphics.print(text, textX, textY)
        love.graphics.setScissor()
    end    love.graphics.setColor(1, 1, 1, 0.8)
    local safeScale = self.currentScale or 1
    local arrowSize = 6 * safeScale
    love.graphics.polygon(
        "fill",
        self.x + self.width - (20 * safeScale), self.y + self.height / 2 - arrowSize / 2,
        self.x + self.width - (10 * safeScale), self.y + self.height / 2 - arrowSize / 2,
        self.x + self.width - (15 * safeScale), self.y + self.height / 2 + arrowSize / 2
    )

    love.graphics.setLineWidth(1 * safeScale)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 4 * safeScale, 4 * safeScale)
    love.graphics.setLineWidth(1)

    if self.open then
        -- Save current scissor state
        local prevScissor = {love.graphics.getScissor()}
        -- Clear scissor to draw over everything
        love.graphics.setScissor()
        
        -- Add a semi-transparent overlay over the entire screen
        love.graphics.setColor(0.1, 0.1, 0.15, 0.5)
        love.graphics.rectangle("fill", 0, 0, bw, bh)
        
        local visibleCount = math.min(#self.options, self.maxVisibleOptions)
        local startIndex = self.scrollOffset + 1
        local endIndex = math.min(startIndex + visibleCount - 1, #self.options)
        local optionDrawHeight = self.height

        local containerY, containerHeight
        if self.direction == "up" then
            containerHeight = visibleCount * optionDrawHeight
            containerY = self.y - containerHeight
        else
            containerHeight = visibleCount * optionDrawHeight
            containerY = self.y + self.height
        end        -- Draw dropdown options container with more visible background
        love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
        local safeScale = self.currentScale or 1
        love.graphics.rectangle("fill", self.x - (2 * safeScale), containerY - (2 * safeScale), 
                              self.width + (4 * safeScale), containerHeight + (4 * safeScale), 
                              6 * safeScale, 6 * safeScale)
                                -- Add a visible border to make the dropdown stand out
        love.graphics.setColor(0.6, 0.6, 0.8, 0.8)
        local safeScale = self.currentScale or 1
        love.graphics.setLineWidth(2 * safeScale)
        love.graphics.rectangle("line", self.x - (2 * safeScale), containerY - (2 * safeScale), 
                              self.width + (4 * safeScale), containerHeight + (4 * safeScale), 
                              6 * safeScale, 6 * safeScale)
        love.graphics.setLineWidth(1)

        for i = startIndex, endIndex do
            local option = self.options[i]
            local relativeIndex = i - startIndex
            local optionY
            if self.direction == "up" then
                optionY = self.y - (visibleCount - relativeIndex) * optionDrawHeight
            else
                optionY = self.y + self.height + relativeIndex * optionDrawHeight
            end

            if i == self.hoveredOption then
                love.graphics.setColor(self.hoverColor)
            elseif i == self.selectedIndex then
                love.graphics.setColor(0.5, 0.5, 0.7, 1) -- Selected color
            else
                love.graphics.setColor(self.backgroundColor)
            end
            love.graphics.rectangle("fill", self.x, optionY, self.width, optionDrawHeight)
              love.graphics.setColor(self.textColor)
            love.graphics.setFont(self.font)
            local optText = option.label or option
            local safeScale = self.currentScale or 1
            local optTextX = self.x + (10 * safeScale)
            local optTextY = optionY + (optionDrawHeight - self.font:getHeight()) / 2
            
            -- Draw option text without scissor since we're handling overlap differently
            love.graphics.print(optText, optTextX, optTextY)
        end
        
        -- Restore previous scissor if there was one
        if prevScissor[1] then
            -- Use table.unpack for Lua 5.4 compatibility
            love.graphics.setScissor(table.unpack(prevScissor))
        else
            love.graphics.setScissor()
        end
    end
    love.graphics.setColor(1,1,1,1) -- Reset color
end

return Dropdown
