-- Settings Menu State
local Button = require "src.ui.button"
local Slider = require "src.ui.slider"
local Dropdown = require "src.ui.dropdown"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"

local settingsState = {}

local buttons = {}
local sliders = {}
local dropdowns = {}
local titleFont = nil

-- Local copy of settings for editing
local tempSettings = {}

-- Store virtual canvas dimensions and current GUI scale
local virtualWidth = 1280 -- Default, will be updated from init/resize
local virtualHeight = 720 -- Default, will be updated from init/resize
local currentGuiScale = 1 -- Default, will be updated

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

local function recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    -- Always get the actual virtual canvas dimensions from the main transform
    -- This ensures consistent dimensions across all states
    local _, _, _, baseWidth, baseHeight = love.getScreenTransform()
    virtualWidth = baseWidth or vWidth  -- Fallback to parameter if function fails
    virtualHeight = baseHeight or vHeight -- Fallback to parameter if function fails
    currentGuiScale = guiScale

    -- Font sized for virtual canvas - main.lua's transform will scale it on screen
    titleFont = fontManager.getFont(30) -- Base size for virtual canvas

    -- Calculate positions on the virtual canvas
    local centerX = virtualWidth / 2
    local startY = virtualHeight * 0.16 -- Relative positioning
    local spacing = virtualHeight * 0.18

    local controlWidth = virtualWidth * 0.38 -- Relative width
    local buttonWidth = virtualWidth * 0.18
    local buttonHeight = virtualHeight * 0.08
    local controlHeight = virtualHeight * 0.06

    buttons = {}
    sliders = {}
    dropdowns = {}

    -- Music volume slider
    table.insert(sliders, Slider.new(
        centerX - controlWidth / 2,
        startY,
        controlWidth,
        10, -- Visual height of slider track
        0, 1,
        tempSettings.musicVolume,
        gameState.getText("musicVolume"),
        function(value)
            tempSettings.musicVolume = value
        end,
        currentGuiScale
    ))

    -- Effects volume slider
    table.insert(sliders, Slider.new(
        centerX - controlWidth / 2,
        startY + spacing,
        controlWidth,
        10,
        0, 1,
        tempSettings.effectsVolume,
        gameState.getText("effectsVolume"),
        function(value)
            tempSettings.effectsVolume = value
        end,
        currentGuiScale
    ))

    -- Screen size dropdown
    local screenOptions = {}
    local selectedScreenIndex = 1

    for i, size in ipairs(gameState.screenSizes) do
        table.insert(screenOptions, { label = size.label, value = i })
        if size.width == tempSettings.screenSize.width and
           size.height == tempSettings.screenSize.height then
            selectedScreenIndex = i
        end
    end

    local screenDropdown = Dropdown.new(
        centerX - controlWidth / 2,
        startY + spacing * 2,
        controlWidth,
        controlHeight,
        screenOptions,
        selectedScreenIndex,
        gameState.getText("screenSize"),
        function(index, option)
            local selectedSize = gameState.screenSizes[index]
            tempSettings.screenSize.width = selectedSize.width
            tempSettings.screenSize.height = selectedSize.height
        end,
        currentGuiScale
    )
    screenDropdown.direction = "up"
    table.insert(dropdowns, screenDropdown)

    -- Language dropdown
    local languageOptions = {}
    local selectedLangIndex = 1
    local languages = gameState.getAvailableLanguages()

    for i, lang in ipairs(languages) do
        table.insert(languageOptions, { label = lang.name, value = lang.code })
        if lang.code == tempSettings.language then
            selectedLangIndex = i
        end
    end

    local langDropdown = Dropdown.new(
        centerX - controlWidth / 2,
        startY + spacing * 3,
        controlWidth,
        controlHeight,
        languageOptions,
        selectedLangIndex,
        gameState.getText("language"),
        function(index, option)
            tempSettings.language = option.value
        end,
        currentGuiScale
    )
    langDropdown.maxVisibleOptions = 6
    table.insert(dropdowns, langDropdown)

    -- Back button (returns to menu without saving)
    table.insert(buttons, Button.new(
        centerX - buttonWidth - 20,
        virtualHeight - buttonHeight - 20,
        buttonWidth,
        buttonHeight,
        gameState.getText("back"),
        function()
            love.switchState("menu")
        end,
        currentGuiScale
    ))

    -- Apply button (saves settings and returns to menu)
    table.insert(buttons, Button.new(
        centerX + 20,
        virtualHeight - buttonHeight - 20,
        buttonWidth,
        buttonHeight,
        gameState.getText("apply"),
        function()
            gameState.settings = deepcopy(tempSettings)
            gameState.applySettings()
            love.switchState("menu")
        end,
        currentGuiScale
    ))
