-- Controls Settings State
local love = require("love")
local Button = require "src.ui.button"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"

local controlsState = {}

local buttons = {}
local controlButtons = {}
local titleFont = nil
local labelFont = nil
local waitingForInput = false
local currentBindingDevice = nil
local currentBindingAction = nil

-- Store virtual canvas dimensions and current GUI scale
local virtualWidth = 1280
local virtualHeight = 720
local currentGuiScale = 1

-- Actions that can be bound
local bindableActions = {
    "up", "down", "left", "right", "select", "back"
}

-- Variable to track selected button index
local selectedButtonIndex = 1

local function recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    -- Always get the actual virtual canvas dimensions from the main transform
    local _, _, _, baseWidth, baseHeight = love.getScreenTransform()
    virtualWidth = baseWidth or vWidth
    virtualHeight = baseHeight or vHeight
    currentGuiScale = guiScale

    titleFont = fontManager.getFont(30)
    labelFont = fontManager.getFont(16)

    local centerX = virtualWidth / 2
    local startY = virtualHeight * 0.15
    local spacing = virtualHeight * 0.07
    
    buttons = {}
    controlButtons = {}
    
    -- Title area - spans both columns
    local columnWidth = virtualWidth * 0.35
    local buttonWidth = virtualWidth * 0.15
    local buttonHeight = virtualHeight * 0.06
    
    -- Create keyboard controls column
    local keyboardX = centerX - columnWidth - 20
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
    local gamepadX = centerX + 20
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
        centerX - columnWidth - 20,
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
        gameState.getText("reset"),
        function()
            inputManager.resetToDefaults()
            soundManager.playSound("menuSelect")
            recalculateLayout(virtualWidth, virtualHeight, currentGuiScale, guiOffsetX, guiOffsetY)
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
        soundManager.playSound("menuMove")
        selectedButtonIndex = selectedButtonIndex - 2
        if selectedButtonIndex < 1 then
            selectedButtonIndex = #buttons - (selectedButtonIndex + 2)
        end
    elseif inputManager.isActionJustPressed("down") then
        soundManager.playSound("menuMove")
        selectedButtonIndex = selectedButtonIndex + 2
        if selectedButtonIndex > #buttons then
            selectedButtonIndex = selectedButtonIndex - #buttons
        end
    elseif inputManager.isActionJustPressed("left") then
        soundManager.playSound("menuMove")
        if selectedButtonIndex % 2 == 0 then
            selectedButtonIndex = selectedButtonIndex - 1
        end
    elseif inputManager.isActionJustPressed("right") then
        soundManager.playSound("menuMove")
        if selectedButtonIndex % 2 == 1 and selectedButtonIndex < #buttons then
            selectedButtonIndex = selectedButtonIndex + 1
        end
    elseif inputManager.isActionJustPressed("select") then
        -- Activate the selected button
        if buttons[selectedButtonIndex] then
            buttons[selectedButtonIndex].callback()
        end
    elseif inputManager.isActionJustPressed("back") then
        soundManager.playSound("menuBack")
        love.switchState("settings")
    end
end

function controlsState.draw()
    -- Draw title
    love.graphics.setFont(titleFont)
    local title = gameState.getText("controls")
    local titleWidth = titleFont:getWidth(title)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        title,
        virtualWidth / 2 - titleWidth / 2,
        virtualHeight * 0.05
    )
    
    -- Draw section headers
    love.graphics.setFont(labelFont)
    
    local centerX = virtualWidth / 2
    local columnWidth = virtualWidth * 0.35
    
    love.graphics.print(
        gameState.getText("keyboard"),
        centerX - columnWidth - 20,
        virtualHeight * 0.12
    )
    
    love.graphics.print(
        gameState.getText("gamepad"),
        centerX + 20,
        virtualHeight * 0.12
    )
    
    -- Draw action labels
    local startY = virtualHeight * 0.15
    local spacing = virtualHeight * 0.07
    
    for i, action in ipairs(bindableActions) do
        local actionY = startY + spacing * i
        love.graphics.print(
            gameState.getText(action),
            virtualWidth * 0.2,
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
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", virtualWidth * 0.3, virtualHeight * 0.4, virtualWidth * 0.4, virtualHeight * 0.2)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", virtualWidth * 0.3, virtualHeight * 0.4, virtualWidth * 0.4, virtualHeight * 0.2)
        
        love.graphics.setFont(titleFont)
        local promptText = "Press any key..."
        local promptWidth = titleFont:getWidth(promptText)
        
        love.graphics.print(
            promptText,
            virtualWidth / 2 - promptWidth / 2,
            virtualHeight / 2 - titleFont:getHeight() / 2
        )
    end
end

function controlsState.mousepressed(x, y, button)
    if button == 1 then
        if waitingForInput then
            -- Cancel rebinding on mouse click
            waitingForInput = false
            return
        end
        
        for i, btn in ipairs(buttons) do
            if btn:click(x, y) then
                selectedButtonIndex = i
                return
            end
        end
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
    end
end

return controlsState
