-- Main entry point for our Love2D game
local gameState = require "src.states.gameState"
local fontManager = require "src.fontManager"

-- Variables to store the current state
local currentState = nil
local states = {}

function love.load()
    -- Set default settings
    love.window.setTitle("My Love2D Game")
    love.window.setMode(800, 600, {resizable=true})
    
    -- Initialize the font manager
    fontManager.init()
    
    -- Load the game states
    states.menu = require "src.states.menuState"
    states.play = require "src.states.playState"
    states.settings = require "src.states.settingsState"
    
    -- Set the initial state to menu
    switchState("menu")
    
    -- Load game settings
    gameState.load()
end

function love.update(dt)
    if currentState and currentState.update then
        currentState.update(dt)
    end
end

function love.draw()
    if currentState and currentState.draw then
        currentState.draw()
    end
end

function love.mousepressed(x, y, button)
    if currentState and currentState.mousepressed then
        currentState.mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if currentState and currentState.mousereleased then
        currentState.mousereleased(x, y, button)
    end
end

function love.keypressed(key)
    if currentState and currentState.keypressed then
        currentState.keypressed(key)
    end
    
    -- Escape key to quit
    if key == "escape" then
        love.event.quit()
    end
end

function love.wheelmoved(x, y)
    if currentState and currentState.wheelmoved then
        currentState.wheelmoved(x, y)
    end
end

-- Keep track of the current state name
local currentStateName = "menu"

-- Function to switch between game states
function switchState(stateName)
    if states[stateName] then
        currentState = states[stateName]
        -- Store the current state name
        currentStateName = stateName
        if currentState.init then
            currentState.init()
        end
    else
        error("No state with name: " .. stateName)
    end
end

-- Function to get the current state name
function getCurrentStateName()
    return currentStateName
end

-- Make the functions globally accessible
love.switchState = switchState
love.getCurrentStateName = getCurrentStateName
