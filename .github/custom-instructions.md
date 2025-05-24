# Love2D Starter Kit: Best Practices

This guide provides best practices for working with this Love2D Starter Kit game project. This is no longer a template but a fully functional game with menu system, settings, controls, and gameplay. Adhering to these guidelines will help ensure that code modifications and additions are consistent, correct, and leverage the existing project structure.

## 1. Core Files

*   **`main.lua`**: This is the main entry point of the game. It typically contains the core Love2D callback functions:
    *   `love.load()`: Called once at the beginning of the game for initial setup, loading assets, and initializing variables.
    *   `love.update(dt)`: Called every frame. `dt` (delta time) is the time since the last frame and should be used for time-based calculations (e.g., movement, animations) to ensure frame-rate independence.
    *   `love.draw()`: Called every frame after `love.update()`. All drawing operations should happen here.
    *   `love.keypressed(key, scancode, isrepeat)`: Handles key press events.
    *   `love.mousepressed(x, y, button, istouch, presses)`: Handles mouse button press events.
    *   Other input callbacks (e.g., `love.keyreleased`, `love.mousereleased`).
*   **`conf.lua`**: This file configures the game window and other project-wide settings (e.g., window title, dimensions, enabled modules). Changes here affect the global game environment.

## 2. Language: Lua

*   All game logic is written in Lua. Ensure any generated code is valid Lua 5.1 (as commonly used with LÖVE).
*   Remember that Lua tables are 1-indexed by default.
*   Use `local` for variables to keep them scoped, unless global scope is explicitly required.

## 3. Love2D API

