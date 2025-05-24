-- Snake Entity
local love = require("love")
local gameConfig = require("src.constants.gameConfig")

local Snake = {}
Snake.__index = Snake

function Snake.new(gridWidth, gridHeight, gridSize, initialLength)
    local self = setmetatable({}, Snake)
    
    self.gridWidth = gridWidth
    self.gridHeight = gridHeight
    self.gridSize = gridSize
    self.initialLength = initialLength or gameConfig.SNAKE.INITIAL_LENGTH
    
    -- Snake body segments
    self.segments = {}
    self.direction = "right"
    self.nextDirection = "right"
    
    -- Images for rendering
    self.headImage = nil
    self.bodyImage = nil
    self.tailImage = nil
    
    self:init()
    
    return self
end

function Snake:init()
    -- Reset snake state
    self.segments = {}
    self.direction = "right"
    self.nextDirection = "right"
    
    -- Create the snake with initial length
    local startX = math.floor(self.gridWidth / 4)
    local startY = math.floor(self.gridHeight / 2)
    
    -- Create head
    self.segments[1] = {x = startX, y = startY, type = "head"}
    
    -- Create initial body segments
    for i = 1, self.initialLength do
        self.segments[i+1] = {x = startX - i, y = startY, type = "body"}
    end
    
    -- Set the last segment as tail
    if #self.segments > 1 then
        self.segments[#self.segments].type = "tail"
    end
end

function Snake:setImages(headImage, bodyImage, tailImage)
    self.headImage = headImage
    self.bodyImage = bodyImage
    self.tailImage = tailImage
end

function Snake:setDirection(direction)
    -- Prevent 180-degree turns
    if direction == "up" and self.direction ~= "down" then
        self.nextDirection = "up"
    elseif direction == "down" and self.direction ~= "up" then
        self.nextDirection = "down"
    elseif direction == "left" and self.direction ~= "right" then
        self.nextDirection = "left"
    elseif direction == "right" and self.direction ~= "left" then
        self.nextDirection = "right"
    end
end

function Snake:move()
    -- Update direction based on nextDirection
    self.direction = self.nextDirection
    
    -- Check if snake has a head
    if #self.segments < 1 then
        return false
    end
    
    -- Calculate new head position
    local newHead = {x = self.segments[1].x, y = self.segments[1].y, type = "head"}
    
    if self.direction == "up" then
        newHead.y = newHead.y - 1
    elseif self.direction == "down" then
        newHead.y = newHead.y + 1
    elseif self.direction == "left" then
        newHead.x = newHead.x - 1
    elseif self.direction == "right" then
        newHead.x = newHead.x + 1
    end
    
    -- Check for collision with walls
    if newHead.x < 1 or newHead.x > self.gridWidth or newHead.y < 1 or newHead.y > self.gridHeight then
        return false -- Collision with wall
    end
    
    -- Check for collision with self
    for i = 1, #self.segments - 1 do
        if self.segments[i] and newHead.x == self.segments[i].x and newHead.y == self.segments[i].y then
            return false -- Collision with self
        end
    end
    
    -- Insert new head at beginning
    table.insert(self.segments, 1, newHead)
    
    return newHead -- Return new head position for collision checking
end

function Snake:grow()
    -- Don't remove the tail when growing
    self:updateSegmentTypes()
end

function Snake:removeTail()
    -- Remove the tail segment
    table.remove(self.segments)
    self:updateSegmentTypes()
end

function Snake:updateSegmentTypes()
    if #self.segments == 0 then return end
    
    -- First segment is always the head
    self.segments[1].type = "head"
    
    -- Middle segments are body
    for i = 2, #self.segments - 1 do
        if self.segments[i] then
            self.segments[i].type = "body"
        end
    end
    
    -- Last segment is always the tail
    if #self.segments > 1 then
        self.segments[#self.segments].type = "tail"
    end
end

function Snake:checkCollisionWithPoint(x, y)
    for _, segment in ipairs(self.segments) do
        if segment.x == x and segment.y == y then
            return true
        end
    end
    return false
end

function Snake:getHeadPosition()
    if #self.segments > 0 then
        return self.segments[1].x, self.segments[1].y
    end
    return nil, nil
end

function Snake:getLength()
    return #self.segments
end

-- Calculate rotation angle for a snake segment based on direction
function Snake:getSegmentRotation(segment, prevSegment, nextSegment)
    if not segment then return 0 end
    if segment.type == "head" then
        -- Head rotation based on movement direction
        if self.direction == "up" then return 0            -- Head points up
        elseif self.direction == "down" then return math.pi            -- Head points down
        elseif self.direction == "left" then return -math.pi/2    -- Head points left
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

function Snake:draw()
    if not self.segments then return end
    
    love.graphics.setColor(1, 1, 1, 1)
    for i, segment in ipairs(self.segments) do
        local img = nil
        
        if segment.type == "head" and self.headImage then
            img = self.headImage
        elseif segment.type == "tail" and self.tailImage then
            img = self.tailImage
        elseif self.bodyImage then
            img = self.bodyImage
        end
        
        if img then
            local prevSeg = self.segments[i + 1]
            local nextSeg = self.segments[i - 1]
            local rotation = self:getSegmentRotation(segment, prevSeg, nextSeg)
            
            local imgWidth = img:getWidth() or 1
            local imgHeight = img:getHeight() or 1
            
            -- Draw snake segment with proper rotation and 2x scale
            love.graphics.draw(
                img, 
                (segment.x - 0.5) * self.gridSize + self.gridSize/2, 
                (segment.y - 0.5) * self.gridSize + self.gridSize/2, 
                rotation,
                self.gridSize / imgWidth, 
                self.gridSize / imgHeight,
                imgWidth / 2,
                imgHeight / 2
            )
        end
    end
end

return Snake
