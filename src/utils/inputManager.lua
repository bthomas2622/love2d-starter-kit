-- Input manager to handle keyboard and gamepad input
local love = require("love")
local gameState = require "src.states.gameState"
local soundManager = require "src.utils.soundManager"
local gameConfig = require("src.constants.gameConfig")

local inputManager = {}

-- Default key bindings
local defaultKeyBindings = gameConfig.DEFAULT_KEY_BINDINGS

-- Current key bindings - will be loaded from settings
inputManager.keyBindings = {
    keyboard = {},
    gamepad = {}
}

-- State tracking
local lastKeyboardState = {}
local lastGamepadState = {}
local currentGamepad = nil
local lastMenuAction = 0
local menuRepeatDelay = gameConfig.INPUT.MENU_REPEAT_DELAY -- Time in seconds before menu navigation repeats when holding a direction

-- Initialize input manager
function inputManager.init()
    -- Reset the states
    lastKeyboardState = {}
    lastGamepadState = {}
    
    -- Load key bindings from settings or use defaults
    if gameState.settings.keyBindings then
        -- Create a deep copy of settings to avoid reference issues
        inputManager.keyBindings = {
            keyboard = {},
            gamepad = {}
        }
        
        -- Copy all keyboard bindings
        for action, key in pairs(gameState.settings.keyBindings.keyboard) do
            inputManager.keyBindings.keyboard[action] = key
        end
        
        -- Copy all gamepad bindings
        for action, button in pairs(gameState.settings.keyBindings.gamepad) do
            inputManager.keyBindings.gamepad[action] = button
        end
    else
        -- Create a deep copy of default key bindings
        inputManager.keyBindings = {
            keyboard = {},
            gamepad = {}
        }
        
        -- Copy all keyboard bindings
        for action, key in pairs(defaultKeyBindings.keyboard) do
            inputManager.keyBindings.keyboard[action] = key
        end
        
        -- Copy all gamepad bindings
        for action, button in pairs(defaultKeyBindings.gamepad) do
            inputManager.keyBindings.gamepad[action] = button
        end
        
        -- Save the deep-copied defaults
        gameState.settings.keyBindings = inputManager.keyBindings
        gameState.save()
    end
    
    -- Initialize gamepad if available
    if love.joystick then
        local joysticks = love.joystick.getJoysticks()
        if #joysticks > 0 then
            currentGamepad = joysticks[1]
            print("Gamepad connected: " .. currentGamepad:getName())
        end
    end
end

-- Update input state
function inputManager.update(dt)
    -- Update the repeat timer
    if lastMenuAction > 0 then
        lastMenuAction = lastMenuAction - dt
    end
end

-- Check if an action was just pressed (not held)
function inputManager.isActionJustPressed(action)
    -- Check keyboard first
    local keyboardBinding = inputManager.keyBindings.keyboard[action]
    if keyboardBinding and love.keyboard.isDown(keyboardBinding) and not lastKeyboardState[action] then
        lastKeyboardState[action] = true
        return true
    elseif keyboardBinding and not love.keyboard.isDown(keyboardBinding) then
        lastKeyboardState[action] = false
    end
    
    -- Then check gamepad if available
    if currentGamepad then
        local gamepadBinding = inputManager.keyBindings.gamepad[action]
        if gamepadBinding then
            local isDown = false
            
            -- Handle different types of gamepad inputs
            if gamepadBinding:sub(1, 2) == "dp" then
                -- D-pad buttons
                isDown = currentGamepad:isGamepadDown(gamepadBinding)            elseif gamepadBinding == "leftstick_up" then
                isDown = currentGamepad:getGamepadAxis("lefty") < -gameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_down" then
                isDown = currentGamepad:getGamepadAxis("lefty") > gameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_left" then
                isDown = currentGamepad:getGamepadAxis("leftx") < -gameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_right" then
                isDown = currentGamepad:getGamepadAxis("leftx") > gameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            else
                -- Regular buttons
                isDown = currentGamepad:isGamepadDown(gamepadBinding)
            end
            
            if isDown and not lastGamepadState[action] then
                lastGamepadState[action] = true
                return true
            elseif not isDown then
                lastGamepadState[action] = false
            end
        end
    end
    
    return false
end

