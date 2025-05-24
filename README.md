# Love2D Starter Kit with Complete Menu System

This is a fully functional Love2D Starter Kit with a complete menu system and game framework including:
- Main Menu
- Settings Menu  
- Controls Menu
- Playable Snake Game

## Features

### Menu System
- Main menu with "Play", "Settings", and "Quit" buttons
- Settings menu with:
  - Music volume control
  - Effects volume control
  - Screen size options
  - Language selection (13 supported languages)
- Controls menu with full input customization:
  - Keyboard and gamepad support
  - Customizable key bindings for all actions
  - Reset to defaults option
- Persistent settings using Love2D's save/load system
- State management system
- Reusable UI components (buttons, sliders, dropdowns)

### Sample Snake Game
- Classic Snake gameplay with modern enhancements
- Dynamic grid-based movement system
- Collision detection (walls and self-collision)
- Progressive difficulty - game speeds up as you score
- Visual sprite-based graphics for snake segments and fruit
- Sound effects for fruit eating and menu interactions
- Score tracking with real-time display
- Game over detection and restart functionality

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
    - `controlsState.lua` - Controls/input settings menu
    - `playState.lua` - Complete Snake game implementation
  - `ui/` - Contains reusable UI components
    - `button.lua` - Reusable button component
    - `slider.lua` - Reusable slider component for volume controls
    - `dropdown.lua` - Reusable dropdown component for selections
  - `utils/` - Utility functions and helpers
    - `fontManager.lua` - Font loading and management
    - `localization.lua` - Multi-language localization system
    - `soundManager.lua` - Audio management and playback
    - `inputManager.lua` - Input handling (keyboard/gamepad)
    - `json.lua` - JSON parsing utilities
  - `entities/` - Game entities and objects (available for expansion)
  - `systems/` - Game systems like physics, audio, etc. (available for expansion)
  - `constants/` - Game constants and configuration
    - `gameConfig.lua` - Centralized game configuration constants
- `assets/` - Contains game assets
  - `fonts/` - Font files (including multi-language support)
  - `sounds/` - Audio files (menu sounds)
  - `music/` - Background music files
  - `images/` - Game sprites (snake segments, fruit)
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

## Input System

The game includes a comprehensive input management system with full customization support:

### Supported Input Methods
- **Keyboard** - Full QWERTY support with customizable bindings
- **Gamepad** - Xbox/PlayStation controller support with analog and button inputs
- **Hybrid Support** - Use keyboard and gamepad simultaneously

### Input Features
- **Action-based system** - Map multiple keys/buttons to single actions
- **Real-time remapping** - Change controls without restarting
- **Conflict prevention** - Prevents duplicate key assignments
- **Input validation** - Ensures all controls remain functional
- **Default restoration** - Reset to default bindings option

### Available Actions
- **Movement**: Up, Down, Left, Right (for game and menu navigation)
- **Menu**: Select, Back (for menu interactions)
- **Game**: All movement actions work in-game for Snake control

### Usage
```lua
-- Check for action input (handles both keyboard and gamepad)
if inputManager.isActionJustPressed("select") then
    -- Handle select action
end

-- Access input manager for custom controls
local inputManager = require("src.utils.inputManager")
```

## Audio System

The game includes a complete audio management system:

### Features
- **Music Management** - Background music with volume control
- **Sound Effects** - Menu sounds and game audio feedback  
- **Volume Control** - Separate music and effects volume sliders
- **Dynamic Audio** - Context-aware music and sound triggering

### Audio Assets
- Menu background music
- Menu navigation sounds (move, select, back)
- Game sound effects (fruit eating)

## Game Configuration

All game settings are centralized in `src/constants/gameConfig.lua`:

### Configuration Categories
- **Screen/Scaling** - Virtual canvas and window settings
- **Snake Game** - Grid size, speed, difficulty progression
- **Input** - Timing and threshold settings
- **Audio** - File paths and audio configuration
- **Fonts** - Font definitions and sizing
- **UI** - Interface layout and behavior settings

## Extending the Game

This is now a complete Snake game rather than just a template. To build upon it:

### Game Enhancements
1. **Add more game modes** - Time attack, multiplayer, obstacles
2. **Power-ups** - Special fruits with different effects
3. **Levels/Maps** - Different arena layouts and challenges
4. **Visual effects** - Particles, animations, screen shake
5. **Advanced scoring** - Combo systems, high score tables

### Framework Extensions  
1. **Add more states** - Pause menu, high scores, credits
2. **Create game entities** - Use `src/entities/` for game objects
3. **Implement game systems** - Use `src/systems/` for physics, particles, etc.
4. **Expand UI components** - Add more reusable interface elements
5. **Add more assets** - Sprites, sounds, music, shaders
6. **Enhance settings** - More graphics options, accessibility features

### Technical Improvements
1. **Save system** - Game progress, high scores, achievements
2. **Networking** - Multiplayer support, leaderboards  
3. **Performance** - Optimize rendering, add object pooling
4. **Platform support** - Mobile controls, different screen sizes
5. **Modding support** - External content loading, scripting
