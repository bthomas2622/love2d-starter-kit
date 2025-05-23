-- Button class for the menus
local love = require "love"
local gameConfig = require "src.constants.gameConfig"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"

local Button = {}
Button.__index = Button

-- Create a new button
-- x, y, width, height are on the virtual canvas (e.g., 800x450)
-- guiScale is the overall scale factor from main.lua, used for fine details
function Button.new(x, y, width, height, text, callback, guiScale, playSounds)
    local self = setmetatable({}, Button)
    self.x = x         -- Position on the virtual canvas
    self.y = y         -- Position on the virtual canvas
    self.width = width -- Width on the virtual canvas
    self.height = height -- Height on the virtual canvas
    self.text = text
    self.callback = callback
    self.hovered = false
    self.disabled = false -- Add disabled state
    self.guiScale = guiScale or 1 -- Store the GUI scale for detail scaling
    self.playSounds = playSounds -- If true (default), play sounds on hover/click. If false, no sounds.
    if self.playSounds == nil then self.playSounds = true end -- Default to true if not specified    -- Default colors
    self.normalColor = gameConfig.UI.BUTTON.NORMAL_COLOR
    self.hoverColor = gameConfig.UI.BUTTON.HOVER_COLOR
    self.disabledColor = gameConfig.UI.BUTTON.DISABLED_COLOR
    self.textColor = gameConfig.UI.BUTTON.TEXT_COLOR
    self.disabledTextColor = gameConfig.UI.BUTTON.DISABLED_TEXT_COLOR    -- Font sized for the virtual canvas (e.g., 16pt for an 800x450 canvas)
    -- It will be scaled visually by main.lua's global transform.
    self.font = fontManager.getFont(gameConfig.UI.BUTTON.FONT_SIZE) -- Base font size for virtual canvas
    
    -- Track the last update's hover state to only play sound once
    self.lastHoverState = false
    
    return self
end

-- Update the button state
function Button:update(dt, guiScale) -- Receive current overall guiScale
    if guiScale and self.guiScale ~= guiScale then
        self.guiScale = guiScale
        -- Font is already sized for the virtual canvas, no need to change it based on guiScale here.
    end

    -- If disabled, don't process hover effects
    if self.disabled then
        self.hovered = false
        return
    end

    -- Mouse position for hover detection.
    -- love.mouse.getPosition() returns raw screen coordinates.
    -- We need to transform them to the virtual canvas space.
    local rawMouseX, rawMouseY = love.mouse.getPosition()
    local currentMainScale, offsetX, offsetY = love.getScreenTransform()

    local virtualMouseX = rawMouseX
    local virtualMouseY = rawMouseY

    if currentMainScale and currentMainScale ~= 0 then -- Prevent division by zero
        virtualMouseX = (rawMouseX - offsetX) / currentMainScale
        virtualMouseY = (rawMouseY - offsetY) / currentMainScale
    else
        -- If scale is 0 or nil, cannot accurately determine hover, assume not hovered.
        self.hovered = false
        return
    end
    
    -- Calculate the current hover state based on mouse position
    local currentlyHovered = virtualMouseX >= self.x and virtualMouseX <= self.x + self.width and
                           virtualMouseY >= self.y and virtualMouseY <= self.y + self.height
    
    -- Only play sound when the button transitions from not hovered to hovered
    if currentlyHovered and not self.lastHoverState and self.playSounds then
        soundManager.playSound("menuMove")
    end
    
    -- Update tracking states for next frame
    self.lastHoverState = currentlyHovered
    self.hovered = currentlyHovered
end

-- Draw the button
function Button:draw()
    -- self.x, self.y, self.width, self.height are coordinates on the virtual canvas.
    -- main.lua's transform handles scaling this to the screen.    local cornerRadius = gameConfig.UI.BUTTON.CORNER_RADIUS * self.guiScale -- Scale corner radius based on overall GUI scale
    local lineWidth = gameConfig.UI.BUTTON.BORDER_WIDTH * self.guiScale   -- Scale line width similarly
    if lineWidth < 1 then lineWidth = 1 end -- Ensure line width is at least 1 pixel on screen

    -- Draw the button background
    if self.disabled then
        love.graphics.setColor(self.disabledColor)
    else
        love.graphics.setColor(self.hovered and self.hoverColor or self.normalColor)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, gameConfig.UI.BUTTON.CORNER_RADIUS * self.guiScale, gameConfig.UI.BUTTON.CORNER_RADIUS * self.guiScale)    -- Draw the button border
    love.graphics.setColor(self.disabled and gameConfig.UI.BUTTON.DISABLED_BORDER_COLOR or gameConfig.UI.BUTTON.BORDER_COLOR)
    love.graphics.setLineWidth(lineWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, gameConfig.UI.BUTTON.CORNER_RADIUS * self.guiScale, gameConfig.UI.BUTTON.CORNER_RADIUS * self.guiScale)
    love.graphics.setLineWidth(1) -- Reset line width to default for other drawing operations

    -- Draw the text
    love.graphics.setColor(self.disabled and self.disabledTextColor or self.textColor)
    love.graphics.setFont(self.font) -- self.font is already sized for the virtual canvas

    local textWidth = self.font:getWidth(self.text)   -- Width on virtual canvas
    local textHeight = self.font:getHeight() -- Height on virtual canvas

    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - textHeight) / 2

    love.graphics.print(self.text, textX, textY)

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Check if button is clicked
function Button:click(virtualX, virtualY)
    -- virtualX, virtualY are optional and used for hit detection
    -- If they're not provided, the button is being activated directly (e.g., by keyboard/gamepad)
    if not self.disabled then
        -- If coordinates are provided, check if the click is within the button boundaries
        if virtualX and virtualY then
            if not (virtualX >= self.x and virtualX <= self.x + self.width and
                   virtualY >= self.y and virtualY <= self.y + self.height) then
                return false
            end
        end
        
        -- If we're here, either the coords are within the button or none were provided
        if self.playSounds then
            soundManager.playSound("menuSelect")
        end
        if self.callback then
            self.callback()
        end
        return true
    end
    return false
end

return Button

