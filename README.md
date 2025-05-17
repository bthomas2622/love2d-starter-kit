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
- `src/states/` - Contains all game states and UI components
  - `gameState.lua` - Manages game settings and localization
  - `menuState.lua` - Main menu implementation
  - `settingsState.lua` - Settings menu implementation
  - `playState.lua` - A simple placeholder for the actual game
  - `button.lua` - Reusable button component
  - `slider.lua` - Reusable slider component for volume controls
  - `dropdown.lua` - Reusable dropdown component for selections
- `assets/` - Contains game assets (fonts, sounds, etc.)

## Extending the Game

To build upon this template:
1. Modify `playState.lua` to implement your actual game logic
2. Add more states as needed
3. Expand the settings with additional options
4. Add game assets (sprites, sounds, music) to the assets folder
