-- Settings Menu State
local love = require("love")
local Button = require "src.ui.button"
local Slider = require "src.ui.slider"
local Dropdown = require "src.ui.dropdown"
local gameState = require "src.states.gameState"
local fontManager = require "src.utils.fontManager"
local soundManager = require "src.utils.soundManager"

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
    titleFont = fontManager.getFont(30) -- Base size for virtual canvas    -- Calculate positions on the virtual canvas
    local centerX = virtualWidth / 2
    local startY = virtualHeight * 0.14 -- Slightly reduced starting position
    local spacing = virtualHeight * 0.15 -- Reduced spacing for more compact layout

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
        0, 1,        tempSettings.musicVolume,
        gameState.getText("musicVolume"),
        function(value)
            tempSettings.musicVolume = value
            soundManager.updateVolumesNow(tempSettings.musicVolume, nil) -- Apply volume change immediately
        end,
        currentGuiScale
    ))

    -- Effects volume slider
    table.insert(sliders, Slider.new(
        centerX - controlWidth / 2,
        startY + spacing,
        controlWidth,
        10,
        0, 1,        tempSettings.effectsVolume,
        gameState.getText("effectsVolume"),
        function(value)
            tempSettings.effectsVolume = value
            soundManager.updateVolumesNow(nil, tempSettings.effectsVolume) -- Apply volume change immediately
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
        startY + spacing * 2 - 30,
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
        startY + spacing * 3 - 30,
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
    langDropdown.maxVisibleOptions = 6    table.insert(dropdowns, langDropdown)    -- Controls button - positioned directly below the language dropdown with minimal spacing
    table.insert(buttons, Button.new(
        centerX - buttonWidth / 2,
        startY + spacing * 3 + controlHeight * 2, -- Reduced spacing between language dropdown and controls button
        buttonWidth,
        buttonHeight,
        gameState.getText("controls"),
        function()
            love.switchState("controls")
        end,
        currentGuiScale
    ))-- Back button (returns to menu without saving)
    table.insert(buttons, Button.new(
        centerX - buttonWidth - 20,
        virtualHeight - buttonHeight - 20, -- Keep at bottom of screen
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
        virtualHeight - buttonHeight - 20, -- Keep at bottom of screen
        buttonWidth,
        buttonHeight,
        gameState.getText("apply"),        function()
            gameState.settings = deepcopy(tempSettings)
            gameState.applySettings()
            soundManager.updateVolumes() -- Update volumes with final settings
            love.switchState("menu")
        end,
        currentGuiScale
    ))
end

function settingsState.init(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    tempSettings = deepcopy(gameState.settings)
    recalculateLayout(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    -- Initialize selection to first slider
    settingsState.selectedElement = {type = "slider", index = 1}
end

function settingsState.resize(vWidth, vHeight, guiScale, guiOffsetX, guiOffsetY)
    -- Always use the main virtual canvas dimensions to ensure consistency
    local _, _, _, baseWidth, baseHeight = love.getScreenTransform()
    virtualWidth = baseWidth
    virtualHeight = baseHeight
    recalculateLayout(virtualWidth, virtualHeight, guiScale, guiOffsetX, guiOffsetY)
end

function settingsState.update(dt, guiScale)
    -- Get input manager for navigation
    local inputManager = require "src.utils.inputManager"
    inputManager.update(dt)
    
    -- Initialize current selection if needed
    if not settingsState.selectedElement then
        settingsState.selectedElement = {type = "slider", index = 1}
    end
    
    -- Check if any dropdown is open
    local anyDropdownOpen = false
    for _, dropdown in ipairs(dropdowns) do
        if dropdown.open then
            anyDropdownOpen = true
            break
        end
    end
    
    -- Disable buttons if any dropdown is open
    for _, button in ipairs(buttons) do
        button.disabled = anyDropdownOpen
    end
    
    -- If a button is selected but dropdowns are open, deselect it
    if anyDropdownOpen and settingsState.selectedElement and settingsState.selectedElement.type == "button" then
        -- Find closest dropdown to select instead
        settingsState.selectedElement = {type = "dropdown", index = #dropdowns}
    end
    
    -- Update UI elements
    for _, button in ipairs(buttons) do
        button:update(dt, guiScale)
    end
    for _, slider in ipairs(sliders) do
        slider:update(dt, guiScale)
    end
    for _, dropdown in ipairs(dropdowns) do
        dropdown:update(dt, guiScale)
    end
    
    -- Check if any dropdown is open - restrict movement when dropdown is open
    for _, dropdown in ipairs(dropdowns) do
        if dropdown.open then
            -- Handle dropdown navigation
            if inputManager.isActionJustPressed("up") then
                dropdown:selectPrevious()
                soundManager.playSound("menuMove")
                return
            elseif inputManager.isActionJustPressed("down") then
                dropdown:selectNext()
                soundManager.playSound("menuMove")
                return
            elseif inputManager.isActionJustPressed("select") then
                dropdown:selectCurrent()
                soundManager.playSound("menuSelect")
                return
            elseif inputManager.isActionJustPressed("back") then
                dropdown:close()
                soundManager.playSound("menuBack")
                return
            end
        end
    end

    -- Mouse hover selection logic (only if no dropdown is open)
    if not anyDropdownOpen then
        local rawMx, rawMy = love.mouse.getPosition()
        local currentMainScale, offsetX, offsetY = love.getScreenTransform()

        local mx = rawMx
        local my = rawMy

        if currentMainScale and currentMainScale ~= 0 then
            mx = (rawMx - offsetX) / currentMainScale
            my = (rawMy - offsetY) / currentMainScale
        else
            -- If scale is 0 or nil, cannot accurately determine hover, so skip hover update
            return
        end

        local hovered = nil
        -- Check dropdowns first (topmost)
        for i, dropdown in ipairs(dropdowns) do
            if dropdown:isMouseOver(mx, my) then
                hovered = {type = "dropdown", index = i}
                break
            end
        end
        -- Check buttons if not already hovering a dropdown
        if not hovered then
            for i, button in ipairs(buttons) do
                if not button.disabled and mx >= button.x and mx <= button.x + button.width and my >= button.y and my <= button.y + button.height then
                    hovered = {type = "button", index = i}
                    break
                end
            end
        end
        -- Check sliders if not already hovering something else
        if not hovered then
            for i, slider in ipairs(sliders) do
                if slider:isMouseOver(mx, my) then
                    hovered = {type = "slider", index = i}
                    break
                end
            end
        end
        -- If hovered element is different from selected, update selection
        if hovered and (not settingsState.selectedElement or hovered.type ~= settingsState.selectedElement.type or hovered.index ~= settingsState.selectedElement.index) then
            settingsState.selectedElement = hovered
        end
    end
    
    if not anyDropdownOpen then
        -- Handle keyboard/gamepad navigation between elements
        local selectedChanged = false
        
        if inputManager.isActionJustPressed("up") then
            if settingsState.selectedElement.type == "slider" and settingsState.selectedElement.index > 1 then
                settingsState.selectedElement.index = settingsState.selectedElement.index - 1
                selectedChanged = true
            elseif settingsState.selectedElement.type == "dropdown" and settingsState.selectedElement.index > 1 then
                settingsState.selectedElement.index = settingsState.selectedElement.index - 1
                selectedChanged = true
            elseif settingsState.selectedElement.type == "button" and (settingsState.selectedElement.index == 2 or settingsState.selectedElement.index == 3) then
                -- If Back or Apply button is selected, move up to Controls button
                settingsState.selectedElement = {type = "button", index = 1}
                selectedChanged = true
            elseif settingsState.selectedElement.type == "button" and settingsState.selectedElement.index == 1 then
                settingsState.selectedElement = {type = "dropdown", index = #dropdowns}
                selectedChanged = true
            elseif settingsState.selectedElement.type == "dropdown" and settingsState.selectedElement.index == 1 then
                settingsState.selectedElement = {type = "slider", index = #sliders}
                selectedChanged = true
            end
        elseif inputManager.isActionJustPressed("down") then
            if settingsState.selectedElement.type == "slider" and settingsState.selectedElement.index < #sliders then
                settingsState.selectedElement.index = settingsState.selectedElement.index + 1
                selectedChanged = true
            elseif settingsState.selectedElement.type == "slider" and settingsState.selectedElement.index == #sliders then
                settingsState.selectedElement = {type = "dropdown", index = 1}
                selectedChanged = true
            elseif settingsState.selectedElement.type == "dropdown" and settingsState.selectedElement.index < #dropdowns then
                settingsState.selectedElement.index = settingsState.selectedElement.index + 1
                selectedChanged = true
            elseif settingsState.selectedElement.type == "dropdown" and settingsState.selectedElement.index == #dropdowns then
                settingsState.selectedElement = {type = "button", index = 1}
                selectedChanged = true
            elseif settingsState.selectedElement.type == "button" and settingsState.selectedElement.index == 1 then
                -- If the Controls button (index 1) is selected, move to the Back button (index 2)
                settingsState.selectedElement = {type = "button", index = 2}
                selectedChanged = true
            end
        elseif inputManager.isActionJustPressed("left") then
            if settingsState.selectedElement.type == "slider" then
                local slider = sliders[settingsState.selectedElement.index]
                if slider and slider.setValue then
                    slider:setValue(slider.value - ((slider.max or 1) - (slider.min or 0)) / 20)
                elseif slider then
                    -- fallback: direct assignment if setValue is missing
                    slider.value = math.max((slider.min or 0), slider.value - ((slider.max or 1) - (slider.min or 0)) / 20)
                    if slider.onChange then slider.onChange(slider.value) end
                end
            elseif settingsState.selectedElement.type == "button" and settingsState.selectedElement.index == 3 then
                -- From Apply button (index 3) to Back button (index 2)
                settingsState.selectedElement.index = 2
                selectedChanged = true
            end
        elseif inputManager.isActionJustPressed("right") then
            if settingsState.selectedElement.type == "slider" then
                local slider = sliders[settingsState.selectedElement.index]
                if slider and slider.setValue then
                    local range = (slider.max or 1) - (slider.min or 0)
                    slider:setValue(slider.value + range / 20)
                elseif slider then
                    -- fallback: direct assignment if setValue is missing
                    local range = (slider.max or 1) - (slider.min or 0)
                    slider.value = math.min((slider.max or 1), slider.value + range / 20)
                    if slider.onChange then slider.onChange(slider.value) end
                end
            elseif settingsState.selectedElement.type == "button" and settingsState.selectedElement.index == 1 then
                settingsState.selectedElement.index = 2
                selectedChanged = true
            elseif settingsState.selectedElement.type == "button" and settingsState.selectedElement.index == 2 then
                -- From Back button (index 2) to Apply button (index 3)
                settingsState.selectedElement.index = 3
                selectedChanged = true
            end
        elseif inputManager.isActionJustPressed("select") then
            -- Activate the selected element
            if settingsState.selectedElement.type == "button" then
                buttons[settingsState.selectedElement.index]:click()
            elseif settingsState.selectedElement.type == "dropdown" then
                local dropdown = dropdowns[settingsState.selectedElement.index]
                if dropdown and not dropdown.open then
                    dropdown:toggle()
                    soundManager.playSound("menuSelect")
                end
            end
        elseif inputManager.isActionJustPressed("back") then
            love.switchState("menu")
            soundManager.playSound("menuBack")
        end
        
        if selectedChanged then
            soundManager.playSound("menuMove")
        end
    end
end

function settingsState.draw()
    -- Draw title centered on the virtual canvas
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1, 1)
    local settingsText = gameState.getText("settings")
    local titleW = titleFont and titleFont:getWidth(settingsText) or 0
    love.graphics.print(settingsText, virtualWidth / 2 - titleW / 2, virtualHeight * 0.06)

    -- Check if any dropdowns are open
    local anyDropdownOpen = false
    for _, dropdown in ipairs(dropdowns) do
        if dropdown.open then
            anyDropdownOpen = true
            break
        end
    end
    
    -- Disable buttons if any dropdown is open
    for _, button in ipairs(buttons) do
        button.disabled = anyDropdownOpen
    end

    -- Draw UI components with highlighting based on selection - draw sliders first
    for i, slider in ipairs(sliders) do
        if settingsState.selectedElement and settingsState.selectedElement.type == "slider" and settingsState.selectedElement.index == i then
            -- Highlight the selected slider
            love.graphics.setColor(0.8, 0.8, 1.0, 0.3)
            love.graphics.rectangle("fill", slider.x - 10, slider.y - 10, 
                                    slider.width + 20, slider.height + 30)
            love.graphics.setColor(1, 1, 1, 1)
        end
        slider:draw()
    end
    
    -- Draw buttons second
    for i, button in ipairs(buttons) do
        -- Highlight the selected button
        if not anyDropdownOpen and settingsState.selectedElement and settingsState.selectedElement.type == "button" and settingsState.selectedElement.index == i then
            local originalHoverColor = button.hoverColor
            button.hoverColor = {0.7, 0.7, 1.0, 1.0}
            button.hovered = true
            button:draw()
            button.hoverColor = originalHoverColor
            button.hovered = false
        else
            button:draw()
        end
    end
    
    -- Draw dropdowns last so they appear on top of everything
    for i, dropdown in ipairs(dropdowns) do
        if settingsState.selectedElement and settingsState.selectedElement.type == "dropdown" and settingsState.selectedElement.index == i and not dropdown.open then
            -- Highlight the selected dropdown
            love.graphics.setColor(0.8, 0.8, 1.0, 0.3)
            love.graphics.rectangle("fill", dropdown.x - 10, dropdown.y - 10, 
                                    dropdown.width + 20, dropdown.height + 20)
            love.graphics.setColor(1, 1, 1, 1)
        end
        dropdown:draw()
    end
end

function settingsState.mousepressed(x, y, button)
    -- x and y are already transformed to virtual canvas coordinates by main.lua
    if button == 1 then -- Left mouse button
        -- Check if any dropdown is open first
        local anyDropdownOpen = false
        for i, dropdown in ipairs(dropdowns) do
            if dropdown.open then
                anyDropdownOpen = true
                -- If a dropdown is open and we click on it, handle the click
                if dropdown:mousepressed(x, y) then 
                    settingsState.selectedElement = {type = "dropdown", index = i}
                    return 
                end
            end
        end

        -- If any dropdown is open, clicks should only affect dropdowns
        if anyDropdownOpen then
            -- Check if click is outside all dropdowns - close them if so
            local clickedOutside = true
            for _, dropdown in ipairs(dropdowns) do
                if dropdown.isMouseOver and dropdown:isMouseOver(x, y) then
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
        -- Check sliders
        for i, slider in ipairs(sliders) do
            if slider:click(x, y) then
                settingsState.selectedElement = {type = "slider", index = i}
                return
            end
        end
        
        -- Check dropdowns
        for i, dropdown in ipairs(dropdowns) do
            if dropdown:click(x, y) then
                settingsState.selectedElement = {type = "dropdown", index = i}
                return
            end
        end
        
        -- Check buttons - buttons respect their own disabled state
        for i, btn in ipairs(buttons) do
            if not btn.disabled and btn:click(x, y) then
                settingsState.selectedElement = {type = "button", index = i}
                return
            end
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

function settingsState.keypressed(key)
    -- If a dropdown is open, send key to it
    for _, dropdown in ipairs(dropdowns) do
        if dropdown.open then
            if dropdown.keypressed then
                dropdown:keypressed(key)
            end
            return
        end
    end
end

return settingsState
