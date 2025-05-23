# Love2D Game with Menu System

This is a simple Love2D game template with a complete menu system including:
- Main Menu
- Settings Menu
- Play State

## Features

- Main menu with "Play", "Settings", and "Quit" buttons
- Settings menu with:
  - Music volume control
  - Effects volume control
  - Screen size options
  - Language selection (English, Spanish, French)
- Persistent settings using Love2D's save/load system
- State management system
- Reusable UI components (buttons, sliders, dropdowns)

## How to Run

1. Install Love2D from https://love2d.org/
2. Navigate to this project folder in your terminal/command prompt
3. Run the command: `love .`

## Project Structure

- `main.lua` - Entry point for the Love2D application
- `conf.lua` - Configuration settings for the Love2D application
- `src/` - Source code directory
  - `states/` - Contains all game state implementations
    - `gameState.lua` - Manages game settings and localization
    - `menuState.lua` - Main menu implementation
    - `settingsState.lua` - Settings menu implementation
    - `playState.lua` - A simple placeholder for the actual game
  - `ui/` - Contains reusable UI components
    - `button.lua` - Reusable button component
    - `slider.lua` - Reusable slider component for volume controls
    - `dropdown.lua` - Reusable dropdown component for selections  - `utils/` - Utility functions and helpers
    - `fontManager.lua` - Font loading and management
    - `localization.lua` - Multi-language localization system
    - `updateGameSettings.lua` - Utility for updating game settings
  - `entities/` - Game entities and objects (empty - for future use)
  - `systems/` - Game systems like physics, audio, etc. (empty - for future use)
  - `constants/` - Game constants and configuration (empty - for future use)
- `assets/` - Contains game assets
  - `fonts/` - Font files
  - `sounds/` - Audio files
  - `images/` - Image and sprite files (empty - for future use)
  - `shaders/` - GLSL shader files (empty - for future use)
  - `maps/` - Level and map data (empty - for future use)

## Localization System

The game includes a comprehensive multi-language localization system with support for 13 languages:

### Supported Languages
- **English** (`en`) - Default language
- **中文 Chinese** (`zh`) - Simplified Chinese
- **हिन्दी Hindi** (`hi`) - Hindi
- **Español Spanish** (`es`) - Spanish
- **Français French** (`fr`) - French  
- **العربية Arabic** (`ar`) - Arabic (RTL support)
- **বাংলা Bengali** (`bn`) - Bengali
- **Português Portuguese** (`pt`) - Portuguese
- **Русский Russian** (`ru`) - Russian
- **日本語 Japanese** (`ja`) - Japanese
- **한국어 Korean** (`ko`) - Korean
- **Deutsch German** (`de`) - German
- **Polski Polish** (`pl`) - Polish

### Localization Features
- **Complete translations** - All UI text is translated for every supported language
- **RTL support** - Right-to-left text rendering for Arabic
- **Dynamic language switching** - Change language in settings without restart
- **Fallback system** - Falls back to English if a translation is missing
- **Validation system** - Built-in validation to ensure translation completeness

### Usage
```lua
-- Get localized text (uses current language setting)
local playText = gameState.getText("play")

-- Direct access to localization module
local localization = require("src.utils.localization")
local playText = localization.getText("play", "es") -- Spanish
```

### Adding New Languages
1. Add the language code and translations to `src/utils/localization.lua`
2. Add the language to the `getAvailableLanguages()` function
3. Use `localization.validateTranslations()` to check completeness

## Extending the Game

To build upon this template:
1. Modify `playState.lua` to implement your actual game logic
2. Add more states as needed in the `src/states/` directory
3. Create game entities in the `src/entities/` directory
4. Implement game systems (physics, audio managers, etc.) in the `src/systems/` directory
5. Define game constants and configuration in the `src/constants/` directory
6. Expand the settings with additional options
7. Add game assets (sprites, sounds, music) to their respective folders in the `assets/` directory
