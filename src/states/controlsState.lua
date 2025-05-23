-- filepath: c:\Users\Ben\Documents\LoveProjects\love2d-starter-kit\src\states\controlsState.lua
-- Controls Settings State
local love = require("love")
local gameConfig = require("src.constants.gameConfig")
local Button = require "src.ui.button"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"

local controlsState = {}

local buttons = {}
local controlButtons = {}

-- Final button array order after recalculateLayout():
-- 1: Keyboard UP        7: Gamepad UP
-- 2: Keyboard DOWN      8: Gamepad DOWN
-- 3: Keyboard LEFT      9: Gamepad LEFT
-- 4: Keyboard RIGHT     10: Gamepad RIGHT
-- 5: Keyboard SELECT    11: Gamepad SELECT
-- 6: Keyboard BACK      12: Gamepad BACK
-- 13: Back button (to return to settings)
-- 14: Reset button

local titleFont = nil
local labelFont = nil
local waitingForInput = false
local currentBindingDevice = nil
local currentBindingAction = nil

-- Store virtual canvas dimensions and current GUI scale
local virtualWidth = 1280
local virtualHeight = 720
local currentGuiScale = 1

-- Add a cooldown timer to prevent executing the remapped input
local remappingCooldown = 0
local remappingCooldownTime = 0.5 -- Half a second cooldown after remapping

-- Actions that can be bound
local bindableActions = {
    "up", "down", "left", "right", "select", "back"
}

-- Variable to track selected button index
local selectedButtonIndex = 1

-- Function to update all control button texts with current bindings
local function updateControlButtonTexts()
    -- Make sure we refresh all control buttons with current bindings
    for _, btn in ipairs(controlButtons) do
        if btn.deviceType and btn.actionType then
            -- Force get the latest binding text
            btn.text = inputManager.getBindingText(btn.deviceType, btn.actionType)
        end
    end
    -- Force a visual update by returning true
    return true
end

