-- Settings Menu State
local Button = require "src.states.button"
local Slider = require "src.states.slider"
local Dropdown = require "src.states.dropdown"
local gameState = require "src.states.gameState"
local fontManager = require "src.fontManager"

local settingsState = {}

local buttons = {}
local sliders = {}
local dropdowns = {}
local titleFont = nil
local regularFont = nil

-- Local copy of settings for editing
local tempSettings = {}

function settingsState.init()
    -- Load fonts with Unicode support
    titleFont = fontManager.getFont(30)
    regularFont = fontManager.getFont(16)
    
    -- Make a copy of current settings
    tempSettings = {}
    for k, v in pairs(gameState.settings) do
        if type(v) == "table" then
            -- Deep copy for nested tables
            tempSettings[k] = {}
            for k2, v2 in pairs(v) do
                tempSettings[k][k2] = v2
            end
        else
            tempSettings[k] = v
        end
    end
    
    -- Create UI elements
    settingsState.createUI()
end

function settingsState.createUI()    -- Calculate positions
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local centerX = width / 2
    local startY = 120
    local spacing = 100  -- Significantly increased spacing between elements
    
    local controlWidth = 300
    local buttonWidth = 150
    local buttonHeight = 40
    
    -- Clear previous UI elements
    buttons = {}
    sliders = {}
    dropdowns = {}
    
    -- Music volume slider
    table.insert(sliders, Slider.new(
        centerX - controlWidth/2,
        startY,
        controlWidth,
        10,
        0, 1,
        tempSettings.musicVolume,
        gameState.getText("musicVolume"),
        function(value)
            tempSettings.musicVolume = value
        end
    ))
    
    -- Effects volume slider
    table.insert(sliders, Slider.new(
        centerX - controlWidth/2,
        startY + spacing,
        controlWidth,
        10,
        0, 1,
        tempSettings.effectsVolume,
        gameState.getText("effectsVolume"),
        function(value)
            tempSettings.effectsVolume = value
        end
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
    
    -- Create screen size dropdown with direction set to "up" so options appear above
    local screenDropdown = Dropdown.new(
        centerX - controlWidth/2,
        startY + spacing * 2,
        controlWidth,
        30,
        screenOptions,
        selectedScreenIndex,
        gameState.getText("screenSize"),
        function(index, option)
            local selectedSize = gameState.screenSizes[index]
            tempSettings.screenSize.width = selectedSize.width
            tempSettings.screenSize.height = selectedSize.height
        end
    )
    screenDropdown.direction = "up"  -- Set dropdown direction to up
    table.insert(dropdowns, screenDropdown)    -- Language dropdown
    local languageOptions = {}
    local selectedLangIndex = 1
    local languages = {
        { code = "en", name = "English" },
        { code = "zh", name = "中文 (Chinese)" },
        { code = "hi", name = "हिन्दी (Hindi)" },
        { code = "es", name = "Español (Spanish)" },
        { code = "fr", name = "Français (French)" },
        { code = "ar", name = "العربية (Arabic)" },
        { code = "bn", name = "বাংলা (Bengali)" },
        { code = "pt", name = "Português (Portuguese)" },
        { code = "ru", name = "Русский (Russian)" },
        { code = "ja", name = "日本語 (Japanese)" },
        { code = "ko", name = "한국어 (Korean)" },
        { code = "de", name = "Deutsch (German)" },
        { code = "pl", name = "Polski (Polish)" }
    }
    
    for i, lang in ipairs(languages) do
        table.insert(languageOptions, { label = lang.name, value = lang.code })
        if lang.code == tempSettings.language then
            selectedLangIndex = i
        end
    end    -- Language dropdown with more space at the bottom
    local langDropdown = Dropdown.new(
        centerX - controlWidth/2,
        startY + spacing * 3,
        controlWidth,
        30,
        languageOptions,
        selectedLangIndex,
        gameState.getText("language"),
        function(index, option)
            tempSettings.language = option.value
        end
    )    -- Set the maximum number of visible options
    langDropdown.maxVisibleOptions = 6  -- Show 6 options at a time to fit more languages
    table.insert(dropdowns, langDropdown)
      -- Back button (returns to menu without saving)
    table.insert(buttons, Button.new(
        centerX - buttonWidth - 20,
        height - 40,  -- Moved further down
        buttonWidth,
        buttonHeight,
        gameState.getText("back"),
        function()
            love.switchState("menu")
        end
    ))
    
    -- Apply button (saves settings and returns to menu)
    table.insert(buttons, Button.new(
        centerX + 20,
        height - 40,  -- Moved further down
        buttonWidth,
        buttonHeight,
        gameState.getText("apply"),
        function()
            -- Apply settings from temp settings
            gameState.settings = tempSettings
            gameState.applySettings()
            love.switchState("menu")
        end
    ))
end

function settingsState.update(dt)
    -- Update buttons
    for _, button in ipairs(buttons) do
        button:update(dt)
    end
    
    -- Update sliders
    for _, slider in ipairs(sliders) do
        slider:update(dt)
    end
    
    -- Update dropdowns
    for _, dropdown in ipairs(dropdowns) do
        dropdown:update(dt)
    end
end

function settingsState.draw()
    -- Clear the screen with a nice background
    love.graphics.setBackgroundColor(0.2, 0.2, 0.3)
    
    -- Draw the title
    love.graphics.setFont(titleFont)
    local title = gameState.getText("settings")
    local titleWidth = titleFont:getWidth(title)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        title, 
        love.graphics.getWidth() / 2 - titleWidth / 2,
        40
    )
    
    -- Draw UI elements
    love.graphics.setFont(regularFont)
    
    -- Draw sliders
    for _, slider in ipairs(sliders) do
        slider:draw()
    end
    
    -- Draw buttons first (so dropdowns appear on top)
    for _, button in ipairs(buttons) do
        button:draw()
    end
    
    -- Draw dropdowns last (so they appear on top of everything)
    for _, dropdown in ipairs(dropdowns) do
        dropdown:draw()
    end
end

function settingsState.mousepressed(x, y, button)
    if button == 1 then  -- Left mouse button
        -- Check dropdowns first (give them interaction priority)
        for _, dropdown in ipairs(dropdowns) do
            if dropdown:mousepressed(x, y) then
                return
            end
        end
        
        -- Check sliders
        for _, slider in ipairs(sliders) do
            if slider:mousepressed(x, y) then
                return
            end
        end
        
        -- Check buttons last
        for _, btn in ipairs(buttons) do
            if btn:click(x, y) then
                return
            end
        end
    end
end

function settingsState.mousereleased(x, y, button)
    if button == 1 then  -- Left mouse button
        -- Notify sliders
        for _, slider in ipairs(sliders) do
            slider:mousereleased(x, y)
        end
    end
end

-- Handle mouse wheel for dropdown scrolling
function settingsState.wheelmoved(x, y)
    -- Pass to dropdowns first
    for _, dropdown in ipairs(dropdowns) do
        if dropdown.open and dropdown:wheelmoved(x, y) then
            return
        end
    end
end

return settingsState
