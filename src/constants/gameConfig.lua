-- Game Configuration Constants
-- This file contains all constants used throughout the game

local gameConfig = {}

-- =============================================================================
-- SCREEN AND SCALING CONSTANTS
-- =============================================================================

-- Virtual canvas dimensions (target resolution)
gameConfig.VIRTUAL_WIDTH = 1280
gameConfig.VIRTUAL_HEIGHT = 720

-- Target aspect ratio for scaling
gameConfig.TARGET_ASPECT_RATIO = 16 / 9

-- Window configuration
gameConfig.WINDOW = {
    TITLE = "My Love2D Game",
    DEFAULT_WIDTH = 800,
    DEFAULT_HEIGHT = 600,
    MIN_WIDTH = 400,
    MIN_HEIGHT = 300,
    RESIZABLE = true
}

-- =============================================================================
-- GAME PLAY CONSTANTS
-- =============================================================================

-- Snake game settings
gameConfig.SNAKE = {
    GRID_SIZE = 40,  -- Size of each grid cell in pixels
    BASE_GAME_SPEED = 0.15,  -- Base time (in seconds) between snake movements
    SPEED_INCREASE = 0.005,  -- How much to decrease the delay per fruit eaten
    MIN_SPEED = 0.05,  -- Minimum speed delay (maximum speed)
    INITIAL_LENGTH = 2,  -- Initial snake body length (excluding head)
    DIRECTION_INPUT_WINDOW = 0.5  -- Accept direction changes during first half of movement cycle
}

-- =============================================================================
-- INPUT CONSTANTS
-- =============================================================================

-- Input timing
gameConfig.INPUT = {
    MENU_REPEAT_DELAY = 0.2,  -- Time in seconds before menu navigation repeats when holding a direction
    REMAPPING_COOLDOWN = 0.5,  -- Cooldown after remapping a key (estimated from usage)
    GAMEPAD_AXIS_THRESHOLD = 0.5  -- Threshold for gamepad analog stick input
}

-- Default key bindings
gameConfig.DEFAULT_KEY_BINDINGS = {
    keyboard = {
        up = "up",
        down = "down",
        left = "left",
        right = "right",
        select = "return",
        back = "escape"
    },
    gamepad = {
        up = "dpup",
        down = "dpdown",
        left = "dpleft",
        right = "dpright",
        select = "a",
        back = "b"
    }
}

-- =============================================================================
-- UI LAYOUT CONSTANTS
-- =============================================================================

-- Menu layout
gameConfig.MENU = {
    BUTTON_WIDTH = 200,   -- Width on the virtual canvas
    BUTTON_HEIGHT = 50,   -- Height on the virtual canvas
    BUTTON_SPACING = 20,  -- Spacing between buttons
    TITLE_Y_OFFSET = 0.25 -- Title position as percentage of screen height
}

-- Settings layout
gameConfig.SETTINGS = {
    TITLE_Y_OFFSET = 0.06,          -- Title position as percentage of screen height
    START_Y_OFFSET = 0.14,          -- Starting Y position for controls
    SPACING_OFFSET = 0.15,          -- Vertical spacing between elements
    CONTROL_WIDTH_RATIO = 0.38,     -- Control width as ratio of screen width
    BUTTON_WIDTH_RATIO = 0.18,      -- Button width as ratio of screen width
    BUTTON_HEIGHT_RATIO = 0.08,     -- Button height as ratio of screen height
    CONTROL_HEIGHT_RATIO = 0.06,    -- Control height as ratio of screen height
    BOTTOM_BUTTON_MARGIN = 20,      -- Margin from bottom of screen for buttons
    SLIDER_STEP_DIVISOR = 20,       -- Slider adjustment step (range / 20)
    DROPDOWN_Y_OFFSET = 30,         -- Y offset for dropdowns
    MAX_VISIBLE_DROPDOWN_OPTIONS = 6
}