local function recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    -- Always get the actual virtual canvas dimensions from the main transform
    local _, _, _, baseWidth, baseHeight = love.getScreenTransform()
    virtualWidth = baseWidth or vWidth
    virtualHeight = baseHeight or vHeight
    currentGuiScale = guiScale    titleFont = fontManager.getFont(gameConfig.FONTS.CONTROLS_TITLE)
    labelFont = fontManager.getFont(gameConfig.FONTS.LABEL)

    local centerX = virtualWidth / 2
    local startY = virtualHeight * gameConfig.CONTROLS.START_Y_OFFSET
    local spacing = virtualHeight * gameConfig.CONTROLS.SPACING_OFFSET
    
    -- Clear existing buttons
    buttons = {}
    controlButtons = {}
      -- Title area - spans both columns
    local columnWidth = virtualWidth * gameConfig.CONTROLS.COLUMN_WIDTH_RATIO
    local buttonWidth = virtualWidth * gameConfig.CONTROLS.BUTTON_WIDTH_RATIO
    local buttonHeight = virtualHeight * gameConfig.CONTROLS.BUTTON_HEIGHT_RATIO
      
    -- Create keyboard controls column
    local keyboardX = centerX - columnWidth + gameConfig.CONTROLS.KEYBOARD_X_OFFSET
    for i, action in ipairs(bindableActions) do
        -- Create button for rebinding
        local buttonY = startY + spacing * i
        local keyBtn = Button.new(
            keyboardX,
            buttonY,
            buttonWidth,
            buttonHeight,
            inputManager.getBindingText("keyboard", action),
            function()
                -- Start rebinding process
                waitingForInput = true
                currentBindingDevice = "keyboard"
                currentBindingAction = action
                soundManager.playSound("menuSelect")
            end,
            currentGuiScale
        )
        keyBtn.actionType = action
        keyBtn.deviceType = "keyboard"
        table.insert(controlButtons, keyBtn)
    end
      -- Create gamepad controls column
    local gamepadX = centerX + gameConfig.CONTROLS.GAMEPAD_X_OFFSET
    for i, action in ipairs(bindableActions) do
        -- Create button for rebinding
        local buttonY = startY + spacing * i
        local padBtn = Button.new(
            gamepadX,
            buttonY,
            buttonWidth,
            buttonHeight,
            inputManager.getBindingText("gamepad", action),
            function()
                -- Start rebinding process
                waitingForInput = true
                currentBindingDevice = "gamepad"
                currentBindingAction = action
                soundManager.playSound("menuSelect")
            end,
            currentGuiScale
        )
        padBtn.actionType = action
        padBtn.deviceType = "gamepad"
        table.insert(controlButtons, padBtn)
    end
    
    -- Back button
    table.insert(buttons, Button.new(
        centerX - columnWidth + 200,
        virtualHeight * 0.85,
        buttonWidth,
        buttonHeight,
        gameState.getText("back"),
        function()
            soundManager.playSound("menuBack")
            love.switchState("settings")
        end,
        currentGuiScale
    ))
      -- Reset button
    table.insert(buttons, Button.new(
        centerX + 20,
        virtualHeight * 0.85,
        buttonWidth,
        buttonHeight,
        gameState.getText("reset"),        function()
            -- First play the sound
            soundManager.playSound("menuSelect")
            
            -- Reset key bindings to defaults - returns the new bindings
            local newBindings = inputManager.resetToDefaults()
            
            -- Debug output to verify default values were restored
            print("Reset defaults - keyboard 'right' is now: " .. newBindings.keyboard.right)
            
            -- Force refresh of all control buttons with updated texts
            for _, btn in ipairs(controlButtons) do
                if btn.deviceType and btn.actionType then
                    -- First clear button text to ensure visual update
                    btn.text = ""
                    
                    -- Important: Force refresh the text from input manager
                    btn.text = inputManager.getBindingText(btn.deviceType, btn.actionType)
                    
                    -- Print confirmation for the button update
                    if btn.actionType == "right" and btn.deviceType == "keyboard" then
                        print("Updated 'right' button text to: " .. btn.text)
                    end
                end
            end
            
            -- Force a redraw
            love.graphics.present()
        end,
        currentGuiScale
    ))
    
    -- Combine all buttons for navigation
    local allButtons = {}
    
    -- Add control buttons
    for i, btn in ipairs(controlButtons) do
        table.insert(allButtons, btn)
    end
    
    -- Add navigation buttons
    for i, btn in ipairs(buttons) do
        table.insert(allButtons, btn)
    end
    
    -- Update button navigation properties
    buttons = allButtons
    
    -- Set the initial selected button
    if selectedButtonIndex > #buttons then
        selectedButtonIndex = 1
    end
end

