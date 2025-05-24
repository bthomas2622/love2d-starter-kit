-- Snake Game Play State
local love = require("love")
local gameConfig = require("src.constants.gameConfig")
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"
local Snake = require "src.entities.snake"
local Fruit = require "src.entities.fruit"

local playState = {}

-- Game configuration (now using centralized constants)
local GRID_SIZE = gameConfig.SNAKE.GRID_SIZE
local GRID_WIDTH = nil -- Will be calculated based on screen width
local GRID_HEIGHT = nil -- Will be calculated based on screen height
local BASE_GAME_SPEED = gameConfig.SNAKE.BASE_GAME_SPEED
local SPEED_INCREASE = gameConfig.SNAKE.SPEED_INCREASE
local MIN_SPEED = gameConfig.SNAKE.MIN_SPEED
local INITIAL_LENGTH = gameConfig.SNAKE.INITIAL_LENGTH

-- Game state variables
local buttons = {}
local scoreFont = nil
local messageFont = nil
local snake = nil
local fruit = nil
local timer = 0
local score = 0
local gameOver = false
local paused = false
local gameSpeed = BASE_GAME_SPEED -- Current game speed (gets faster as score increases)

-- Store current transform for consistent UI layout
local baseScreenWidth = gameConfig.VIRTUAL_WIDTH
local baseScreenHeight = gameConfig.VIRTUAL_HEIGHT

-- Forward declarations (not needed anymore with entities)

-- Initialize the game elements
local function initGame()
    -- Reset game state
    timer = 0
    score = 0
    gameOver = false
    paused = false
    gameSpeed = BASE_GAME_SPEED -- Reset game speed to base value
    
    -- Create new snake entity
    snake = Snake.new(GRID_WIDTH, GRID_HEIGHT, GRID_SIZE, INITIAL_LENGTH)
    
    -- Create new fruit entity
    fruit = Fruit.new(GRID_WIDTH, GRID_HEIGHT, GRID_SIZE)
    
    -- Spawn first fruit
    fruit:spawn(snake)
end

local function recalculateLayout(w, h, scale, offsetX, offsetY)
    
    -- Get the virtual canvas size properly
    local _, _, _, vWidth, vHeight = love.getScreenTransform()
    baseScreenWidth = vWidth or 1280  -- Fallback if not available
    baseScreenHeight = vHeight or 720 -- Fallback if not available

    -- Calculate grid dimensions based on screen size
    GRID_WIDTH = math.floor(baseScreenWidth / GRID_SIZE)
    GRID_HEIGHT = math.floor(baseScreenHeight / GRID_SIZE)
      -- Load fonts
    if fontManager then
        scoreFont = fontManager.getFont(gameConfig.FONTS.SCORE) -- Font for score display
        messageFont = fontManager.getFont(gameConfig.FONTS.MESSAGE) -- Font for game over message
    end

    buttons = {} -- Initialize empty buttons table but don't add the back button
      -- Load game assets with error handling
    local function safeLoadImage(path)
        if love.filesystem.getInfo(path) then
            return love.graphics.newImage(path)
        else
            print("Warning: Could not find image at path: " .. path)
            return nil
        end
    end
    
    -- Load the snake and fruit images
    local snakeHeadImg = safeLoadImage("assets/images/snakeHead.png")
    local snakeBodyImg = safeLoadImage("assets/images/snakeBody.png")
    local snakeTailImg = safeLoadImage("assets/images/snakeTail.png")
    local fruitImg = safeLoadImage("assets/images/fruit.png")
      -- Set images for existing entities if they exist
    if snake then
        snake:setImages(snakeHeadImg, snakeBodyImg, snakeTailImg)
    end
    if fruit then
        fruit:setImage(fruitImg)
    end
    
    -- Initialize the game
    initGame()
    
    -- Set images for newly created entities
    if snake then
        snake:setImages(snakeHeadImg, snakeBodyImg, snakeTailImg)
    end
    if fruit then
        fruit:setImage(fruitImg)
    end
end

function playState.init(w, h, scale, offsetX, offsetY)
    -- Ensure input manager is initialized
    if inputManager and inputManager.init then
        inputManager.init()
    end
    
    recalculateLayout(w, h, scale, offsetX, offsetY)
end

function playState.resize(w, h, scale, offsetX, offsetY)
    -- Get the actual virtual canvas dimensions from the transform
    local s, ox, oy, baseWidth, baseHeight = love.getScreenTransform()
    recalculateLayout(baseWidth, baseHeight, s, ox, oy)