*   Utilize the official Love2D API extensively. Refer to the [Love2D Wiki](https://love2d.org/wiki/Main_Page) for documentation.
*   **Graphics**: Use `love.graphics` for drawing shapes, images, text, etc. (e.g., `love.graphics.draw()`, `love.graphics.printf()`, `love.graphics.setColor()`). Coordinates are (0,0) at the top-left corner by default.
*   **Audio**: Use `love.audio` for playing sounds and music (e.g., `love.audio.newSource()`, `source:play()`).
*   **Filesystem**: Use `love.filesystem` for reading and writing files. Be mindful of fused mode vs. non-fused mode when distributing the game.
*   **Input**: Use `love.keyboard` and `love.mouse` for polling input state outside of callbacks if needed, but prefer callbacks like `love.keypressed` for event-driven input.

## 4. Project Structure & Modules

*   **Game States**: The project uses a state-based architecture, with states located in `src/states/`:
    *   `menuState.lua` - Main menu with navigation
    *   `settingsState.lua` - Settings menu with volume, screen size, and language options
    *   `controlsState.lua` - Controls menu for input customization
    *   `playState.lua` - Complete Snake game implementation
    *   `gameState.lua` - Global state management and localization
    *   When adding or modifying game states, follow the existing pattern (each state has `init`, `update`, `draw`, and input handling methods).
    *   State transitions are managed through `love.switchState()` and handle audio/UI transitions.
*   **Modules**: Custom modules are organized across various directories:
    *   `src/utils/`: Core utility functions
        *   `fontManager.lua` - Font loading and management
        *   `soundManager.lua` - Audio playback and management
        *   `inputManager.lua` - Input handling (keyboard/gamepad)
        *   `localization.lua` - Multi-language system (13 languages)
        *   `json.lua` - JSON parsing utilities
    *   `src/ui/`: UI components
        *   `button.lua` - Interactive button component
        *   `slider.lua` - Volume/value slider component  
        *   `dropdown.lua` - Selection dropdown component
    *   `src/constants/`: Configuration and constants
        *   `gameConfig.lua` - Centralized game configuration
    *   `src/entities/`: Game entities and objects (available for expansion)
    *   `src/systems/`: Game systems (available for expansion)
    *   Load modules using `require("path.to.module")`. For example, `local soundManager = require("src.utils.soundManager")`. The path uses dots as separators and does not include the `.lua` extension.
*   **Assets**: All game assets are stored in the `assets/` directory:
    *   `assets/fonts/` - Multi-language font files (including Noto Sans variants)
    *   `assets/sounds/` - Sound effects (MenuSelect.ogg, MenuMove.ogg, MenuBack.ogg)
    *   `assets/music/` - Background music (MenuMusic.ogg)
    *   `assets/images/` - Game sprites (snakeHead.png, snakeBody.png, snakeTail.png, fruit.png)
    *   `assets/shaders/` - GLSL shaders (available for expansion)
    *   `assets/maps/` - Level/map data (available for expansion)
    *   Use relative paths from the project root when accessing assets, e.g., `"assets/images/snakeHead.png"` or `"assets/sounds/MenuSelect.ogg"`.

## 5. Asset Management

*   **Fonts**: The `fontManager.lua` module loads and manages fonts for different languages and UI elements. Use its functions to get font objects for rendering text.
*   **Audio**: The `soundManager.lua` module handles all audio playback:
    *   `soundManager.playMusic(name)` - Play background music
    *   `soundManager.stopMusic()` - Stop current music
    *   `soundManager.playSound(name)` - Play sound effects
    *   Volume is controlled through settings and applied automatically
*   **Images**: Game sprites are loaded in `playState.lua` with error handling. Use the existing `safeLoadImage()` pattern for loading new assets.
*   **Configuration**: All asset paths and configuration are centralized in `gameConfig.lua` - modify this file to add new assets or change paths.

## 6. Input System

*   The project includes a comprehensive input manager (`inputManager.lua`) that handles:
    *   **Action-based input** - Use `inputManager.isActionJustPressed("action")` instead of raw key codes
    *   **Keyboard and gamepad support** - Both input methods work simultaneously
    *   **Customizable bindings** - Users can remap controls in the Controls menu
    *   **Input validation** - Prevents conflicts and ensures all actions remain bound
*   **Available actions**: "up", "down", "left", "right", "select", "back"
*   **Best practice**: Always use action-based input rather than direct key/button checking for game controls.

## 7. Game Configuration

*   **Central configuration**: All game constants are defined in `src/constants/gameConfig.lua`
    *   Screen/scaling settings
    *   Snake game parameters (grid size, speed, difficulty)
    *   Audio file paths
    *   Font definitions
    *   Input settings
*   **Modifying settings**: Update `gameConfig.lua` rather than hardcoding values throughout the codebase.
*   **Settings persistence**: User settings are saved/loaded through `gameState.lua` and `updateGameSettings.lua`.

## 8. Snake Game Implementation

*   The `playState.lua` contains a complete Snake game with:
    *   **Grid-based movement** - Snake moves on a calculated grid based on screen size
    *   **Collision detection** - Wall and self-collision with proper game over handling
    *   **Progressive difficulty** - Game speeds up as the player scores points
    *   **Visual rendering** - Sprite-based snake segments with proper rotation
    *   **Sound integration** - Fruit eating sounds and menu audio
*   **Key functions**:
    *   `initGame()` - Resets and initializes a new game
    *   `spawnFruit()` - Places fruit in valid locations
    *   `updateSnakeSegmentTypes()` - Manages head/body/tail segment types
    *   `getSegmentRotation()` - Calculates sprite rotation for snake segments

## 9. UI Components

*   The project includes reusable UI components in `src/ui/`:
    *   `button.lua` - Interactive buttons with hover/selection states and callback support
    *   `slider.lua` - Value sliders for volume controls and numeric settings
    *   `dropdown.lua` - Selection dropdowns for options like language and screen size
*   **UI Integration**: All components work with the input manager and support both keyboard/gamepad navigation
*   **Consistent styling**: Components follow the established visual design and scale properly across different screen sizes
*   **Event handling**: Use callback functions for button actions and value change events for sliders/dropdowns

## 10. Localization System

*   **Multi-language support**: 13 languages supported with complete translations
*   **Usage**: `gameState.getText("key")` returns localized text for the current language
*   **RTL support**: Arabic language includes right-to-left text rendering
*   **Fallback system**: Missing translations fall back to English
*   **Adding languages**: Add to `localization.lua` and use validation functions to ensure completeness

## 11. State Management

*   **Current states**: menu, settings, controls, play, (gameState for global management)
*   **State switching**: Use `love.switchState(stateName)` for transitions
*   **State lifecycle**: Each state implements `init()`, `update(dt)`, `draw()`, and input handlers
*   **Global state**: `gameState.lua` manages settings, localization, and persistent data
*   **Audio transitions**: State changes trigger appropriate sound effects and music changes

## 12. Specific Files to Note

*   **`src/constants/gameConfig.lua`**: Central configuration file - modify this for game balance, paths, and settings
*   **`src/utils/inputManager.lua`**: Handles all input with customizable bindings - reference for input handling patterns
*   **`src/utils/soundManager.lua`**: Audio management - use for adding new sounds or music
*   **`src/states/playState.lua`**: Complete Snake game implementation - reference for game logic patterns
*   **`src/states/controlsState.lua`**: Input remapping interface - reference for complex UI interactions

## 13. Prompting the AI Agent

*   **Be Specific**: Clearly state which file(s) and function(s) need modification.
*   **Provide Context**: If a feature spans multiple files or modules, explain the overall goal and how different parts should interact.
*   **Asset Paths**: When requesting new assets or using existing ones, provide the correct path within the `assets/` directory.
*   **Love2D API Usage**: If you know specific Love2D functions are needed, mention them (e.g., "Use `love.graphics.rectangle()` to draw a border").
*   **Input Handling**: Use action-based input through `inputManager` rather than direct key checking for consistency with the control customization system.
*   **Audio Integration**: Use `soundManager` functions for any new audio features to maintain volume control and consistency.
*   **Configuration Changes**: Modify `gameConfig.lua` for new constants rather than hardcoding values.
*   **Error Handling**: If you encounter errors from the AI's code, provide the full error message and the relevant code snippet.

By following these guidelines, you can help the AI coding agent understand the project structure and Love2D conventions, leading to more effective and accurate code generation.
