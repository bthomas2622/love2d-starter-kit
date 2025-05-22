-- Snake Game Play State
local love = require("love")
local Button = require "src.ui.button"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"
local inputManager = require "src.utils.inputManager"

local playState = {}

-- Game configuration
local GRID_SIZE = 40 -- Size of each grid cell in pixels (doubled from 20 to make snake/fruit 2x larger)
local GRID_WIDTH = nil -- Will be calculated based on screen width
local GRID_HEIGHT = nil -- Will be calculated based on screen height
local BASE_GAME_SPEED = 0.15 -- Base time (in seconds) between snake movements
local SPEED_INCREASE = 0.005 -- How much to decrease the delay per fruit eaten
local MIN_SPEED = 0.05 -- Minimum speed delay (maximum speed)
local INITIAL_LENGTH = 2 -- Initial snake body length (excluding head)

-- Game state variables
local buttons = {}
local scoreFont = nil
local messageFont = nil
local snakeHead = nil
local snakeBody = nil
local snakeTail = nil
local fruitImg = nil
local snake = {}
local fruit = {x = 1, y = 1} -- Initialize with a default value
local direction = "right"
local nextDirection = "right"
local timer = 0
local score = 0
local gameOver = false
local paused = false
local gameSpeed = BASE_GAME_SPEED -- Current game speed (gets faster as score increases)

-- Store current transform for consistent UI layout
local currentScale = 1
local currentOffsetX = 0
local currentOffsetY = 0
local baseScreenWidth = 1280
local baseScreenHeight = 720

-- Forward declarations
local spawnFruit

