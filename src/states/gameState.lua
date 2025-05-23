-- Game state management
local love = require("love")
local gameConfig = require("src.constants.gameConfig")
local localization = require("src.utils.localization")
local gameState = {}

-- Default settings
gameState.settings = gameConfig.DEFAULT_SETTINGS

-- Screen sizes available in settings
gameState.screenSizes = gameConfig.SCREEN_SIZES

-- Get a formatted list of available languages for UI
function gameState.getAvailableLanguages()
    return localization.getAvailableLanguages()
end

-- Return the text in the current language
function gameState.getText(key)
    return localization.getText(key, gameState.settings.language)
end

-- Check if current language is RTL (right-to-left)
function gameState.isRTL()
    return localization.isRTL(gameState.settings.language)
end

-- Save settings to a file using Lua's native serialization
function gameState.save()
    -- Convert settings to a Lua string representation
    local serialized = "return " .. serializeTable(gameState.settings)
    
    -- Print the path where settings are being saved
    local path = love.filesystem.getSaveDirectory()
    print("Saving settings to: " .. path .. "/settings.lua")
    
    local success = love.filesystem.write("settings.lua", serialized)
    if not success then
        print("Error: Failed to write settings to file")
    else
        print("Settings saved successfully!")
        -- Print first few characters of serialized data
        if serialized and #serialized > 0 then
            print("First 100 characters of saved data: " .. string.sub(serialized, 1, 100))
        end
    end
end

-- Helper function to serialize a table to a string
function serializeTable(val, indent)
    indent = indent or ""
    local result
    
    if type(val) == "table" then
        result = "{\n"
        for k, v in pairs(val) do
            local keyStr
            if type(k) == "string" then
                keyStr = "[\"" .. k .. "\"]"
            else
                keyStr = "[" .. tostring(k) .. "]"
            end
            
            result = result .. indent .. "    " .. keyStr .. " = " .. serializeTable(v, indent .. "    ") .. ",\n"
        end
        result = result .. indent .. "}"
    elseif type(val) == "string" then
        result = "\"" .. string.gsub(val, "\"", "\\\"") .. "\""
    elseif type(val) == "number" or type(val) == "boolean" then
        result = tostring(val)
    elseif val == nil then
        result = "nil"
    else
        result = "\"" .. tostring(val) .. "\""
    end
    
    return result
end

-- Alias for save to make code more intuitive
function gameState.saveSettings()
    gameState.save()
end

-- Load settings from a file
function gameState.load()
    -- Check for the new Lua format settings file first
    if love.filesystem.getInfo("settings.lua") then
        local status, loadedSettings = pcall(function()
            local chunk = love.filesystem.load("settings.lua")
            if chunk then
                return chunk()
            end
            return nil
        end)
        
        if status and type(loadedSettings) == "table" then
            -- Update settings with loaded values
            for k, v in pairs(loadedSettings) do
                -- Ensure we only apply valid settings
                if gameState.settings[k] ~= nil then
                    -- Ensure screenSize is properly structured
                    if k == "screenSize" and type(v) == "table" then
                        if v.width and v.height then
                            gameState.settings.screenSize.width = v.width
                            gameState.settings.screenSize.height = v.height
                        end
                    else
                        gameState.settings[k] = v
                    end
                end
            end
              -- Verify language is valid
            if not localization.languages[gameState.settings.language] then
                print("Warning: Invalid language setting detected, resetting to English")
                gameState.settings.language = "en"
            end
            
            -- Apply screen size
            love.window.setMode(
                gameState.settings.screenSize.width, 
                gameState.settings.screenSize.height, 
                {resizable = true}
            )
        else
            local errorMsg = type(loadedSettings) == "string" and loadedSettings or "Unknown error"
            print("Error: Failed to load settings. " .. errorMsg)
            -- Delete the corrupt settings file
            love.filesystem.remove("settings.lua")
        end
    -- Legacy JSON format support - Try to handle old settings files
    elseif love.filesystem.getInfo("settings.json") then
        print("Found legacy settings.json. Migrating to new format...")
        -- Just delete the old file and start fresh
        love.filesystem.remove("settings.json")
    end
end

-- Apply current settings to the game
function gameState.applySettings()
    -- Apply screen size
    love.window.setMode(
        gameState.settings.screenSize.width, 
        gameState.settings.screenSize.height, 
        {resizable = true}
    )
    
    -- Update the screen transform to ensure scaling works properly
    if love.graphics then
        -- Manually trigger the same behavior as in the resize callback
        if love.updateScreenTransform then
            love.updateScreenTransform(love.graphics.getWidth(), love.graphics.getHeight())
        end
    end
    
    -- Save settings
    gameState.save()
    
    -- Force a refresh of the current state to update language
    if love.switchState and love.getCurrentStateName then
        local currentState = love.getCurrentStateName()
        if currentState then
            love.switchState(currentState)
        end
    end
end

return gameState
