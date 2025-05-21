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

    buttons = {}    -- Play button
    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2,
        centerY - buttonHeight - buttonSpacing,
        buttonWidth,
        buttonHeight,
        gameState.getText("play"),
        function()
            love.switchState("play")
        end,
        currentGuiScale, -- Pass the GUI scale for button's internal detail scaling
        true -- Enable automatic sound effects
    ))    -- Settings button
    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2,
        centerY,
        buttonWidth,
        buttonHeight,
        gameState.getText("settings"),
        function()
            love.switchState("settings")
        end,
        currentGuiScale, -- Pass the GUI scale
        true -- Enable automatic sound effects
    ))    -- Quit button
    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2,
        centerY + buttonHeight + buttonSpacing,
        buttonWidth,
        buttonHeight,
        gameState.getText("quit"),
        function()
            love.event.quit()
        end,
        currentGuiScale, -- Pass the GUI scale
        true -- Enable automatic sound effects
    ))
end

-- init receives: virtualWidth, virtualHeight, guiScale, guiOffsetX, guiOffsetY
function menuState.init(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    soundManager.playMusic("menu") -- Start playing menu music when entering the menu state
    menuState.selectedButton = 1  -- Reset selected button when initializing
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
    -- Get input manager for navigation
    local inputManager = require "src.utils.inputManager"
    inputManager.update(dt)    -- Update buttons, pass the guiScale for their internal logic (e.g., hover effects, animations)
    local hoveredButton = nil
    for i, button in ipairs(buttons) do
        button:update(dt, guiScale)
        
        -- Track which button is hovered but don't immediately update selection
        if button.hovered then
            hoveredButton = i
        end
    end
    
    -- Only update the selected button if a button is being hovered
    if hoveredButton ~= nil then
        -- Only update if the hover has changed
        if menuState.selectedButton ~= hoveredButton then
            menuState.selectedButton = hoveredButton
        end
    end
    
    -- Handle keyboard/gamepad navigation
    local selectedButtonChanged = false
      -- Ensure we have a default selection only for keyboard navigation
    -- If the mouse is not over any button, we still need a selection for keyboard controls
    if menuState.selectedButton == nil then
        -- Only set a default selection if we need to handle keyboard input
        if inputManager.isActionJustPressed("up") or
           inputManager.isActionJustPressed("down") or
           inputManager.isActionJustPressed("select") then
            menuState.selectedButton = 1
            -- Don't play the selection sound here as the keyboard navigation
            -- will handle playing sounds when direction keys are pressed
        end
    end
      if inputManager.isActionJustPressed("up") then
        -- If no button is selected, select the first one
        if menuState.selectedButton == nil then
            menuState.selectedButton = 1
        else
            menuState.selectedButton = menuState.selectedButton - 1
        end
        selectedButtonChanged = true
    elseif inputManager.isActionJustPressed("down") then
        -- If no button is selected, select the first one
        if menuState.selectedButton == nil then
            menuState.selectedButton = 1
        else
            menuState.selectedButton = menuState.selectedButton + 1
        end
        selectedButtonChanged = true
    end
      -- Wrap around selection if we have a selection
    if menuState.selectedButton ~= nil then
        if menuState.selectedButton < 1 then
            menuState.selectedButton = #buttons
        elseif menuState.selectedButton > #buttons then
            menuState.selectedButton = 1
        end
    end
    
    -- Play sound on selection change
    if selectedButtonChanged then
        soundManager.playSound("menuMove")
    end
      -- Handle selection with action button
    if inputManager.isActionJustPressed("select") and menuState.selectedButton ~= nil then
        if buttons[menuState.selectedButton] then
            soundManager.playSound("menuSelect")
            buttons[menuState.selectedButton].callback()
        end
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
    )    -- Draw buttons
    for i, button in ipairs(buttons) do
        -- If there's a selected button and this is it, highlight it
        if menuState.selectedButton ~= nil and i == menuState.selectedButton then
            local originalHoverColor = button.hoverColor
            button.hoverColor = {0.7, 0.7, 1.0, 1.0}
            button.hovered = true
            button:draw()
            button.hoverColor = originalHoverColor
            button.hovered = false
        else
            -- Just draw the button in its normal state
            button:draw() -- Buttons draw themselves on the virtual canvas
        end
    end
end

function menuState.mousepressed(x, y, button)
    -- x and y are already transformed to virtual canvas coordinates by main.lua
    if button == 1 then  -- Left mouse button
        for i, btn in ipairs(buttons) do
            if btn:click(x, y) then 
                menuState.selectedButton = i
                return 
            end
        end
    end
end

function menuState.mousemoved(x, y)
    -- x and y are already transformed to virtual canvas coordinates by main.lua
    
    -- Track the previously selected button to detect changes
    local previousSelection = menuState.selectedButton
    
    -- Check if mouse is over any button
    for i, btn in ipairs(buttons) do
        if x >= btn.x and x <= btn.x + btn.width and
           y >= btn.y and y <= btn.y + btn.height then
            -- Update selected button
            menuState.selectedButton = i
            
            -- Since buttons now handle their own sound effects,
            -- we no longer need to play sounds here.
            -- This prevents duplicate sound effects.
            
            return
        end
    end
      -- If we got here, we're not hovering over any button
    -- Clear the selection
    menuState.selectedButton = nil
end

return menuState