end

function playState.update(dt, scale)
    -- Update buttons
    if buttons then
        for _, button in ipairs(buttons) do
            if button and button.update then
                button:update(dt, scale)
            end
        end
    end
    
    -- Update inputManager
    if inputManager and inputManager.update then
        inputManager.update(dt)
    end
    
    if gameOver or paused then
        return
    end    -- Handle continuous input for more responsive controls
    -- Only process input when not in the process of moving the snake
    if timer < gameSpeed * 0.5 then -- Only accept new direction during first half of movement cycle
        -- Check for direction input using inputManager's isActionJustPressed function
        if inputManager and inputManager.isActionJustPressed and snake then
            local currentDirection = snake.direction
            if inputManager.isActionJustPressed("up") and currentDirection ~= "down" then
                snake:setDirection("up")
            elseif inputManager.isActionJustPressed("down") and currentDirection ~= "up" then
                snake:setDirection("down")
            elseif inputManager.isActionJustPressed("left") and currentDirection ~= "right" then
                snake:setDirection("left")
            elseif inputManager.isActionJustPressed("right") and currentDirection ~= "left" then
                snake:setDirection("right")
            end
        end
    end
    
    -- Update the game timer
    timer = timer + dt
      -- Move the snake at regular intervals
    if timer >= gameSpeed then
        timer = 0
        
        -- Move the snake and check for collisions
        if snake then
            local newHead = snake:move()
            
            if not newHead then
                -- Snake collided with wall or itself
                gameOver = true
                return
            end
            
            -- Check for fruit collision
            local headX, headY = snake:getHeadPosition()
            if fruit then
                local fruitX, fruitY = fruit:getPosition()
                
                if headX == fruitX and headY == fruitY then
                    -- Increase score
                    score = score + 1
                    -- Play fruit eating sound effect
                    soundManager.playSound("fruitEat")
                    
                    -- Increase game speed (make the game faster as the player scores more points)
                    gameSpeed = math.max(MIN_SPEED, gameSpeed - SPEED_INCREASE)
                    
                    -- Grow the snake (don't remove tail)
                    snake:grow()
                    
                    -- Spawn new fruit
                    fruit:spawn(snake)
                else
                    -- If no fruit eaten, remove the tail
                    snake:removeTail()
                end
            else
                -- If no fruit exists, just remove the tail
                snake:removeTail()
            end
        end
    end
end

function playState.draw()
    -- Background color - dark green for a classic snake feel
    love.graphics.setColor(0.1, 0.3, 0.1, 1)
    love.graphics.rectangle("fill", 0, 0, baseScreenWidth, baseScreenHeight)
    
    -- Draw checkerboard grid pattern for better visibility
    for y = 0, GRID_HEIGHT - 1 do
        for x = 0, GRID_WIDTH - 1 do
            if (x + y) % 2 == 0 then
                love.graphics.setColor(0.12, 0.32, 0.12, 1) -- Slightly lighter green
            else
                love.graphics.setColor(0.1, 0.3, 0.1, 1) -- Base green
            end
            love.graphics.rectangle("fill", x * GRID_SIZE, y * GRID_SIZE, GRID_SIZE, GRID_SIZE)
        end
    end
    
    -- Draw the grid lines for clarity
    love.graphics.setColor(0.15, 0.35, 0.15, 1)
    for x = 0, GRID_WIDTH do
        love.graphics.line(x * GRID_SIZE, 0, x * GRID_SIZE, GRID_HEIGHT * GRID_SIZE)
    end
    for y = 0, GRID_HEIGHT do
        love.graphics.line(0, y * GRID_SIZE, GRID_WIDTH * GRID_SIZE, y * GRID_SIZE)
    end
      -- Draw fruit
    if fruit then
        fruit:draw()
    end
    
    -- Draw snake
    if snake then
        snake:draw()
    end
    
    -- Draw score and speed
    if scoreFont then
        love.graphics.setFont(scoreFont)
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Display score
        local scoreText = score .. " " .. (score == 1 and "Fruit" or "Fruits")
        local scoreWidth = scoreFont:getWidth(scoreText) or 0
        love.graphics.print(scoreText, baseScreenWidth - scoreWidth - 20, 20)
        
        -- Display speed as a percentage (100% is base speed, higher is faster)
        local speedPercent = math.floor((BASE_GAME_SPEED / gameSpeed) * 100)
        local speedText = "Speed: " .. speedPercent .. "%"
        local speedWidth = scoreFont:getWidth(speedText) or 0
        love.graphics.print(speedText, baseScreenWidth - speedWidth - 20, 50)
    end
    
    -- Draw game over message if needed
    if gameOver and messageFont and scoreFont then
        love.graphics.setFont(messageFont)
        love.graphics.setColor(1, 0.2, 0.2, 1)
        local message = "Game Over!"
        local messageWidth = messageFont:getWidth(message) or 0
        local messageFontHeight = messageFont:getHeight() or 0
        
        love.graphics.print(
            message,
            baseScreenWidth/2 - messageWidth/2,
            baseScreenHeight/2 - messageFontHeight/2
        )
        
        love.graphics.setFont(scoreFont)
        local restartMsg = "Press Enter/Select to restart"
        local restartWidth = scoreFont:getWidth(restartMsg) or 0
        
        love.graphics.print(
            restartMsg,
            baseScreenWidth/2 - restartWidth/2,
            baseScreenHeight/2 + messageFontHeight
        )
    end
    
    -- Draw pause message if needed
    if paused and messageFont then
        love.graphics.setFont(messageFont)
        love.graphics.setColor(1, 1, 1, 1)
        local message = "Paused"
        local messageWidth = messageFont:getWidth(message) or 0
        local messageFontHeight = messageFont:getHeight() or 0
        
        love.graphics.print(
            message,
            baseScreenWidth/2 - messageWidth/2,
            baseScreenHeight/2 - messageFontHeight/2
        )
        
        -- Add instructions for returning to menu
        if scoreFont then
            love.graphics.setFont(scoreFont)
            local backKeyText = inputManager.getBindingText("keyboard", "back")
            local menuMsg = "Press " .. backKeyText .. " again to return to menu"
            local menuMsgWidth = scoreFont:getWidth(menuMsg) or 0
            
            love.graphics.print(
                menuMsg,
                baseScreenWidth/2 - menuMsgWidth/2,
                baseScreenHeight/2 + messageFontHeight
            )
        end
    end
end

function playState.mousepressed(x, y, button)
    -- x, y are already transformed by main.lua
    if button == 1 then  -- Left mouse button
        for _, btn in ipairs(buttons) do
            btn:click(x, y) -- Pass transformed coordinates
        end
        
        -- Handle mouse click to restart game when game over
        if gameOver then
            initGame()
        elseif paused then
            -- Unpause game when clicked during pause
            paused = false
        end
    end
end

-- Consolidated input handling logic
local function handleInput(inputType, inputValue)
    -- Verify inputManager exists
    if not inputManager then
        return
    end
    
    -- Determine which action was triggered based on input type
    local actionTriggered = nil
    
    if inputType == "keyboard" then
        -- Find which action corresponds to this key
        for action, key in pairs(inputManager.keyBindings.keyboard) do
            if key == inputValue then
                actionTriggered = action
                break
            end
        end
    elseif inputType == "gamepad" then
        -- Find which action corresponds to this button
        for action, button in pairs(inputManager.keyBindings.gamepad) do
            if button == inputValue then
                actionTriggered = action
                break
            end
        end
    end
    
    -- If no action was found, return early
    if not actionTriggered then
        return
    end
    
    -- Handle the action based on game state
    if gameOver then
        if actionTriggered == "select" then
            initGame()
        elseif actionTriggered == "back" then
            -- Return to menu when back is pressed on game over screen
            soundManager.playSound("menuBack")
            love.switchState("menu")
        end
        return
    end
    
    -- Toggle pause or return to menu
    if actionTriggered == "back" then
        if paused then
            -- Return to menu when back is pressed while paused
            soundManager.playSound("menuBack")
            love.switchState("menu")
        else
            -- First pause the game
            paused = true
        end
        return
    end
    
    if paused then
        return
    end    -- Direction controls (prevent 180-degree turns)
    if snake then
        local currentDirection = snake.direction
        if actionTriggered == "up" and currentDirection ~= "down" then
            snake:setDirection("up")
        elseif actionTriggered == "down" and currentDirection ~= "up" then
            snake:setDirection("down")
        elseif actionTriggered == "left" and currentDirection ~= "right" then
            snake:setDirection("left")
        elseif actionTriggered == "right" and currentDirection ~= "left" then
            snake:setDirection("right")
        end
    end
end

-- Handle keyboard input
function playState.keypressed(key)
    handleInput("keyboard", key)
end

-- Handle gamepad input
function playState.gamepadpressed(joystick, button)
    handleInput("gamepad", button)
end

return playState