end

function settingsState.init(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    tempSettings = deepcopy(gameState.settings)
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
end

function settingsState.resize(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    -- Always use the main virtual canvas dimensions to ensure consistency
    local _, _, _, baseWidth, baseHeight = love.getScreenTransform()
    virtualWidth = baseWidth
    virtualHeight = baseHeight
    recalculateLayout(virtualWidth, virtualHeight, guiScale, guiOffsetX, guiOffsetY)
end

function settingsState.update(dt, guiScale)
    for _, button in ipairs(buttons) do
        button:update(dt, guiScale)
    end
    for _, slider in ipairs(sliders) do
        slider:update(dt, guiScale)
    end
    for _, dropdown in ipairs(dropdowns) do
        dropdown:update(dt, guiScale)
    end
end

function settingsState.draw()
    -- Draw title centered on the virtual canvas
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1, 1)
    local settingsText = gameState.getText("settings")
    local titleW = titleFont:getWidth(settingsText)
    love.graphics.print(settingsText, virtualWidth / 2 - titleW / 2, virtualHeight * 0.06)

    -- Draw UI components
    for _, button in ipairs(buttons) do
        button:draw()
    end
    for _, slider in ipairs(sliders) do
        slider:draw()
    end
    for _, dropdown in ipairs(dropdowns) do
        dropdown:draw()
    end
end

function settingsState.mousepressed(x, y, button)
    -- x and y are already transformed to virtual canvas coordinates by main.lua
    if button == 1 then -- Left mouse button
        -- Check if any dropdown is open first
        local anyDropdownOpen = false
        for _, dropdown in ipairs(dropdowns) do
            if dropdown.open then
                anyDropdownOpen = true
                -- If a dropdown is open and we click on it, handle the click
                if dropdown:mousepressed(x, y) then 
                    return 
                end
            end
        end
        
        -- If any dropdown is open, clicks should only affect dropdowns
        if anyDropdownOpen then
            -- Check if click is outside all dropdowns - close them if so
            local clickedOutside = true
            for _, dropdown in ipairs(dropdowns) do
                if dropdown:isMouseOver(x, y) then
                    clickedOutside = false
                    break
                end
            end
              if clickedOutside then
                -- Close all dropdowns when clicking elsewhere
                for _, dropdown in ipairs(dropdowns) do
                    dropdown:close()
                end
            end
            return
        end
        
        -- Normal click processing when no dropdowns are open
        for _, btn in ipairs(buttons) do
            if btn:click(x, y) then return end -- If click handled, exit
        end
        for _, slider in ipairs(sliders) do
            if slider:mousepressed(x, y) then return end
        end
        for _, dropdown in ipairs(dropdowns) do
            if dropdown:mousepressed(x, y) then return end
        end
    end
end

function settingsState.mousereleased(x, y, button)
    -- x and y are already transformed to virtual canvas coordinates by main.lua
    if button == 1 then -- Left mouse button
        -- Check if any dropdown is open first
        local anyDropdownOpen = false
        for _, dropdown in ipairs(dropdowns) do
            if dropdown.open then
                anyDropdownOpen = true
                break
            end
        end
        
        -- Only process slider releases if no dropdown is open
        if not anyDropdownOpen then
            for _, slider in ipairs(sliders) do
                slider:mousereleased(x, y)
            end
        end
        -- Dropdowns handle their own state on press
    end
end

function settingsState.wheelmoved(x_delta, y_delta, rawMousePos)
    -- Get raw mouse coordinates
    local mx, my
    if rawMousePos then
        -- If rawMousePos was passed as a single value
        mx, my = rawMousePos, nil
    else
        -- Get current mouse position if not provided
        mx, my = love.mouse.getPosition()
    end
    
    -- Check if any dropdown is open
    local anyDropdownOpen = false
    for _, dropdown in ipairs(dropdowns) do
        if dropdown.open then
            anyDropdownOpen = true
            -- If a dropdown is open, prioritize it for wheel movement
            if dropdown:wheelmoved(x_delta, y_delta, mx, my) then
                return
            end
        end
    end
    
    -- If no dropdown is open, or open dropdowns didn't handle the wheel,
    -- process as normal for all dropdowns
    if not anyDropdownOpen then
        for _, dropdown in ipairs(dropdowns) do
            if dropdown:wheelmoved(x_delta, y_delta, mx, my) then 
                return 
            end
        end
    end
end

return settingsState
