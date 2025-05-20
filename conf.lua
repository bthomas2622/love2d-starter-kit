local love = require("love")

function love.conf(t)
    t.title = "Love2D Game"            -- The title of the window the game is in
    t.version = "11.4"                 -- The LÖVE version this game was made for
    t.window.width = 800               -- Game's default window width
    t.window.height = 600              -- Game's default window height
    t.window.resizable = true          -- Let the user resize the window
    t.console = true                   -- Enable console output for debugging
    
    -- For Windows, macOS and Linux
    t.identity = "love2d_game"         -- The name of the save directory (string)
    t.appendidentity = true            -- Search files in source directory before save directory
      -- Modules that you don't need can be disabled to save memory
    t.modules.joystick = true          -- Enable joystick module
    t.modules.physics = false          -- Enable the physics module
end