-- Initialize the game elements
local function initGame()
    -- Reset game state
    snake = {}
    direction = "right"
    nextDirection = "right"
    timer = 0
    score = 0
    gameOver = false
    paused = false
    gameSpeed = BASE_GAME_SPEED -- Reset game speed to base value
    
    -- Create the snake with initial length
    local startX = math.floor(GRID_WIDTH / 4)
    local startY = math.floor(GRID_HEIGHT / 2)
    
    -- Create head
    snake[1] = {x = startX, y = startY, type = "head"}
    
    -- Create initial body segments
    for i = 1, INITIAL_LENGTH do
        snake[i+1] = {x = startX - i, y = startY, type = "body"}
    end
    
    -- Set the last segment as tail
    if #snake > 1 then
        snake[#snake].type = "tail"
    end
    
    -- Spawn first fruit
    spawnFruit()
end

-- Spawn a fruit at a random location (not on the snake)
spawnFruit = function()
    local valid = false
    local newX, newY
    
    while not valid do
        -- Make sure we're using the current grid dimensions
        newX = love.math.random(1, GRID_WIDTH)
        newY = love.math.random(1, GRID_HEIGHT)
        
        -- Check if position collides with snake
        valid = true
        for _, segment in ipairs(snake) do
            if segment.x == newX and segment.y == newY then
                valid = false
                break
            end
        end
    end
    
    fruit = {x = newX, y = newY}
end

-- Update snake segment types (head, body, tail)
local function updateSnakeSegmentTypes()
    if #snake == 0 then return end
    
    -- First segment is always the head
    snake[1].type = "head"
    
    -- Middle segments are body
    for i = 2, #snake - 1 do
        if snake[i] then
            snake[i].type = "body"
        end
    end
    
    -- Last segment is always the tail
    if #snake > 1 then
        snake[#snake].type = "tail"
    end
end

-- Calculate rotation angle for a snake segment based on direction
local function getSegmentRotation(segment, prevSegment, nextSegment)
    if not segment then return 0 end
    if segment.type == "head" then
        -- Head rotation based on movement direction
        if direction == "up" then return 0            -- Head points up
        elseif direction == "down" then return math.pi            -- Head points down
        elseif direction == "left" then return -math.pi/2    -- Head points left
        else return math.pi/2                              -- Head points right
        end
    elseif segment.type == "tail" then
        -- Tail rotation based on the direction to the previous segment
        if nextSegment then
            if segment.y > nextSegment.y then return 0       -- Prev is above
            elseif segment.y < nextSegment.y then return math.pi -- Prev is below
            elseif segment.x > nextSegment.x then return -math.pi/2 -- Prev is to the left
            else return math.pi/2 -- Prev is to the right
            end
        end
        return 0
    else
        -- For body segments, calculate rotation based on both prev and next segments
        if prevSegment and nextSegment then
            -- Check for turns (when direction changes)
            
            -- Vertical to horizontal transitions
            if prevSegment.x == segment.x and segment.y == nextSegment.y then
                -- From up to right
                if prevSegment.y > segment.y and segment.x < nextSegment.x then
                    return -math.pi/2 -- Was 0
                -- From up to left
                elseif prevSegment.y > segment.y and segment.x > nextSegment.x then
                    return -math.pi -- Was -math.pi/2
                -- From down to right
                elseif prevSegment.y < segment.y and segment.x < nextSegment.x then
                    return 0 -- Was math.pi/2
                -- From down to left
                elseif prevSegment.y < segment.y and segment.x > nextSegment.x then
                    return math.pi/2 -- Was math.pi
                end
            -- Horizontal to vertical transitions
            elseif prevSegment.y == segment.y and segment.x == nextSegment.x then
                -- From right to down
                if prevSegment.x < segment.x and segment.y < nextSegment.y then
                    return -math.pi/2 -- Was 0
                -- From right to up
                elseif prevSegment.x < segment.x and segment.y > nextSegment.y then
                    return 0 -- Was math.pi/2
                -- From left to down
                elseif prevSegment.x > segment.x and segment.y < nextSegment.y then
                    return -math.pi -- Was -math.pi/2
                -- From left to up
                elseif prevSegment.x > segment.x and segment.y > nextSegment.y then
                    return math.pi/2 -- Was math.pi
                end
            end
            
            -- Check if part of a straight section
            if prevSegment.x == nextSegment.x then
                return 0  -- Vertical segment (was math.pi/2)
            end
        end
        return -math.pi/2  -- Default horizontal orientation (was 0)
    end
end

local function recalculateLayout(w, h, scale, offsetX, offsetY)
    currentScale = scale
    currentOffsetX = offsetX
    currentOffsetY = offsetY
    
    -- Get the virtual canvas size properly
    local _, _, _, vWidth, vHeight = love.getScreenTransform()
    baseScreenWidth = vWidth or 1280  -- Fallback if not available
    baseScreenHeight = vHeight or 720 -- Fallback if not available

    -- Calculate grid dimensions based on screen size
    GRID_WIDTH = math.floor(baseScreenWidth / GRID_SIZE)
    GRID_HEIGHT = math.floor(baseScreenHeight / GRID_SIZE)
    
    -- Load fonts
    if fontManager then
        scoreFont = fontManager.getFont(24) -- Font for score display
        messageFont = fontManager.getFont(36) -- Font for game over message
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
    snakeHead = safeLoadImage("assets/images/snakeHead.png")
    snakeBody = safeLoadImage("assets/images/snakeBody.png")
    snakeTail = safeLoadImage("assets/images/snakeTail.png")
    fruitImg = safeLoadImage("assets/images/fruit.png")
    
    -- Initialize the game
    initGame()
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
    end
    
    -- Handle continuous input for more responsive controls
    -- Only process input when not in the process of moving the snake
    if timer < gameSpeed * 0.5 then -- Only accept new direction during first half of movement cycle
        -- Check for direction input using inputManager's isActionJustPressed function
        if inputManager and inputManager.isActionJustPressed then
            if inputManager.isActionJustPressed("up") and direction ~= "down" then
                nextDirection = "up"
            elseif inputManager.isActionJustPressed("down") and direction ~= "up" then
                nextDirection = "down"
            elseif inputManager.isActionJustPressed("left") and direction ~= "right" then
                nextDirection = "left"
            elseif inputManager.isActionJustPressed("right") and direction ~= "left" then
                nextDirection = "right"
            end
        end
    end
    
    -- Update the game timer
    timer = timer + dt
    
    -- Move the snake at regular intervals
    if timer >= gameSpeed then
        timer = 0
        
        -- Update direction based on nextDirection
        direction = nextDirection
        
        -- Check if snake has a head
        if #snake < 1 then
            return
        end
        
        -- Calculate new head position
        local newHead = {x = snake[1].x, y = snake[1].y, type = "head"}
        
        if direction == "up" then
            newHead.y = newHead.y - 1
        elseif direction == "down" then
            newHead.y = newHead.y + 1
        elseif direction == "left" then
            newHead.x = newHead.x - 1
        elseif direction == "right" then
            newHead.x = newHead.x + 1
        end
        
        -- Check for collision with walls
        if newHead.x < 1 or newHead.x > GRID_WIDTH or newHead.y < 1 or newHead.y > GRID_HEIGHT then
            gameOver = true
            return
        end
        
        -- Check for collision with self
        for i = 1, #snake - 1 do
            if snake[i] and newHead.x == snake[i].x and newHead.y == snake[i].y then
                gameOver = true
                return
            end
        end
        
        -- Insert new head at beginning
        table.insert(snake, 1, newHead)        -- Check for fruit collision
        if fruit and newHead.x == fruit.x and newHead.y == fruit.y then
            -- Increase score
            score = score + 1
            -- Play fruit eating sound effect
            soundManager.playSound("fruitEat")
            
            -- Increase game speed (make the game faster as the player scores more points)
            gameSpeed = math.max(MIN_SPEED, gameSpeed - SPEED_INCREASE)
            
            -- Spawn new fruit
            if spawnFruit then
                spawnFruit()
            end
        else
            -- If no fruit eaten, remove the tail
            table.remove(snake)
        end
        
        -- Update segment types after any changes to the snake
        updateSnakeSegmentTypes()
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
    if fruitImg and fruit then
        love.graphics.setColor(1, 1, 1, 1)
        local fruitWidth = fruitImg:getWidth() or 1
        local fruitHeight = fruitImg:getHeight() or 1
        
        -- Scale fruit image 2x larger
        love.graphics.draw(
            fruitImg, 
            (fruit.x - 0.5) * GRID_SIZE, 
            (fruit.y - 0.5) * GRID_SIZE, 
            0, 
            GRID_SIZE / fruitWidth, 
            GRID_SIZE / fruitHeight
        )
    end
    
    -- Draw snake
    if snake then
        love.graphics.setColor(1, 1, 1, 1)
        for i, segment in ipairs(snake) do
            local img = nil
            
            if segment.type == "head" and snakeHead then
                img = snakeHead
            elseif segment.type == "tail" and snakeTail then
                img = snakeTail
            elseif snakeBody then
                img = snakeBody
            end
            
            if img then
                local prevSeg = snake[i + 1]
                local nextSeg = snake[i - 1]
                local rotation = getSegmentRotation(segment, prevSeg, nextSeg)
                
                local imgWidth = img:getWidth() or 1
                local imgHeight = img:getHeight() or 1
                
                -- Draw snake segment with proper rotation and 2x scale
                love.graphics.draw(
                    img, 
                    (segment.x - 0.5) * GRID_SIZE + GRID_SIZE/2, 
                    (segment.y - 0.5) * GRID_SIZE + GRID_SIZE/2, 
                    rotation,
                    GRID_SIZE / imgWidth, 
                    GRID_SIZE / imgHeight,
                    imgWidth / 2,
                    imgHeight / 2
                )
            end
        end
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

-- Handle keyboard input
function playState.keypressed(key)
    -- Restart game when game over
    if gameOver then
        -- Check if the pressed key matches the select binding for keyboard
        if key == inputManager.keyBindings.keyboard.select then
            initGame()
        elseif key == inputManager.keyBindings.keyboard.back then
            -- Return to menu when escape/back is pressed on game over screen
            soundManager.playSound("menuBack")
            love.switchState("menu")
        end
        return
    end
    
    -- Toggle pause or return to menu
    if key == "p" then
        paused = not paused
        return
    elseif key == inputManager.keyBindings.keyboard.back then
        -- Return to menu when escape/back is pressed
        if paused then
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
    end
    
    -- Direction controls (prevent 180-degree turns)
    -- Use the configured keyboard bindings from inputManager
    if key == inputManager.keyBindings.keyboard.up and direction ~= "down" then
        nextDirection = "up"
    elseif key == inputManager.keyBindings.keyboard.down and direction ~= "up" then
        nextDirection = "down"
    elseif key == inputManager.keyBindings.keyboard.left and direction ~= "right" then
        nextDirection = "left"
    elseif key == inputManager.keyBindings.keyboard.right and direction ~= "left" then
        nextDirection = "right"
    end
end

-- Handle gamepad input
function playState.gamepadpressed(joystick, button)
    -- Verify inputManager and its properties exist
    if not (inputManager and inputManager.keyBindings and inputManager.keyBindings.gamepad) then
        return
    end
    
    -- Check button mappings from inputManager
    local gb = inputManager.keyBindings.gamepad
    
    -- Restart game when game over
    if gameOver then
        if button == gb.select then
            initGame()
        elseif button == gb.back then
            -- Return to menu when back is pressed on game over screen
            soundManager.playSound("menuBack")
            love.switchState("menu")
        end
        return
    end
    
    -- Toggle pause or return to menu
    if button == gb.back then
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
    end
    
    -- Direction controls (prevent 180-degree turns)
    if button == gb.up and direction ~= "down" then
        nextDirection = "up"
    elseif button == gb.down and direction ~= "up" then
        nextDirection = "down"
    elseif button == gb.left and direction ~= "right" then
        nextDirection = "left"
    elseif button == gb.right and direction ~= "left" then
        nextDirection = "right"
    end
end

return playState
