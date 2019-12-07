-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"
local constants = require("scene.const.constants")

-- load menu screen
composer.gotoScene("scene.menu")

-- load all sounds
backgroundMusic = audio.loadSound( "audio/8bitHappy.mp3")
barkSound = audio.loadSound( "audio/bark.mp3" )
winSound = audio.loadSound( "audio/win2.mp3" )
loseSound = audio.loadSound( "audio/lose.mp3" )

-- music option, on or off
musicOn = composer.getVariable('musicOn', musicOn )
if musicState == nil then
  -- if the variable is not set it's the first time so set it as in the config file
  musicOn = constants.musicOn
  composer.setVariable('musicOn', musicOn)
end

-- controls option, arrow pad on or accelerometer controls
arrowPadOn = composer.getVariable('arrowPadOn')
if arrowPadOn == nil then
  -- if the variable is not set it's the first time so set it as in the config file
  arrowPadOn = constants.arrowPadOn
  composer.setVariable('arrowPadOn', arrowPadOn)
end

if musicOn == true then
  audio.play( backgroundMusic, { channel=1, loops=-1, fadein=2000 } )
end
audio.setVolume( 0.3 )  -- set the master volume
