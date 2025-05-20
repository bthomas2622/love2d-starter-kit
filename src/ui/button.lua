-- Button class for the menus
local love = require "love"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"

local Button = {}
Button.__index = Button

-- Create a new button
-- x, y, width, height are on the virtual canvas (e.g., 800x450)
-- guiScale is the overall scale factor from main.lua, used for fine details
function Button.new(x, y, width, height, text, callback, guiScale)
    local self = setmetatable({}, Button)
    self.x = x         -- Position on the virtual canvas
    self.y = y         -- Position on the virtual canvas
    self.width = width -- Width on the virtual canvas
    self.height = height -- Height on the virtual canvas
    self.text = text
    self.callback = callback
    self.hovered = false
    self.guiScale = guiScale or 1 -- Store the GUI scale for detail scaling

    -- Default colors
    self.normalColor = {0.4, 0.4, 0.5, 1}
    self.hoverColor = {0.5, 0.5, 0.6, 1}
    self.textColor = {1, 1, 1, 1}    -- Font sized for the virtual canvas (e.g., 16pt for an 800x450 canvas)
    -- It will be scaled visually by main.lua's global transform.
    self.font = fontManager.getFont(16) -- Base font size for virtual canvas
    self.wasHoveredLastFrame = false -- Track hover state changes for sound effects

    return self
end

-- Update the button state
function Button:update(dt, guiScale) -- Receive current overall guiScale
    if guiScale and self.guiScale ~= guiScale then
        self.guiScale = guiScale
        -- Font is already sized for the virtual canvas, no need to change it based on guiScale here.
        -- self.font = fontManager.getFont(math.floor(16 * self.guiScale)) -- This was incorrect
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
        virtualMouseY = (rawMouseY - offsetY) / currentMainScale    else
        -- If scale is 0 or nil, cannot accurately determine hover, assume not hovered.
        self.hovered = false
        return
    end
    
    -- Check hover against button's virtual canvas coordinates
    local previousHoverState = self.hovered
    self.hovered = virtualMouseX >= self.x and virtualMouseX <= self.x + self.width and
                   virtualMouseY >= self.y and virtualMouseY <= self.y + self.height
    
    -- Play menu move sound when hover state changes
    if not previousHoverState and self.hovered then
        soundManager.playSound("menuMove")
    end
end

-- Draw the button
function Button:draw()
    -- self.x, self.y, self.width, self.height are coordinates on the virtual canvas.
    -- main.lua's transform handles scaling this to the screen.

    local cornerRadius = 8 * self.guiScale -- Scale corner radius based on overall GUI scale
    local lineWidth = 1 * self.guiScale   -- Scale line width similarly
    if lineWidth < 1 then lineWidth = 1 end -- Ensure line width is at least 1 pixel on screen

    -- Draw the button background
    love.graphics.setColor(self.hovered and self.hoverColor or self.normalColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, cornerRadius, cornerRadius)

    -- Draw the button border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setLineWidth(lineWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, cornerRadius, cornerRadius)
    love.graphics.setLineWidth(1) -- Reset line width to default for other drawing operations

    -- Draw the text
    love.graphics.setColor(self.textColor)
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
    -- virtualX, virtualY are already transformed coordinates from the state (originally from main.lua)
    if virtualX >= self.x and virtualX <= self.x + self.width and
       virtualY >= self.y and virtualY <= self.y + self.height then
        soundManager.playSound("menuSelect")
        if self.callback then
            self.callback()
        end
        return true
    end
    return false
end

return Button