-- Controls layout
gameConfig.CONTROLS = {
    TITLE_Y_OFFSET = 0.05,          -- Title position
    HEADER_Y_OFFSET = 0.12,         -- Section headers position
    START_Y_OFFSET = 0.15,          -- Starting Y position for controls
    SPACING_OFFSET = 0.07,          -- Vertical spacing between controls
    COLUMN_WIDTH_RATIO = 0.35,      -- Column width as ratio of screen width
    BUTTON_WIDTH_RATIO = 0.15,      -- Button width as ratio of screen width
    BUTTON_HEIGHT_RATIO = 0.06,     -- Button height as ratio of screen height
    KEYBOARD_X_OFFSET = 200,        -- X offset for keyboard column
    GAMEPAD_X_OFFSET = 20,          -- X offset for gamepad column
    ACTION_LABEL_X_RATIO = 0.2,     -- Action label X position as ratio of screen width
    ACTION_LABEL_Y_OFFSET = 0.02,   -- Y offset for action labels
    MODAL_WIDTH_RATIO = 0.4,        -- Modal dialog width as ratio of screen width
    MODAL_HEIGHT_RATIO = 0.2,       -- Modal dialog height as ratio of screen height
    MODAL_X_RATIO = 0.3,            -- Modal dialog X position as ratio of screen width
    MODAL_Y_RATIO = 0.4             -- Modal dialog Y position as ratio of screen height
}

-- =============================================================================
-- UI COMPONENT CONSTANTS
-- =============================================================================

-- Initialize UI table
gameConfig.UI = {}

-- Button styling
gameConfig.UI.BUTTON = {
    CORNER_RADIUS = 8,              -- Corner radius base value
    BORDER_WIDTH = 1,               -- Border width base value
    FONT_SIZE = 16,                 -- Base font size for virtual canvas
    -- Colors
    NORMAL_COLOR = {0.4, 0.4, 0.5, 1},
    HOVER_COLOR = {0.5, 0.5, 0.6, 1},
    DISABLED_COLOR = {0.3, 0.3, 0.35, 0.7},
    TEXT_COLOR = {1, 1, 1, 1},
    DISABLED_TEXT_COLOR = {0.7, 0.7, 0.7, 0.7},
    BORDER_COLOR = {1, 1, 1, 0.8},
    DISABLED_BORDER_COLOR = {0.5, 0.5, 0.5, 0.5},
    SELECTION_HIGHLIGHT_COLOR = {0.7, 0.7, 1.0, 1.0}
}

-- Slider styling
gameConfig.UI.SLIDER = {
    TRACK_HEIGHT = 10,              -- Visual height of slider track
    CORNER_RADIUS_SCALE = 4,        -- Corner radius multiplied by GUI scale
    HANDLE_WIDTH_SCALE = 10,        -- Handle width multiplied by GUI scale
    HANDLE_HEIGHT_OFFSET = 4,       -- Additional height for handle beyond track
    HANDLE_CORNER_RADIUS = 3,       -- Corner radius for handle
    LABEL_Y_OFFSET = 5,             -- Distance between label and slider
    FONT_SIZE = 16,                 -- Font size for labels
    CLICK_AREA_PADDING = 20,        -- Extra clickable area around slider
    -- Colors
    BAR_COLOR = {0.4, 0.4, 0.5, 1},
    FILL_COLOR = {0.6, 0.6, 0.7, 1},
    HANDLE_COLOR = {0.8, 0.8, 0.9, 1},
    BORDER_COLOR = {1, 1, 1, 0.8},
    TEXT_COLOR = {1, 1, 1, 1}
}

-- Dropdown styling
gameConfig.UI.DROPDOWN = {
    CORNER_RADIUS_SCALE = 4,        -- Corner radius multiplied by GUI scale
    ARROW_SIZE_SCALE = 6,           -- Arrow size multiplied by GUI scale
    ARROW_X_OFFSET_SCALE = 15,      -- Arrow X offset from right edge
    ARROW_MARGIN_SCALE = 10,        -- Arrow margin from edge
    TEXT_X_PADDING_SCALE = 10,      -- Text padding from left edge
    CONTAINER_PADDING_SCALE = 2,    -- Container padding
    BORDER_WIDTH_SCALE = 2,         -- Border width multiplied by GUI scale    TEXT_SCISSOR_PADDING_SCALE = 5, -- Scissor padding for text
    FONT_SIZE = 16,                 -- Font size for dropdown text
    LABEL_FONT_SIZE = 14,           -- Font size for dropdown label
    MAX_VISIBLE_OPTIONS = 10,       -- Maximum visible options in dropdown
    -- Colors
    BACKGROUND_COLOR = {0.4, 0.4, 0.5, 1},
    HOVER_COLOR = {0.5, 0.5, 0.6, 1},
    TEXT_COLOR = {1, 1, 1, 1},
    ARROW_COLOR = {1, 1, 1, 0.8},
    OVERLAY_COLOR = {0.1, 0.1, 0.15, 0.5},
    CONTAINER_COLOR = {0.1, 0.1, 0.15, 0.95},
    BORDER_COLOR = {0.6, 0.6, 0.8, 0.8},
    SELECTED_COLOR = {0.5, 0.5, 0.7, 1},
    SELECTION_HIGHLIGHT_COLOR = {0.8, 0.8, 1.0, 0.3}
}

