-- File: updateGameSettings.lua
-- This file is run once to update the language options display in the dropdown
local gameState = require "src.states.gameState"
local settingsState = require "src.states.settingsState"

-- Function to get the native name for each language
local function getNativeNames()
    -- Return a table with language codes and their native display names
    return {
        -- Format: [code] = "Native Name (English Name)"
        ["en"] = "English",
        ["zh"] = "中文 (Chinese)",
        ["hi"] = "हिन्दी (Hindi)",
        ["es"] = "Español (Spanish)",
        ["fr"] = "Français (French)",
        ["ar"] = "العربية (Arabic)",
        ["bn"] = "বাংলা (Bengali)",
        ["pt"] = "Português (Portuguese)",
        ["ru"] = "Русский (Russian)",
        ["ja"] = "日本語 (Japanese)",
        ["ko"] = "한국어 (Korean)",
        ["de"] = "Deutsch (German)",
        ["pl"] = "Polski (Polish)"
    }
end

-- Print the language names for verification
local nativeNames = getNativeNames()
print("Language options with native names:")
for code, name in pairs(nativeNames) do
    print(code .. " = " .. name)
end

print("\nMake sure to add these to the settingsState.lua file, in the language dropdown section.")
