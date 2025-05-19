---
applyTo: '**'
---
# Love2D Project: Best Practices for AI Coding Agents

This guide provides best practices for AI coding agents working with this Love2D game engine project. Adhering to these guidelines will help ensure that code modifications and additions are consistent, correct, and leverage the existing project structure.

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

*   **Game States**: The project uses a state-based architecture, with states located in `src/states/` (e.g., `menuState.lua`, `playState.lua`).
    *   When adding or modifying game states, follow the existing pattern (e.g., each state might have `load`, `update`, `draw`, `keypressed` methods).
    *   State transitions are a key part of the game flow.
*   **Modules**: Custom modules are used to organize code across various directories:
    *   `src/utils/`: Utility functions (e.g., `src/utils/fontManager.lua`)
    *   `src/ui/`: UI components (e.g., `src/ui/button.lua`)
    *   `src/entities/`: Game entities and objects
    *   `src/systems/`: Game systems (physics, audio, etc.)
    *   `src/constants/`: Game constants and configuration
    *   Load modules using `require("path.to.module")`. For example, `local fontManager = require("src.utils.fontManager")`. The path uses dots as separators and does not include the `.lua` extension.
*   **Assets**: All game assets (fonts, sounds, images) are stored in the `assets/` directory.
    *   Use relative paths from the project root when accessing assets, e.g., `"assets/fonts/NotoSans-Regular.ttf"` or `"assets/sounds/MenuMusic.ogg"`.

## 5. Asset Management

*   **Fonts**: The `src/fontManager.lua` module is responsible for loading and managing fonts. Use its functions to get font objects for rendering text.
*   **Images & Sounds**: Load images (`love.graphics.newImage()`) and sounds (`love.audio.newSource()`) typically within `love.load()` or a state's specific loading function. Store them in variables for reuse to avoid reloading them every frame.

## 6. UI Components

*   The project includes UI components like buttons (`src/ui/button.lua`), dropdowns (`src/ui/dropdown.lua`), and sliders (`src/ui/slider.lua`).
*   When implementing UI elements, try to reuse or extend these existing components if applicable.

## 7. Specific Files to Note

*   **`src/utils/updateGameSettings.lua`**: This script appears to be a utility related to managing game settings. Understand its purpose if tasks involve modifying how game settings are handled.

## 8. Prompting the AI Agent

*   **Be Specific**: Clearly state which file(s) and function(s) need modification.
*   **Provide Context**: If a feature spans multiple files or modules, explain the overall goal and how different parts should interact.
*   **Asset Paths**: When requesting new assets or using existing ones, provide the correct path within the `assets/` directory.
*   **Love2D API Usage**: If you know specific Love2D functions are needed, mention them (e.g., "Use `love.graphics.rectangle()` to draw a border").
*   **Error Handling**: If you encounter errors from the AI's code, provide the full error message and the relevant code snippet.

By following these guidelines, you can help the AI coding agent understand the project structure and Love2D conventions, leading to more effective and accurate code generation.
