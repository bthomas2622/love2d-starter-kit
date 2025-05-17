-- Play State
local Button = require "src.states.button"
local gameState = require "src.states.gameState"
local fontManager = require "src.fontManager"

local playState = {}

local buttons = {}

function playState.init()
    -- Clear previous buttons
    buttons = {}
    
    -- Create back button
    local buttonWidth = 150
    local buttonHeight = 40
    
    table.insert(buttons, Button.new(
        20,
        20,
        buttonWidth,
        buttonHeight,
        gameState.getText("back"),
        function()
            love.switchState("menu")
        end
    ))
end

function playState.update(dt)
    -- Update buttons
    for _, button in ipairs(buttons) do
        button:update(dt)
    end
    
    -- Here you would put your game logic
end

function playState.draw()
    -- Clear the screen with a different background
    love.graphics.setBackgroundColor(0.1, 0.3, 0.2)
    
    -- Draw a simple message
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        "This is where your game would go!", 
        love.graphics.getWidth() / 2 - 100, 
        love.graphics.getHeight() / 2
    )
    
    -- Draw buttons
    for _, button in ipairs(buttons) do
        button:draw()
    end
end

function playState.mousepressed(x, y, button)
    if button == 1 then  -- Left mouse button
        for _, btn in ipairs(buttons) do
            btn:click(x, y)
        end
    end
end

return playState