function controlsState.init(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    waitingForInput = false
    currentBindingDevice = nil
    currentBindingAction = nil
    selectedButtonIndex = 1
    remappingCooldown = 0 -- Reset cooldown when entering the screen
end

function controlsState.resize(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    local _, _, _, baseWidth, baseHeight = love.getScreenTransform()
    virtualWidth = baseWidth
    virtualHeight = baseHeight
    recalculateLayout(virtualWidth, virtualHeight, guiScale, guiOffsetX, guiOffsetY)
end

function controlsState.update(dt, guiScale)
    -- Update input manager
    inputManager.update(dt)
    
    -- Update remapping cooldown timer if active
    if remappingCooldown > 0 then
        remappingCooldown = remappingCooldown - dt
        if remappingCooldown <= 0 then
            remappingCooldown = 0
            -- Debug output to confirm cooldown ended
            print("Remapping cooldown ended, inputs now active again")
        end
        return -- Skip all input processing during cooldown
    end
    
    -- Don't process navigation when waiting for input
    if waitingForInput then
        return
    end
    
    -- Update all buttons
    for i, button in ipairs(buttons) do
        button:update(dt, guiScale)
    end
    
    -- Handle gamepad/keyboard navigation
    if inputManager.isActionJustPressed("up") then
        if selectedButtonIndex ~= 1 and selectedButtonIndex ~= 7 then
            if selectedButtonIndex < 13 then
                selectedButtonIndex = selectedButtonIndex - 1
                soundManager.playSound("menuMove")
            elseif selectedButtonIndex == 13 then
                selectedButtonIndex = 6
                soundManager.playSound("menuMove")
            elseif selectedButtonIndex == 14 then
                selectedButtonIndex = 12
                soundManager.playSound("menuMove")
            end
        end
    elseif inputManager.isActionJustPressed("down") then
        if selectedButtonIndex ~= 13 and selectedButtonIndex ~= 14 and selectedButtonIndex ~= 6 and selectedButtonIndex ~= 12 then
            selectedButtonIndex = selectedButtonIndex + 1
            soundManager.playSound("menuMove")
        elseif selectedButtonIndex == 6 then
            selectedButtonIndex = 13
            soundManager.playSound("menuMove")
        elseif selectedButtonIndex == 12 then
            selectedButtonIndex = 14
            soundManager.playSound("menuMove")
        end
    elseif inputManager.isActionJustPressed("left") then
        if selectedButtonIndex > 6 and selectedButtonIndex < 13 then
            selectedButtonIndex = selectedButtonIndex - 6
            soundManager.playSound("menuMove")
        elseif selectedButtonIndex == 14 then
            selectedButtonIndex = 13
            soundManager.playSound("menuMove")
        end
    elseif inputManager.isActionJustPressed("right") then
        if selectedButtonIndex < 7 then
            selectedButtonIndex = selectedButtonIndex + 6
            soundManager.playSound("menuMove")
        elseif selectedButtonIndex == 13 then
            selectedButtonIndex = 14
            soundManager.playSound("menuMove")
        end
    elseif inputManager.isActionJustPressed("select") then
        -- Activate the selected button
        if buttons[selectedButtonIndex] then
            buttons[selectedButtonIndex]:click()
        end
    elseif inputManager.isActionJustPressed("back") then
        soundManager.playSound("menuBack")
        love.switchState("settings")
    end
end

function controlsState.draw()    -- Draw title
    love.graphics.setFont(titleFont)
    local title = gameState.getText("controls")
    local titleWidth = titleFont and titleFont:getWidth(title) or 0
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        title,
        virtualWidth / 2 - titleWidth / 2,
        virtualHeight * gameConfig.CONTROLS.TITLE_Y_OFFSET
    )
    
    -- Draw section headers
    love.graphics.setFont(labelFont)
    
    local centerX = virtualWidth / 2
    local columnWidth = virtualWidth * gameConfig.CONTROLS.COLUMN_WIDTH_RATIO
    
    love.graphics.print(
        gameState.getText("keyboard"),
        centerX - columnWidth + gameConfig.CONTROLS.KEYBOARD_X_OFFSET,
        virtualHeight * gameConfig.CONTROLS.HEADER_Y_OFFSET
    )
    
    love.graphics.print(
        gameState.getText("gamepad"),
        centerX + gameConfig.CONTROLS.GAMEPAD_X_OFFSET,
        virtualHeight * gameConfig.CONTROLS.HEADER_Y_OFFSET
    )    -- Draw action labels
    local startY = virtualHeight * 0.15
    local spacing = virtualHeight * 0.07
    
    love.graphics.setColor(1, 1, 1, 1)    for i, action in ipairs(bindableActions) do
        local actionY = startY + spacing * i
        local actionText = gameState.getText(action)
        local actionWidth = labelFont and labelFont:getWidth(actionText) or 0        -- Draw the action label on the left side
        love.graphics.print(
            actionText,
            virtualWidth * 0.2,  -- Changed from 0.05 (5%) to 0.15 (15%) to move closer to the center
            actionY + virtualHeight * 0.02
        )
    end
    
    -- Draw all buttons
    for i, button in ipairs(buttons) do
        -- Highlight the selected button
        local isSelected = (i == selectedButtonIndex)
        local originalHoverColor = button.hoverColor
        
        if isSelected then
            button.hoverColor = {0.7, 0.7, 1.0, 1.0}
            button.hovered = true
        end
        
        button:draw()
        
        -- Reset the button state
        if isSelected then
            button.hoverColor = originalHoverColor
            button.hovered = false
        end
    end
    
    -- Draw "Press any key" message if waiting for input    
    if waitingForInput then
        -- Ensure we have a valid GUI scale for the modal dialog
        currentGuiScale = currentGuiScale or 1
          love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", virtualWidth * gameConfig.CONTROLS.MODAL_X_RATIO, virtualHeight * gameConfig.CONTROLS.MODAL_Y_RATIO, virtualWidth * gameConfig.CONTROLS.MODAL_WIDTH_RATIO, virtualHeight * gameConfig.CONTROLS.MODAL_HEIGHT_RATIO)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", virtualWidth * gameConfig.CONTROLS.MODAL_X_RATIO, virtualHeight * gameConfig.CONTROLS.MODAL_Y_RATIO, virtualWidth * gameConfig.CONTROLS.MODAL_WIDTH_RATIO, virtualHeight * gameConfig.CONTROLS.MODAL_HEIGHT_RATIO)
        
        love.graphics.setFont(titleFont)
        local promptText = "Press any key..."
        local promptWidth = titleFont and titleFont:getWidth(promptText) or 0
        local promptHeight = titleFont and titleFont:getHeight() or 0
        
        love.graphics.print(
            promptText,
            virtualWidth / 2 - promptWidth / 2,
            virtualHeight / 2 - promptHeight / 2
        )
    end
