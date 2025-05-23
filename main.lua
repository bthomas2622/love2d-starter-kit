-- Main entry point for our Love2D game
local love = require("love")
local gameConfig = require "src.constants.gameConfig"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"

-- Variables to store the current state
local currentState = nil
local states = {}

-- Screen and scaling variables
local targetAspectRatio = gameConfig.TARGET_ASPECT_RATIO
local baseWidth = gameConfig.VIRTUAL_WIDTH
local baseHeight = gameConfig.VIRTUAL_HEIGHT

local scale = 1
local offsetX = 0
local offsetY = 0

-- Function to update scaling and offset based on window size
function love.updateScreenTransform(w, h)
    local windowAspectRatio = w / h

    if windowAspectRatio > targetAspectRatio then
        -- Window is wider than target (e.g., 16:9 content on a 21:9 screen)
        -- Fit to height, letterbox horizontally
        scale = h / baseHeight
        offsetX = (w - (baseWidth * scale)) / 2
        offsetY = 0
    else
        -- Window is taller or equal to target (e.g., 16:9 content on a 4:3 screen)
        -- Fit to width, letterbox vertically
        scale = w / baseWidth
        offsetX = 0
        offsetY = (h - (baseHeight * scale)) / 2
    end
    
    -- Make sure the screen transform is accessible globally via this function
    -- This ensures all states get the same consistent transform values
    love.getScreenTransform = function()
        return scale, offsetX, offsetY, baseWidth, baseHeight
    end
end

-- Local alias for updateScreenTransform for internal use
local updateScreenTransform = love.updateScreenTransform


function love.load()
    love.window.setTitle(gameConfig.WINDOW.TITLE)
    
    -- Initialize with the user's stored settings if available
    gameState.load()
    
    -- Set the window mode using the loaded settings
    love.window.setMode(
        gameState.settings.screenSize.width, 
        gameState.settings.screenSize.height, 
        {resizable=gameConfig.WINDOW.RESIZABLE, minwidth=gameConfig.WINDOW.MIN_WIDTH, minheight=gameConfig.WINDOW.MIN_HEIGHT}
    )
    
    fontManager.init()
    soundManager.load()

    states.menu = require "src.states.menuState"
    states.play = require "src.states.playState"
    states.settings = require "src.states.settingsState"
    states.controls = require "src.states.controlsState"
    
    -- Initialize input manager after states are loaded
    local inputManager = require "src.utils.inputManager"
    inputManager.init()

    -- Update transform before switching state so the initial layout is correct
    updateScreenTransform(love.graphics.getWidth(), love.graphics.getHeight())
    
    switchState("menu")
end

function love.resize(w, h)
    updateScreenTransform(w, h)
    if currentState and currentState.resize then
        -- Make sure we're using the updated transform values
        local s, ox, oy, bw, bh = love.getScreenTransform()
        -- Pass the virtual width/height and the actual scale, offsetX, offsetY
        currentState.resize(bw, bh, s, ox, oy)
    end
end

function love.update(dt)
    if currentState and currentState.update then
        -- Pass dt and the current scale. States will use the scale for their internal logic if needed.
        currentState.update(dt, scale)
    end
end

function love.draw()
    -- Clear the entire window with black for letterboxing/pillarboxing
    love.graphics.clear(0, 0, 0, 1)

    love.graphics.push()
    -- Translate and scale to draw the game content within the letterboxed area
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    -- Now all drawing operations are relative to the baseWidth x baseHeight virtual canvas
    if currentState and currentState.draw then
        currentState.draw()
    end

    love.graphics.pop()
end

-- Helper function to transform mouse coordinates from screen to virtual canvas space
local function transformMousePosition(screenX, screenY)
    if scale == 0 then return screenX, screenY end -- Avoid division by zero if scale is not ready
    local virtualX = (screenX - offsetX) / scale
    local virtualY = (screenY - offsetY) / scale
    return virtualX, virtualY
end

function love.mousepressed(x, y, button)
    local virtualX, virtualY = transformMousePosition(x, y)
    if currentState and currentState.mousepressed then
        currentState.mousepressed(virtualX, virtualY, button)
    end
end

function love.mousereleased(x, y, button)
    local virtualX, virtualY = transformMousePosition(x, y)
    if currentState and currentState.mousereleased then
        currentState.mousereleased(virtualX, virtualY, button)
    end
end

function love.mousemoved(x, y, dx, dy)
    local virtualX, virtualY = transformMousePosition(x, y)
    if currentState and currentState.mousemoved then
        currentState.mousemoved(virtualX, virtualY, dx, dy)
    end
end

-- Define currentStateName before using it in the keypressed function
local currentStateName = "menu"

function love.keypressed(key)
    if key == "escape" and currentStateName == "play" then
        -- Special handling for escape key in play state (pause game)
        love.switchState("menu")
        return
    end
    
    if currentState and currentState.keypressed then
        currentState.keypressed(key)
    end
end

function love.gamepadpressed(joystick, button)
    if currentState and currentState.gamepadpressed then
        currentState.gamepadpressed(joystick, button)
    end
end

function love.wheelmoved(x_delta, y_delta) -- x_delta, y_delta are scroll amounts
    if currentState and currentState.wheelmoved then
        -- Get the current mouse position and pass it to the wheelmoved handler
        local mx, my = love.mouse.getPosition()
        local virtualX, virtualY = transformMousePosition(mx, my)
        currentState.wheelmoved(x_delta, y_delta, virtualX, virtualY)
    end
end

function switchState(stateName)
    local oldStateName = currentStateName
    
    if states[stateName] then
        -- Handle music transitions
        if (stateName == "menu" or stateName == "settings") and (oldStateName ~= "menu" and oldStateName ~= "settings") then
            -- Switching to a menu state from a non-menu state, play menu music
            soundManager.playMusic("menu")
        elseif stateName == "play" and (oldStateName == "menu" or oldStateName == "settings") then
            -- Switching from menu to gameplay, stop menu music
            soundManager.stopMusic()
        end

        -- If we're going back to the menu from settings, play the back sound
        if stateName == "menu" and oldStateName == "settings" then
            soundManager.playSound("menuBack")
        end
        
        currentState = states[stateName]
        currentStateName = stateName
        if currentState.init then
            -- Initialize state with virtual dimensions and current transform
            currentState.init(baseWidth, baseHeight, scale, offsetX, offsetY)
        end
    else
        error("No state with name: " .. stateName)
    end
end

function getCurrentStateName()
    return currentStateName
end

love.switchState = switchState
love.getCurrentStateName = getCurrentStateName

-- Note: love.getScreenTransform is already defined in updateScreenTransform
-- This ensures consistent values throughout the application
-- The function returns: scale, offsetX, offsetY, baseWidth, baseHeight
