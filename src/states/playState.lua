-- Play State
local love = require("love")
local Button = require "src.ui.button"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"

local playState = {}

local buttons = {}
local messageFont = nil

-- Store current transform for consistent UI layout
local currentScale = 1
local currentOffsetX = 0
local currentOffsetY = 0
local baseScreenWidth = 1280
local baseScreenHeight = 720

local function recalculateLayout(w, h, scale, offsetX, offsetY)
    currentScale = scale
    currentOffsetX = offsetX
    currentOffsetY = offsetY
      -- Get the virtual canvas size properly
    local _, _, _, vWidth, vHeight = love.getScreenTransform()
    baseScreenWidth = vWidth or 1280  -- Fallback if not available
    baseScreenHeight = vHeight or 720 -- Fallback if not available

    messageFont = fontManager.getFont(20) -- Font sized for virtual canvas

    buttons = {}

    -- Create back button (position relative to virtual canvas)
    local buttonWidth = 150 -- Base width for virtual canvas
    local buttonHeight = 40 -- Base height for virtual canvas

    table.insert(buttons, Button.new(
        20, -- Position on the virtual canvas
        20, -- Position on the virtual canvas
        buttonWidth,
        buttonHeight,        gameState.getText("back"),
        function()
            soundManager.playSound("menuBack")
            love.switchState("menu")
        end,
        currentScale -- Pass scale to button for detail scaling
    ))
end

function playState.init(w, h, scale, offsetX, offsetY)
    recalculateLayout(w, h, scale, offsetX, offsetY)
end

function playState.resize(w, h, scale, offsetX, offsetY)
    -- Get the actual virtual canvas dimensions from the transform
    local s, ox, oy, baseWidth, baseHeight = love.getScreenTransform()
    recalculateLayout(baseWidth, baseHeight, s, ox, oy)
end

function playState.update(dt, scale) -- Receive scale from main
    -- Update buttons
    for _, button in ipairs(buttons) do
        button:update(dt, scale) -- Pass scale to button's update
    end

    -- Here you would put your game logic, potentially using scale for positioning or physics
end

function playState.draw()
    -- Background color is set in main.lua's draw before the transform

    -- Draw a simple message (positioned on the virtual canvas)
    love.graphics.setFont(messageFont)
    love.graphics.setColor(1, 1, 1, 1)
    local message = "This is where your game would go!"
    local messageWidth = messageFont and messageFont:getWidth(message) or 0
    
    -- Always center based on the virtual canvas dimensions
    local _, _, _, vWidth, vHeight = love.getScreenTransform()
    local centerX = vWidth / 2
    local centerY = vHeight / 2
    
    love.graphics.print(
        message,
        centerX - messageWidth / 2, -- Center horizontally on virtual canvas
        centerY -- Center vertically on virtual canvas
    )

    -- Draw buttons
    for _, button in ipairs(buttons) do
        button:draw() -- Button's draw method should handle its own scaling
    end
end

function playState.mousepressed(x, y, button)
    -- x, y are already transformed by main.lua
    if button == 1 then  -- Left mouse button
        for _, btn in ipairs(buttons) do
            btn:click(x, y) -- Pass transformed coordinates
        end
    end
end

return playState
