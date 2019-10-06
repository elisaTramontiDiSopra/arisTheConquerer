-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

-- load menu screen
composer.gotoScene("scene.menu")

-- load all sounds
backgroundMusic = audio.loadSound( "audio/8bitHappy.mp3")
--peeSound = audio.loadSound( "audio/fire.wav" )
barkSound = audio.loadSound( "audio/bark.mp3" )
winSound = audio.loadSound( "audio/win2.mp3" )
loseSound = audio.loadSound( "audio/lose.mp3" )

audio.play( backgroundMusic, { channel=1, loops=-1, fadein=2000 } )
audio.setVolume( 0.3 )  -- set the master volume
