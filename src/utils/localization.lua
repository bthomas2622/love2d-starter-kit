-- Localization system for the game
local localization = {}

-- Available languages with complete translations
localization.languages = {
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

-- Get a formatted list of available languages for UI
function localization.getAvailableLanguages()
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

-- Return the text in the specified language
function localization.getText(key, language)
    language = language or "en"  -- Default to English
    
    if localization.languages[language] and localization.languages[language][key] then
        local text = localization.languages[language][key]
        
        -- Handle right-to-left languages (like Arabic)
        if language == "ar" then
            -- Add RTL marker to beginning of text
            return "\u{200F}" .. text
        end
        
        return text
    end
    
    -- Fallback to English
    return localization.languages["en"][key] or key
end

-- Check if current language is RTL (right-to-left)
function localization.isRTL(language)
    language = language or "en"
    -- Currently Arabic is our only RTL language
    return language == "ar"
end

-- Validate that all languages have all required keys
function localization.validateTranslations()
    local englishKeys = {}
    local missingTranslations = {}
    
    -- Get all English keys as reference
    for key, _ in pairs(localization.languages["en"]) do
        table.insert(englishKeys, key)
    end
    
    -- Check each language for missing keys
    for langCode, translations in pairs(localization.languages) do
        if langCode ~= "en" then
            local missing = {}
            for _, key in ipairs(englishKeys) do
                if not translations[key] then
                    table.insert(missing, key)
                end
            end
            if #missing > 0 then
                missingTranslations[langCode] = missing
            end
        end
    end
    
    return missingTranslations
end

-- Helper function to print validation results (useful for debugging)
function localization.printValidationResults()
    local missing = localization.validateTranslations()
    if next(missing) == nil then
        print("✓ All translations are complete!")
        print("Languages available: " .. #localization.getAvailableLanguages())
        
        -- Print total number of keys per language
        local englishKeys = {}
        for key, _ in pairs(localization.languages["en"]) do
            table.insert(englishKeys, key)
        end
        print("Total translation keys: " .. #englishKeys)
        
        return true
    else
        print("✗ Missing translations found:")
        for lang, keys in pairs(missing) do
            print("  " .. lang .. ": " .. table.concat(keys, ", "))
        end
        return false
    end
end

return localization
