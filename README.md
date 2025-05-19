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
    - `dropdown.lua` - Reusable dropdown component for selections
  - `utils/` - Utility functions and helpers
    - `fontManager.lua` - Font loading and management
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

## Extending the Game

To build upon this template:
1. Modify `playState.lua` to implement your actual game logic
2. Add more states as needed in the `src/states/` directory
3. Create game entities in the `src/entities/` directory
4. Implement game systems (physics, audio managers, etc.) in the `src/systems/` directory
5. Define game constants and configuration in the `src/constants/` directory
6. Expand the settings with additional options
7. Add game assets (sprites, sounds, music) to their respective folders in the `assets/` directory
