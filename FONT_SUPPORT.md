# Multilingual Love2D Game

## Font Support Information

This game supports 13 different languages:
- English
- Chinese (中文)
- Hindi (हिन्दी)
- Spanish (Español)
- French (Français)
- Arabic (العربية)
- Bengali (বাংলা)
- Portuguese (Português)
- Russian (Русский)
- Japanese (日本語)
- Korean (한국어)
- German (Deutsch)
- Polish (Polski)

## Handling Font Display Issues

If you are experiencing issues with characters not displaying correctly in the dropdown menus or elsewhere:

1. Make sure you have the required fonts:
   - The game uses Noto Sans Regular for most text
   - The font file should be located in `assets/fonts/NotoSans-Regular.ttf`

2. For better font support:
   - You can download additional Noto fonts from Google's Noto project
   - Place them in the assets/fonts directory
   - Update the fontManager.lua file to use these additional fonts

3. Recommended fonts for full language support:
   - Noto Sans: Good general Unicode support
   - Noto Sans CJK: For Chinese, Japanese, and Korean
   - Noto Sans Arabic: For Arabic script
   - Noto Sans Bengali: For Bengali script
   - Noto Sans Devanagari: For Hindi script

## How the Language System Works

The game uses a font fallback system to display characters from various writing systems.
When a character is not available in the main font, LÖVE attempts to render it using
the default system fonts.

Each language is identified by a language code:
- en: English
- zh: Chinese
- hi: Hindi
- es: Spanish
- fr: French
- ar: Arabic (Right-to-Left)
- bn: Bengali
- pt: Portuguese
- ru: Russian
- ja: Japanese
- ko: Korean
- de: German
- pl: Polish

## Adding New Languages

To add a new language:
1. Add a new language section in `src/states/gameState.lua` with translations for all UI strings in `src/utils/localization.lua`
   - Use the existing languages as a reference
   - Ensure all keys are translated
2. Add the language to the dropdown in `src/states/settingsState.lua`
3. Make sure you have fonts that support the characters for the new language
