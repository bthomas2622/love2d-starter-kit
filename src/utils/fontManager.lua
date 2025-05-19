-- Font manager to handle loading and managing fonts
local fontManager = {}

-- Font cache
local fonts = {}

-- Default font file with Unicode support
local defaultFontPath = "assets/fonts/NotoSans-Regular.ttf"

-- Fallback fonts
local fallbackFontPaths = {
    "assets/fonts/NotoSansArabic-Regular.ttf",
    "assets/fonts/NotoSansBengali-Regular.ttf",
    "assets/fonts/NotoSansJP-Regular.ttf",
    "assets/fonts/NotoSansKR-Regular.ttf",
    "assets/fonts/NotoSansSC-Regular.ttf",
    "assets/fonts/NotoSansDevanagari-Regular.ttf"
}
local fallbackFonts = {}

-- Initialize the font manager
function fontManager.init()
    -- Load fallback fonts
    for _, path in ipairs(fallbackFontPaths) do
        local success, font = pcall(function()
            return love.graphics.newFont(path, 16) -- Load with a default size, actual size will be set later
        end)
        if success then
            table.insert(fallbackFonts, font)
        else
            print("Warning: Failed to load fallback font: " .. path)
        end
    end

    -- Preload commonly used sizes
    fontManager.getFont(16) -- Regular text
    fontManager.getFont(20) -- Button text
    fontManager.getFont(30) -- Title text
    fontManager.getFont(40) -- Large title text
end

-- Get a font of the specified size
function fontManager.getFont(size)
    size = size or 16 -- Default size
    
    -- Check if we've already loaded this font size
    if fonts[size] then
        return fonts[size]
    end
    
    -- Load the font
    local success, font = pcall(function()
        local newFont = love.graphics.newFont(defaultFontPath, size)
        if newFont and #fallbackFonts > 0 then
            newFont:setFallbacks(unpack(fallbackFonts))
        end
        return newFont
    end)
    
    if success and font then -- Added 'and font' to ensure font is not nil
        fonts[size] = font
        return font
    else
        -- Fallback to default Love font if loading fails
        print("Warning: Failed to load Unicode font, falling back to default")
        local defaultLoveFont = love.graphics.newFont(size) -- Create a new default Love font
        if defaultLoveFont and #fallbackFonts > 0 then -- Apply fallbacks to the default Love font too
            defaultLoveFont:setFallbacks(unpack(fallbackFonts))
        end
        fonts[size] = defaultLoveFont
        return fonts[size]
    end
end

return fontManager