-- =============================================================================
-- FONT CONSTANTS
-- =============================================================================

gameConfig.FONTS = {
    -- Font sizes for different UI elements (sized for virtual canvas)
    TITLE = 40,          -- Menu titles
    SETTINGS_TITLE = 30, -- Settings screen title
    CONTROLS_TITLE = 30, -- Controls screen title
    LABEL = 16,          -- General labels
    BUTTON = 16,         -- Button text
    SLIDER = 16,         -- Slider labels
    DROPDOWN = 16,       -- Dropdown text
    SCORE = 24,          -- Game score display
    MESSAGE = 36,        -- Game over message
    
    -- Font paths
    DEFAULT_FONT = "assets/fonts/NotoSans-Regular.ttf",
    FALLBACK_FONTS = {
        "assets/fonts/NotoSansArabic-Regular.ttf",
        "assets/fonts/NotoSansBengali-Regular.ttf",
        "assets/fonts/NotoSansJP-Regular.ttf",
        "assets/fonts/NotoSansKR-Regular.ttf",
        "assets/fonts/NotoSansSC-Regular.ttf",
        "assets/fonts/NotoSansDevanagari-Regular.ttf"
    }
}

-- =============================================================================
-- AUDIO CONSTANTS
-- =============================================================================

gameConfig.AUDIO = {
    DEFAULT_MUSIC_VOLUME = 0.7,
    DEFAULT_EFFECTS_VOLUME = 0.8,
    
    -- Audio file paths
    MENU_MUSIC = "assets/music/MenuMusic.ogg",
    SOUNDS = {
        MENU_MOVE = "assets/sounds/MenuMove.ogg",
        MENU_SELECT = "assets/sounds/MenuSelect.ogg",
        MENU_BACK = "assets/sounds/MenuBack.ogg"
    }
}

-- =============================================================================
-- GAME STATE CONSTANTS
-- =============================================================================

-- Default game settings
gameConfig.DEFAULT_SETTINGS = {
    musicVolume = 0.7,
    effectsVolume = 0.8,
    screenSize = {
        width = 1280,
        height = 720
    },
    language = "en"
}

-- Available screen sizes
gameConfig.SCREEN_SIZES = {
    {width = 800, height = 600, label = "800x600"},
    {width = 1024, height = 768, label = "1024x768"},
    {width = 1280, height = 720, label = "1280x720 (720p)"},
    {width = 1920, height = 1080, label = "1920x1080 (1080p)"},
    {width = 3840, height = 2160, label = "3840x2160 (4K)"}
}

-- =============================================================================
-- ASSET PATHS
-- =============================================================================

gameConfig.ASSETS = {
    IMAGES = {
        SNAKE_HEAD = "assets/images/snakeHead.png",
        SNAKE_BODY = "assets/images/snakeBody.png",
        SNAKE_TAIL = "assets/images/snakeTail.png",
        FRUIT = "assets/images/fruit.png"
    },
    
    FONTS = gameConfig.FONTS,  -- Reference to fonts section
    AUDIO = gameConfig.AUDIO   -- Reference to audio section
}

-- =============================================================================
-- CONFIGURATION FLAGS
-- =============================================================================

gameConfig.DEBUG = {
    ENABLE_CONSOLE = true,     -- Enable console output
    PRINT_FONT_LOADING = false -- Print font loading debug info
}

-- Game modules configuration
gameConfig.MODULES = {
    JOYSTICK = true,   -- Enable joystick/gamepad support
    PHYSICS = false    -- Disable physics module (not used)
}

return gameConfig