local composer = require( "composer" )
local widget = require "widget"
local scene = composer.newScene()
local progress = require("scene.widg.progress")
local constants = require("scene.const.constants")

-- MENU LOCAL VAR
local creditsBtn, bgUrl, winOrLose, padBg, accelerometerBg, controlType, onBtn, offBtn

--------------------------------------------------------------

local function onPadBtnRelease(event)
  if event.target.name == 'accelBtn' then
		accelBtn.isVisible = false
		composer.setVariable('arrowPadOn', false)
		controlType = 'accel'
	else
		accelBtn.isVisible = true
		composer.setVariable('arrowPadOn', true)
		controlType = 'pad'
	end
end

local function onMusicBtnRelease(event)
  if event.target.name == 'offBtn' then
		offBtn.isVisible = false
		composer.setVariable('musicOn', false)
		musicState = 'off'
	else
		offBtn.isVisible = true
		composer.setVariable('musicOn', true)
		musicState = 'on'
	end
end

local function onHomeBtnRelease()
	composer.gotoScene("scene.menu", "fade", 500 )
	return true	-- indicates successful touch
end

local function onSaveBtnRelease()
	-- check music saved parameters and start or stop music accordingly
	if musicState == 'on' then
		audio.play( backgroundMusic, { channel=1, loops=-1, fadein=2000 } )
	else
		audio.stop()
	end

	--progress.saveControlOptions(controlType)
	composer.gotoScene("scene.menu", "fade", 500 )
	return true	-- indicates successful touch
end

--------------------------------------------------------------

function scene:create( event )
  -- init vars
  buttonWidth = constants.buttonWidth
	buttonHeight = constants.buttonHeight
	padBgOn = constants.padBtn
	accelerometerOn = constants.accelerometerOn
	saveBg = constants.saveBtn
	musicOnBg = constants.musicOn
	musicOffBg = constants.musicOff
	optionsBg = constants.optionsBg

	sceneGroup = self.view

  -- display a background image
  local background = display.newImageRect(optionsBg, display.actualContentWidth, display.actualContentHeight )
  background.anchorX = 0
  background.anchorY = 0
  background.x = 0 + display.screenOriginX
  background.y = 0 + display.screenOriginY

	print('options')
	print(controlSystem)

	-- create and visualize buttons
  padBtn = widget.newButton(
    {
        width = buttonWidth,
				height = buttonHeight,
        defaultFile = padBgOn,
        onRelease = onPadBtnRelease	-- event listener function
    }
	)
	padBtn.name = 'padBtn'
	padBtn.x = display.contentCenterX
	padBtn.y = display.contentHeight - 320

	accelBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = accelerometerOn,
        onRelease = onPadBtnRelease	-- event listener function
    }
	)
	accelBtn.name = 'accelBtn'
	accelBtn.x = display.contentCenterX
	accelBtn.y = display.contentHeight - 320

	onBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = musicOnBg,
        onRelease = onMusicBtnRelease	-- event listener function
    }
	)
	onBtn.name = 'onBtn'
	onBtn.x = display.contentCenterX
	onBtn.y = display.contentHeight - 200

	offBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = musicOffBg,
        onRelease = onMusicBtnRelease	-- event listener function
    }
	)
	offBtn.name = 'offBtn'
	offBtn.x = display.contentCenterX
	offBtn.y = display.contentHeight - 200


	if controlType == 'pad' then
		accelBtn.isVisible = false
	else
		accelBtn.isVisible = true
	end

  saveBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = saveBg,
        onEvent = onSaveBtnRelease	-- event listener function
    }
  )
	saveBtn.x = display.contentCenterX
	saveBtn.y = display.contentHeight - 70

  -- all display objects must be inserted into group
  sceneGroup:insert( background )
	sceneGroup:insert( saveBtn )
	sceneGroup:insert( padBtn )
	sceneGroup:insert( accelBtn )
	sceneGroup:insert( onBtn )
	sceneGroup:insert( offBtn )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- audio.play( soundName,{ channel = 3, loops = 0} ) -- barking sound ???????????????????
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
	-- Called prior to the removal of scene's "view" (sceneGroup)
	accelBtn:removeSelf()	-- widgets must be manually removed
	accelBtn = nil
	padBtn:removeSelf()	-- widgets must be manually removed
	padBtn = nil
	-- remove required packages
	package.loaded[progress] = nil
  progress = nil
  package.loaded[constants] = nil
  constants = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
