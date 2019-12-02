local composer = require( "composer" )
local widget = require "widget"
local scene = composer.newScene()
local progress = require("scene.widg.progress")
local constants = require("scene.const.constants")

-- MENU LOCAL VAR
local creditsBtn, bgUrl, winOrLose, padBg, accelerometerBg, controlType

--------------------------------------------------------------

local function onPadBtnRelease(event)
	print('pressed')
  if event.target.name == 'accelBtn' then
		accelBtn.isVisible = false
		composer.setVariable('arrowPadOn', false)
		controlType = 'accel'
	else
		accelBtn.isVisible = true
		composer.setVariable('arrowPadOn', true)
		controlType = 'pad'
	end
	print('controlType')
	print(controlType)
end

local function onHomeBtnRelease()
	composer.gotoScene("scene.menu", "fade", 500 )
	return true	-- indicates successful touch
end

local function onSaveBtnRelease()
	--progress.saveControlOptions(controlType)
	composer.gotoScene("scene.menu", "fade", 500 )
	return true	-- indicates successful touch
end

--------------------------------------------------------------

function scene:create( event )
  -- init vars
  buttonSrc = constants.buttonSrc
  buttonWidth = constants.buttonWidth
	buttonHeight = constants.buttonHeight
	padBgOn = constants.padOn
	padBgOff = constants.padOff
	accelerometerOn = constants.accelerometerOn
	accelerometerOff = constants.accelerometerOff
	saveBg = constants.save

	sceneGroup = self.view

  -- display a background image
  local background = display.newImageRect("options.jpg", display.actualContentWidth, display.actualContentHeight )
  background.anchorX = 0
  background.anchorY = 0
  background.x = 0 + display.screenOriginX
  background.y = 0 + display.screenOriginY

	-- get what is the last level passed
  controlSystem = progress.loadControlOptions()

	print('options')
	print(controlSystem)

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
	padBtn.y = display.contentHeight - 270

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
	accelBtn.y = display.contentHeight - 270

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
	saveBtn.y = display.contentHeight - 120

  -- all display objects must be inserted into group
  sceneGroup:insert( background )
	sceneGroup:insert( saveBtn )
	sceneGroup:insert( padBtn )
	sceneGroup:insert( accelBtn )
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
