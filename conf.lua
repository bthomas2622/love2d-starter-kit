local love = require("love")
local gameConfig = require("src.constants.gameConfig")

function love.conf(t)
    t.title = gameConfig.WINDOW.TITLE                  -- The title of the window the game is in
    t.version = "11.4"                                 -- The LÖVE version this game was made for
    t.window.width = gameConfig.WINDOW.DEFAULT_WIDTH   -- Game's default window width
    t.window.height = gameConfig.WINDOW.DEFAULT_HEIGHT -- Game's default window height
    t.window.resizable = gameConfig.WINDOW.RESIZABLE   -- Let the user resize the window
    t.console = gameConfig.DEBUG.ENABLE_CONSOLE        -- Enable console output for debugging
    
    -- For Windows, macOS and Linux
    t.identity = "love2d_game"                         -- The name of the save directory (string)
    t.appendidentity = true                            -- Search files in source directory before save directory
      -- Modules that you don't need can be disabled to save memory
    t.modules.joystick = gameConfig.MODULES.JOYSTICK   -- Enable joystick module
    t.modules.physics = gameConfig.MODULES.PHYSICS     -- Enable the physics module
end
