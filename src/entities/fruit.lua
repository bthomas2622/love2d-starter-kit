-- Fruit Entity
local love = require("love")

local Fruit = {}
Fruit.__index = Fruit

function Fruit.new(gridWidth, gridHeight, gridSize)
    local self = setmetatable({}, Fruit)
    
    self.gridWidth = gridWidth
    self.gridHeight = gridHeight
    self.gridSize = gridSize
    self.x = 1
    self.y = 1
    self.image = nil
    
    return self
end

function Fruit:setImage(image)
    self.image = image
end

function Fruit:spawn(snake)
    local valid = false
    local newX, newY
    
    while not valid do
        -- Generate random position within grid
        newX = love.math.random(1, self.gridWidth)
        newY = love.math.random(1, self.gridHeight)
        
        -- Check if position collides with snake
        valid = true
        if snake and snake.checkCollisionWithPoint then
            if snake:checkCollisionWithPoint(newX, newY) then
                valid = false
            end
        end
    end
    
    self.x = newX
    self.y = newY
end

function Fruit:getPosition()
    return self.x, self.y
end

function Fruit:checkCollisionWithPoint(x, y)
    return self.x == x and self.y == y
end

function Fruit:draw()
    if not self.image then return end
    
    love.graphics.setColor(1, 1, 1, 1)
    local fruitWidth = self.image:getWidth() or 1
    local fruitHeight = self.image:getHeight() or 1
    
    -- Scale fruit image to fit grid
    love.graphics.draw(
        self.image, 
        (self.x - 0.5) * self.gridSize, 
        (self.y - 0.5) * self.gridSize, 
        0, 
        self.gridSize / fruitWidth, 
        self.gridSize / fruitHeight
    )
end

return Fruit
