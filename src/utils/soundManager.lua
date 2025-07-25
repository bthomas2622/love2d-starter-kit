-- Sound Manager Module
local love = require("love")
local gameState = require "src.states.gameState"
local gameConfig = require("src.constants.gameConfig")

local soundManager = {}

-- Store audio objects
local music = {}
local sounds = {}

-- Current music track
local currentMusic = nil

-- Load all sound assets
function soundManager.load()
    -- Load music
    music.menu = love.audio.newSource(gameConfig.AUDIO.MENU_MUSIC, "stream")
    music.menu:setLooping(true)
    
    -- Load sound effects
    sounds.menuSelect = love.audio.newSource(gameConfig.AUDIO.SOUNDS.MENU_SELECT, "static")
    sounds.menuMove = love.audio.newSource(gameConfig.AUDIO.SOUNDS.MENU_MOVE, "static")
    sounds.menuBack = love.audio.newSource(gameConfig.AUDIO.SOUNDS.MENU_BACK, "static")
    
    -- Snake game sounds
    if love.filesystem.getInfo("assets/sounds/FruitEat.ogg") then
        sounds.fruitEat = love.audio.newSource("assets/sounds/FruitEat.ogg", "static")
    else
        -- Create a fallback sound using the menu select sound
        sounds.fruitEat = sounds.menuSelect:clone()
    end
end

-- Play music with current volume setting
function soundManager.playMusic(musicName)
    -- Stop current music if any
    soundManager.stopMusic()
    
    if music[musicName] then
        currentMusic = musicName
        music[musicName]:setVolume(gameState.settings.musicVolume)
        music[musicName]:play()
    end
end

-- Stop the currently playing music
function soundManager.stopMusic()
    if currentMusic and music[currentMusic] then
        music[currentMusic]:stop()
        currentMusic = nil
    end
end

-- Play a sound effect with current volume setting
function soundManager.playSound(soundName)
    if sounds[soundName] then
        -- Create a copy of the sound to allow overlapping sounds
        local sound = sounds[soundName]:clone()
        sound:setVolume(gameState.settings.effectsVolume)
        sound:play()
    end
end

-- Update volume levels based on settings
function soundManager.updateVolumes()
    -- Update music volume
    if currentMusic and music[currentMusic] then
        music[currentMusic]:setVolume(gameState.settings.musicVolume)
    end
    
    -- Sound effects will get new volume when they're played
end

-- Update volume levels immediately
function soundManager.updateVolumesNow(musicVolume, effectsVolume)
    if not musicVolume then
        musicVolume = gameState.settings.musicVolume
    end
    if not effectsVolume then
        effectsVolume = gameState.settings.effectsVolume
    end
    -- Update music volume
    if currentMusic and music[currentMusic] then
        music[currentMusic]:setVolume(musicVolume)
    end
    -- Update sound effects volume
    for _, sound in pairs(sounds) do
        sound:setVolume(effectsVolume)
    end
end
-- Stop all sounds

return soundManager
