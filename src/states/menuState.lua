-- Main Menu State
local love = require("love")
local Button = require "src.ui.button"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"

local menuState = {}

local buttons = {}
local titleFont = nil

-- Store virtual canvas dimensions and current GUI scale
local virtualWidth = 1280 -- Default, will be updated from init/resize
local virtualHeight = 720 -- Default, will be updated from init/resize
local currentGuiScale = 1 -- Default, will be updated

-- Removed currentOffsetX, currentOffsetY as they are not used for layout within the virtual canvas here
-- baseScreenWidth and baseScreenHeight are replaced by virtualWidth and virtualHeight

local function recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    -- Always get the actual virtual canvas dimensions from the main transform
    -- This ensures consistent dimensions across all states
    local _, _, _, baseWidth, baseHeight = love.getScreenTransform()
    virtualWidth = baseWidth or vWidth  -- Fallback to parameter if function fails
    virtualHeight = baseHeight or vHeight -- Fallback to parameter if function fails
    currentGuiScale = guiScale
    
    -- Load fonts for the virtual canvas resolution
    titleFont = fontManager.getFont(40) -- Font size for the virtual canvas

    -- Calculate button dimensions and positions on the virtual canvas
    local centerX = virtualWidth / 2
    local centerY = virtualHeight / 2
    local buttonWidth = 200 -- Width on the virtual canvas
    local buttonHeight = 50 -- Height on the virtual canvas
    local buttonSpacing = 20 -- Spacing on the virtual canvas

    buttons = {}

    -- Play button
    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2,
        centerY - buttonHeight - buttonSpacing,
        buttonWidth,
        buttonHeight,
        gameState.getText("play"),
        function()
            love.switchState("play")
        end,
        currentGuiScale -- Pass the GUI scale for button's internal detail scaling
    ))

    -- Settings button
    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2,
        centerY,
        buttonWidth,
        buttonHeight,
        gameState.getText("settings"),
        function()
            love.switchState("settings")
        end,
        currentGuiScale -- Pass the GUI scale
    ))

    -- Quit button
    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2,
        centerY + buttonHeight + buttonSpacing,
        buttonWidth,
        buttonHeight,
        gameState.getText("quit"),
        function()
            love.event.quit()
        end,
        currentGuiScale -- Pass the GUI scale
    ))
end

-- init receives: virtualWidth, virtualHeight, guiScale, guiOffsetX, guiOffsetY
function menuState.init(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    soundManager.playMusic("menu") -- Start playing menu music when entering the menu state
end

-- resize receives: virtualWidth, virtualHeight, guiScale, guiOffsetX, guiOffsetY
function menuState.resize(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    -- Always use the main virtual canvas dimensions to ensure consistency
    local _, _, _, baseWidth, baseHeight = love.getScreenTransform()
    virtualWidth = baseWidth
    virtualHeight = baseHeight
    recalculateLayout(virtualWidth, virtualHeight, guiScale, guiOffsetX, guiOffsetY)
end

-- update receives dt and the current guiScale from main.lua
function menuState.update(dt, guiScale)
    -- Update buttons, pass the guiScale for their internal logic (e.g., hover effects, animations)
    for _, button in ipairs(buttons) do
        button:update(dt, guiScale)
    end
end

function menuState.draw()
    -- All drawing is now on the virtual canvas (e.g., 800x450)
    -- main.lua handles scaling this virtual canvas to the screen.    -- Draw the game title
    love.graphics.setFont(titleFont) -- titleFont is already sized for the virtual canvas
    local title = "Love2D Game"
    local titleWidth = titleFont and titleFont:getWidth(title) or 0 -- Width on the virtual canvas

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        title,
        virtualWidth / 2 - titleWidth / 2, -- Position on the virtual canvas
        virtualHeight * 0.2 -- Adjusted Y position to be relative to virtual height
    )

    -- Draw buttons
    for _, button in ipairs(buttons) do
        button:draw() -- Buttons draw themselves on the virtual canvas
    end
end

function menuState.mousepressed(x, y, button)
    -- x and y are already transformed to virtual canvas coordinates by main.lua
    if button == 1 then  -- Left mouse button
        for _, btn in ipairs(buttons) do
            if btn:click(x, y) then return end -- If click is handled, no need to check others
        end
    end
end

return menuState