end

function controlsState.mousepressed(x, y, button)
    -- Skip all mouse input during cooldown period
    if remappingCooldown > 0 then
        return
    end
    
    if button == 1 then
        if waitingForInput then
            -- Cancel rebinding on mouse click
            waitingForInput = false
            return
        end
        
        -- Note: x, y are already transformed to virtual canvas coordinates by main.lua
        
        -- Check for button clicks
        for i, btn in ipairs(buttons) do
            -- Use Button's click method which handles the sound and callback
            if btn:click(x, y) then
                selectedButtonIndex = i
                return
            end
        end
    end
end

function controlsState.mousemoved(x, y)
    -- Don't update when waiting for input or during cooldown
    if waitingForInput or remappingCooldown > 0 then
        return
    end
    
    -- Update selectedButtonIndex based on mouse hover
    local hoveredButton = nil
    
    -- Note: x, y are already transformed to virtual canvas coordinates by main.lua
    
    -- Check if mouse is over any button
    for i, btn in ipairs(buttons) do
        if x >= btn.x and x <= btn.x + btn.width and
           y >= btn.y and y <= btn.y + btn.height then
            hoveredButton = i
            break
        end
    end
    
    -- Only update and play sound if selection changed
    if hoveredButton and selectedButtonIndex ~= hoveredButton then
        selectedButtonIndex = hoveredButton
        -- Play the sound when the selected button changes
        soundManager.playSound("menuMove")
    end
end

function controlsState.keypressed(key)
    if waitingForInput and currentBindingDevice == "keyboard" then
        -- Assign the new key binding
        inputManager.setBinding("keyboard", currentBindingAction, key)
        
        -- Update the button label
        for _, btn in ipairs(controlButtons) do
            if btn.deviceType == "keyboard" and btn.actionType == currentBindingAction then
                btn.text = inputManager.getBindingText("keyboard", currentBindingAction)
            end
        end
        
        waitingForInput = false
        soundManager.playSound("menuSelect")
        
        -- Activate cooldown to prevent the new key from being processed as an action
        remappingCooldown = remappingCooldownTime
        print("Remapping cooldown started - preventing input execution for " .. remappingCooldownTime .. " seconds")
    end
end

function controlsState.gamepadpressed(joystick, button)
    if waitingForInput and currentBindingDevice == "gamepad" then
        -- Assign the new gamepad binding
        inputManager.setBinding("gamepad", currentBindingAction, button)
        
        -- Update the button label
        for _, btn in ipairs(controlButtons) do
            if btn.deviceType == "gamepad" and btn.actionType == currentBindingAction then
                btn.text = inputManager.getBindingText("gamepad", currentBindingAction)
            end
        end
        
        waitingForInput = false
        soundManager.playSound("menuSelect")
        
        -- Activate cooldown to prevent the new button from being processed as an action
        remappingCooldown = remappingCooldownTime
        print("Remapping cooldown started - preventing input execution for " .. remappingCooldownTime .. " seconds")
    end
end

return controlsState
