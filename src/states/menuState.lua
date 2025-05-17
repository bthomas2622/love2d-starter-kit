-- Main Menu State
local Button = require "src.states.button"
local gameState = require "src.states.gameState"
local fontManager = require "src.fontManager"

local menuState = {}

local buttons = {}
local titleFont = nil
local buttonFont = nil

function menuState.init()
    -- Load fonts with Unicode support
    titleFont = fontManager.getFont(40)
    buttonFont = fontManager.getFont(20)
    
    -- Calculate button dimensions and positions
    local centerX = love.graphics.getWidth() / 2
    local centerY = love.graphics.getHeight() / 2
    local buttonWidth = 200
    local buttonHeight = 50
    local buttonSpacing = 20
    
    -- Create buttons
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
        end
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
        end
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
        end
    ))
end

function menuState.update(dt)
    -- Update buttons
    for _, button in ipairs(buttons) do
        button:update(dt)
    end
end

function menuState.draw()
    -- Clear the screen with a nice background
    love.graphics.setBackgroundColor(0.2, 0.2, 0.3)
    
    -- Draw the game title
    love.graphics.setFont(titleFont)
    local title = "Love2D Game"
    local titleWidth = titleFont:getWidth(title)
    local titleHeight = titleFont:getHeight()
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        title, 
        love.graphics.getWidth() / 2 - titleWidth / 2,
        100
    )
    
    -- Draw buttons
    love.graphics.setFont(buttonFont)
    for _, button in ipairs(buttons) do
        button:draw()
    end
end

function menuState.mousepressed(x, y, button)
    if button == 1 then  -- Left mouse button
        for _, btn in ipairs(buttons) do
            btn:click(x, y)
        end
    end
end

return menuState
