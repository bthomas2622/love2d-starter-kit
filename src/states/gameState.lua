-- Game state management
local love = require("love")
local gameState = {}

-- Default settings
gameState.settings = {
    musicVolume = 0.7,
    effectsVolume = 0.8,
    screenSize = {
        width = 1280,
        height = 720
    },
    language = "en"  -- Default language: English
}

-- Available languages
gameState.languages = {
    -- English (1.2+ billion speakers)
    ["en"] = {
        play = "Play",
        settings = "Settings",
        quit = "Quit",
        musicVolume = "Music Volume",
        effectsVolume = "Effects Volume",
        screenSize = "Screen Size",
        language = "Language",
        back = "Back",
        apply = "Apply",
        controls = "Controls",
        keyboard = "Keyboard",
        gamepad = "Gamepad",
        up = "Up",
        down = "Down",
        left = "Left",
        right = "Right",
        select = "Select",
        reset = "Reset to Default"
    },    -- Mandarin Chinese (1.1+ billion speakers)
    ["zh"] = {
        play = "开始",
        settings = "设置",
        quit = "退出",
        musicVolume = "音乐音量",
        effectsVolume = "效果音量",
        screenSize = "屏幕尺寸",
        language = "语言",
        back = "返回",
        apply = "应用",
        controls = "控制",
        keyboard = "键盘",
        gamepad = "游戏手柄",
        up = "上",
        down = "下",
        left = "左",
        right = "右",
        select = "选择",
        reset = "恢复默认设置"
    },-- Hindi (600+ million speakers)
    ["hi"] = {
        play = "खेलें",
        settings = "सेटिंग्स",
        quit = "बाहर निकलें",
        musicVolume = "संगीत की आवाज़",
        effectsVolume = "प्रभाव की आवाज़",
        screenSize = "स्क्रीन का आकार",
        language = "भाषा",
        back = "वापस",
        apply = "लागू करें",
        controls = "नियंत्रण",
        keyboard = "कीबोर्ड",
        gamepad = "गेमपैड",
        up = "ऊपर",
        down = "नीचे",
        left = "बाएं",
        right = "दाएं",
        select = "चुनें",
        reset = "डिफ़ॉल्ट पर रीसेट"
    },    -- Spanish (550+ million speakers)
    ["es"] = {
        play = "Jugar",
        settings = "Configuración",
        quit = "Salir",
        musicVolume = "Volumen de música",
        effectsVolume = "Volumen de efectos",
        screenSize = "Tamaño de pantalla",
        language = "Idioma",
        back = "Atrás",
        apply = "Aplicar",
        controls = "Controles",
        keyboard = "Teclado",
        gamepad = "Mando",
        up = "Arriba",
        down = "Abajo",
        left = "Izquierda",
        right = "Derecha",
        select = "Seleccionar",
        reset = "Restablecer"
    },    -- French (280+ million speakers)
    ["fr"] = {
        play = "Jouer",
        settings = "Paramètres",
        quit = "Quitter",
        musicVolume = "Volume de la musique",
        effectsVolume = "Volume des effets",
        screenSize = "Taille de l'écran",
        language = "Langue",
        back = "Retour",
        apply = "Appliquer",
        controls = "Commandes",
        keyboard = "Clavier",
        gamepad = "Manette",
        up = "Haut",
        down = "Bas",
        left = "Gauche",
        right = "Droite",
        select = "Sélectionner",
        reset = "Réinitialiser"
    },    -- Arabic (270+ million speakers)
    ["ar"] = {
        play = "لعب",
        settings = "إعدادات",
        quit = "خروج",
        musicVolume = "مستوى الموسيقى",
        effectsVolume = "مستوى المؤثرات",
        screenSize = "حجم الشاشة",
        language = "اللغة",
        back = "رجوع",
        apply = "تطبيق",
        controls = "التحكم",
        keyboard = "لوحة المفاتيح",
        gamepad = "يد التحكم",
        up = "أعلى",
        down = "أسفل",
        left = "يسار",
        right = "يمين",
        select = "اختيار",
        reset = "إعادة تعيين"
    },    -- Bengali (260+ million speakers)
    ["bn"] = {
        play = "খেলুন",
        settings = "সেটিংস",
        quit = "বের হন",
        musicVolume = "সঙ্গীতের শব্দ",
        effectsVolume = "প্রভাবের শব্দ",
        screenSize = "স্ক্রিনের আকার",
        language = "ভাষা",
        back = "পেছনে",
        apply = "প্রয়োগ করুন",
        controls = "নিয়ন্ত্রণ",
        keyboard = "কীবোর্ড",
        gamepad = "গেমপ্যাড",
        up = "উপরে",
        down = "নিচে",
        left = "বামে",
        right = "ডানে",
        select = "নির্বাচন করুন",
        reset = "পুনরায় সেট করুন"
    },    -- Portuguese (260+ million speakers)
    ["pt"] = {
        play = "Jogar",
        settings = "Configurações",
        quit = "Sair",
        musicVolume = "Volume da música",
        effectsVolume = "Volume dos efeitos",
        screenSize = "Tamanho da tela",
        language = "Idioma",
        back = "Voltar",
        apply = "Aplicar",
        controls = "Controles",
        keyboard = "Teclado",
        gamepad = "Controle",
        up = "Cima",
        down = "Baixo",
        left = "Esquerda",
        right = "Direita",
        select = "Selecionar",
        reset = "Restaurar padrão"
    },    -- Russian (250+ million speakers)
    ["ru"] = {
        play = "Играть",
        settings = "Настройки",
        quit = "Выход",
        musicVolume = "Громкость музыки",
        effectsVolume = "Громкость эффектов",
        screenSize = "Размер экрана",
        language = "Язык",
        back = "Назад",
        apply = "Применить",
        controls = "Управление",
        keyboard = "Клавиатура",
        gamepad = "Геймпад",
        up = "Вверх",
        down = "Вниз",
        left = "Влево",
        right = "Вправо",
        select = "Выбрать",
        reset = "Сбросить"
    },    -- Japanese (130+ million speakers)
    ["ja"] = {
        play = "プレイ",
        settings = "設定",
        quit = "終了",
        musicVolume = "音楽の音量",
        effectsVolume = "効果音の音量",
        screenSize = "画面サイズ",
        language = "言語",
        back = "戻る",
        apply = "適用",
        controls = "操作",
        keyboard = "キーボード",
        gamepad = "ゲームパッド",
        up = "上",
        down = "下",
        left = "左",
        right = "右",
        select = "決定",
        reset = "リセット"
    },    -- Korean (80+ million speakers)
    ["ko"] = {
        play = "플레이",
        settings = "설정",
        quit = "종료",
        musicVolume = "음악 볼륨",
        effectsVolume = "효과음 볼륨",
        screenSize = "화면 크기",
        language = "언어",
        back = "뒤로",
        apply = "적용",
        controls = "조작",
        keyboard = "키보드",
        gamepad = "게임패드",
        up = "위",
        down = "아래",
        left = "왼쪽",
        right = "오른쪽",
        select = "선택",
        reset = "초기화"
    },    -- German (90+ million speakers)
    ["de"] = {
        play = "Spielen",
        settings = "Einstellungen",
        quit = "Beenden",
        musicVolume = "Musiklautstärke",
        effectsVolume = "Effektlautstärke",
        screenSize = "Bildschirmgröße",
        language = "Sprache",
        back = "Zurück",
        apply = "Anwenden",
        controls = "Steuerung",
        keyboard = "Tastatur",
        gamepad = "Gamepad",
        up = "Hoch",
        down = "Runter",
        left = "Links",
        right = "Rechts",
        select = "Auswählen",
        reset = "Zurücksetzen"
    },    -- Polish (40+ million speakers)
    ["pl"] = {
        play = "Graj",
        settings = "Ustawienia",
        quit = "Wyjdź",
        musicVolume = "Głośność muzyki",
        effectsVolume = "Głośność efektów",
        screenSize = "Rozmiar ekranu",
        language = "Język",
        back = "Wstecz",
        apply = "Zastosuj",
        controls = "Sterowanie",
        keyboard = "Klawiatura",
        gamepad = "Kontroler",
        up = "Góra",
        down = "Dół",
        left = "Lewo",
        right = "Prawo",
        select = "Wybierz",
        reset = "Resetuj"
    }
}

-- Screen sizes available in settings
gameState.screenSizes = {
    {width = 800, height = 600, label = "800x600"},
    {width = 1024, height = 768, label = "1024x768"},
    {width = 1280, height = 720, label = "1280x720 (720p)"},
    {width = 1920, height = 1080, label = "1920x1080 (1080p)"},
    {width = 3840, height = 2160, label = "3840x2160 (4K)"}
}

-- Get a formatted list of available languages for UI
function gameState.getAvailableLanguages()
    local languagesList = {
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
    return languagesList
end

-- Return the text in the current language
function gameState.getText(key)
    local lang = gameState.settings.language
    if gameState.languages[lang] and gameState.languages[lang][key] then
        local text = gameState.languages[lang][key]
        
        -- Handle right-to-left languages (like Arabic)
        if lang == "ar" then
            -- Add RTL marker to beginning of text
            return "\u{200F}" .. text
        end
        
        return text
    end
    -- Fallback to English
    return gameState.languages["en"][key] or key
end

-- Check if current language is RTL (right-to-left)
function gameState.isRTL()
    local lang = gameState.settings.language
    -- Currently Arabic is our only RTL language
    return lang == "ar"
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
            if not gameState.languages[gameState.settings.language] then
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
