-- Game state management
local gameState = {}

-- Default settings
gameState.settings = {
    musicVolume = 0.7,
    effectsVolume = 0.8,
    screenSize = {
        width = 800,
        height = 600
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
        apply = "Apply"
    },
    -- Mandarin Chinese (1.1+ billion speakers)
    ["zh"] = {
        play = "开始",
        settings = "设置",
        quit = "退出",
        musicVolume = "音乐音量",
        effectsVolume = "效果音量",
        screenSize = "屏幕尺寸",
        language = "语言",
        back = "返回",
        apply = "应用"
    },
    -- Hindi (600+ million speakers)
    ["hi"] = {
        play = "खेलें",
        settings = "सेटिंग्स",
        quit = "बाहर निकलें",
        musicVolume = "संगीत की आवाज़",
        effectsVolume = "प्रभाव की आवाज़",
        screenSize = "स्क्रीन का आकार",
        language = "भाषा",
        back = "वापस",
        apply = "लागू करें"
    },
    -- Spanish (550+ million speakers)
    ["es"] = {
        play = "Jugar",
        settings = "Configuración",
        quit = "Salir",
        musicVolume = "Volumen de música",
        effectsVolume = "Volumen de efectos",
        screenSize = "Tamaño de pantalla",
        language = "Idioma",
        back = "Atrás",
        apply = "Aplicar"
    },
    -- French (280+ million speakers)
    ["fr"] = {
        play = "Jouer",
        settings = "Paramètres",
        quit = "Quitter",
        musicVolume = "Volume de la musique",
        effectsVolume = "Volume des effets",
        screenSize = "Taille de l'écran",
        language = "Langue",
        back = "Retour",
        apply = "Appliquer"
    },
    -- Arabic (270+ million speakers)
    ["ar"] = {
        play = "لعب",
        settings = "إعدادات",
        quit = "خروج",
        musicVolume = "مستوى الموسيقى",
        effectsVolume = "مستوى المؤثرات",
        screenSize = "حجم الشاشة",
        language = "اللغة",
        back = "رجوع",
        apply = "تطبيق"
    },
    -- Bengali (260+ million speakers)
    ["bn"] = {
        play = "খেলুন",
        settings = "সেটিংস",
        quit = "বের হন",
        musicVolume = "সঙ্গীতের শব্দ",
        effectsVolume = "প্রভাবের শব্দ",
        screenSize = "স্ক্রিনের আকার",
        language = "ভাষা",
        back = "পেছনে",
        apply = "প্রয়োগ করুন"
    },
    -- Portuguese (260+ million speakers)
    ["pt"] = {
        play = "Jogar",
        settings = "Configurações",
        quit = "Sair",
        musicVolume = "Volume da música",
        effectsVolume = "Volume dos efeitos",
        screenSize = "Tamanho da tela",
        language = "Idioma",
        back = "Voltar",
        apply = "Aplicar"
    },
    -- Russian (250+ million speakers)
    ["ru"] = {
        play = "Играть",
        settings = "Настройки",
        quit = "Выход",
        musicVolume = "Громкость музыки",
        effectsVolume = "Громкость эффектов",
        screenSize = "Размер экрана",
        language = "Язык",
        back = "Назад",
        apply = "Применить"
    },
    -- Japanese (130+ million speakers)
    ["ja"] = {
        play = "プレイ",
        settings = "設定",
        quit = "終了",
        musicVolume = "音楽の音量",
        effectsVolume = "効果音の音量",
        screenSize = "画面サイズ",
        language = "言語",
        back = "戻る",
        apply = "適用"
    },
    -- Korean (80+ million speakers)
    ["ko"] = {
        play = "플레이",
        settings = "설정",
        quit = "종료",
        musicVolume = "음악 볼륨",
        effectsVolume = "효과음 볼륨",
        screenSize = "화면 크기",
        language = "언어",
        back = "뒤로",
        apply = "적용"
    },
    -- German (90+ million speakers)
    ["de"] = {
        play = "Spielen",
        settings = "Einstellungen",
        quit = "Beenden",
        musicVolume = "Musiklautstärke",
        effectsVolume = "Effektlautstärke",
        screenSize = "Bildschirmgröße",
        language = "Sprache",
        back = "Zurück",
        apply = "Anwenden"
    },
    -- Polish (40+ million speakers)
    ["pl"] = {
        play = "Graj",
        settings = "Ustawienia",
        quit = "Wyjdź",
        musicVolume = "Głośność muzyki",
        effectsVolume = "Głośność efektów",
        screenSize = "Rozmiar ekranu",
        language = "Język",
        back = "Wstecz",
        apply = "Zastosuj"
    }
}

-- Screen sizes available in settings
gameState.screenSizes = {
    {width = 800, height = 600, label = "800x600"},
    {width = 1024, height = 768, label = "1024x768"},
    {width = 1280, height = 720, label = "1280x720 (720p)"},
    {width = 1920, height = 1080, label = "1920x1080 (1080p)"}
}

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

-- Save settings to a file
function gameState.save()
    local status, jsonData = pcall(function() 
        return love.data.encode("string", "json", gameState.settings)
    end)
    
    if status then
        local data = love.filesystem.newFileData(jsonData, "settings.json")
        local success = love.filesystem.write("settings.json", data)
        if not success then
            print("Error: Failed to write settings to file")
        end
    else
        print("Error: Failed to encode settings to JSON: " .. jsonData)
    end
end

-- Load settings from a file
function gameState.load()
    if love.filesystem.getInfo("settings.json") then
        local data = love.filesystem.read("settings.json")
        if not data then
            print("Error: Failed to read settings.json")
            return
        end
        
        local success, result = pcall(function() 
            return love.data.decode("string", "json", data) 
        end)
        
        if success and type(result) == "table" then
            -- Update settings with loaded values
            for k, v in pairs(result) do
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
            print("Error: Failed to decode settings JSON")
        end
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