-- Check if an action is pressed or held with menu-style repeat
function inputManager.isActionPressedForMenu(action)
    local isPressed = false
    
    -- Check keyboard
    local keyboardBinding = inputManager.keyBindings.keyboard[action]
    if keyboardBinding and love.keyboard.isDown(keyboardBinding) then
        isPressed = true
    end
    
    -- Check gamepad if available
    if not isPressed and currentGamepad then
        local gamepadBinding = inputManager.keyBindings.gamepad[action]
        if gamepadBinding then
            -- Handle different types of gamepad inputs
            if gamepadBinding:sub(1, 2) == "dp" then
                isPressed = currentGamepad:isGamepadDown(gamepadBinding)            elseif gamepadBinding == "leftstick_up" then
                isPressed = currentGamepad:getGamepadAxis("lefty") < -gameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_down" then
                isPressed = currentGamepad:getGamepadAxis("lefty") > gameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_left" then
                isPressed = currentGamepad:getGamepadAxis("leftx") < -gameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            elseif gamepadBinding == "leftstick_right" then
                isPressed = currentGamepad:getGamepadAxis("leftx") > gameConfig.INPUT.GAMEPAD_AXIS_THRESHOLD
            else
                isPressed = currentGamepad:isGamepadDown(gamepadBinding)
            end
        end
    end
    
    -- Handle menu repeat timing
    if isPressed and lastMenuAction <= 0 then
        lastMenuAction = menuRepeatDelay
        return true
    end
    
    return false
end

-- Check if any gamepad is connected
function inputManager.isGamepadConnected()
    return currentGamepad ~= nil
end

-- Get a text representation of a key binding
function inputManager.getBindingText(device, action)
    -- Always get the most up-to-date binding from the keyBindings table
    local binding = inputManager.keyBindings[device][action]
    
    -- Debug output to help track bindings
    if action == "right" and device == "keyboard" then
        print("getBindingText for keyboard 'right' returning: " .. (binding or "nil"))
    end
    
    -- Format text for display
    if device == "keyboard" then
        -- Capitalize first letter and handle special keys
        if binding == "return" then
            return "Enter"
        elseif binding == "space" then
            return "Space"
        else
            return binding:sub(1,1):upper() .. binding:sub(2)
        end
    elseif device == "gamepad" then
        -- Format gamepad buttons
        if binding == "dpup" then
            return "D-Pad Up"
        elseif binding == "dpdown" then
            return "D-Pad Down"
        elseif binding == "dpleft" then
            return "D-Pad Left"
        elseif binding == "dpright" then
            return "D-Pad Right"
        elseif binding == "a" then
            return "A Button"
        elseif binding == "b" then
            return "B Button"
        elseif binding == "x" then
            return "X Button"
        elseif binding == "y" then
            return "Y Button"
        elseif binding and binding:sub(1, 9) == "leftstick" then
            return "Left Stick " .. binding:sub(11):upper()
        elseif binding then
            return binding:sub(1,1):upper() .. binding:sub(2)
        end
    end
    
    -- Fallback to just show the raw binding if available
    return binding or "Not Set"
end

-- Set a new key binding
function inputManager.setBinding(device, action, newBinding)
    inputManager.keyBindings[device][action] = newBinding
    gameState.settings.keyBindings = inputManager.keyBindings
    gameState.save()
end

-- Reset all bindings to default
function inputManager.resetToDefaults()
    print("=== RESETTING ALL KEY BINDINGS TO DEFAULTS ===")
    
    -- Completely clear and recreate the key bindings
    inputManager.keyBindings = {
        keyboard = {},
        gamepad = {}
    }
    
    -- For debugging, print default keyboard bindings
    print("Default keyboard bindings:")
    for action, key in pairs(defaultKeyBindings.keyboard) do
        print("  " .. action .. ": " .. key)
    end
    
    -- Copy all keyboard bindings from defaults
    for action, key in pairs(defaultKeyBindings.keyboard) do
        inputManager.keyBindings.keyboard[action] = key
    end
    
    -- Copy all gamepad bindings from defaults
    for action, button in pairs(defaultKeyBindings.gamepad) do
        inputManager.keyBindings.gamepad[action] = button
    end
    
    -- Verify the copied values
    print("Keyboard right binding was reset to: " .. inputManager.keyBindings.keyboard.right)
    
    -- First save to the settings
    gameState.settings.keyBindings = inputManager.keyBindings
    gameState.save()
    
    -- Return the new bindings
    return inputManager.keyBindings
end

-- Callback functions for gamepad connection/disconnection
function love.joystickadded(joystick)
    -- Use the first available gamepad
    if not currentGamepad then
        currentGamepad = joystick
        print("Gamepad connected: " .. currentGamepad:getName())
    end
end

function love.joystickremoved(joystick)
    -- If the current gamepad was disconnected, try to find another one
    if currentGamepad == joystick then
        currentGamepad = nil
        print("Gamepad disconnected")
        
        local joysticks = love.joystick.getJoysticks()
        if #joysticks > 0 then
            currentGamepad = joysticks[1]
            print("Using alternative gamepad: " .. currentGamepad:getName())
        end
    end
end

return inputManager
