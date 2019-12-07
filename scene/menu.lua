local composer = require( "composer" )
local widget = require "widget"
local scene = composer.newScene()
local constants = require("scene.const.constants")

-- MENU LOCAL VAR
local playBtn, creditsBtn

--------------------------------------------------------------

local function onPlayBtnRelease()
	composer.gotoScene("scene.levels", "fade", 500 )
	return true	-- indicates successful touch
end

local function onCreditsBtnRelease()
	composer.gotoScene("scene.credits", "fade", 500 )
	return true	-- indicates successful touch
end

local function onTutorialBtnRelease()
	composer.gotoScene("scene.tutorial", "fade", 500 )
	return true	-- indicates successful touch
end

local function onOptionBtnRelease()
	composer.gotoScene("scene.options", "fade", 500 )
	return true	-- indicates successful touch
end

--------------------------------------------------------------


function scene:create( event )
  -- init vars
  buttonSrc = constants.buttonSrc
  buttonWidth = constants.buttonWidth
	buttonHeight = constants.buttonHeight
	playBtnBg = constants.playBtn
	creditsBtnBg = constants.creditsBtn
	tutorialBtnBg = constants.tutorialBtn
	optionBtnBg = constants.optionBtn

	local sceneGroup = self.view

  -- level variable
	composer.setVariable("level", 1)

	-- display a background image
	local background = display.newImageRect("background2.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
	background.y = 0 + display.screenOriginY

  -- create a widget button (which will loads level1.lua on release)
  playBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = playBtnBg,
        onEvent = onPlayBtnRelease	-- event listener function
    }
  )
	playBtn.x = display.contentCenterX
	playBtn.y = 155

	creditsBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = creditsBtnBg,
        onEvent = onCreditsBtnRelease	-- event listener function
    }
  )
	creditsBtn.x = display.contentCenterX
	creditsBtn.y = 365

	-- create a widget button (which will loads level1.lua on release)
  tutorialBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = tutorialBtnBg,
        onEvent = onTutorialBtnRelease	-- event listener function
    }
  )
	tutorialBtn.x = display.contentCenterX
	tutorialBtn.y = 295

-- create a widget button (which will loads level1.lua on release)
  optionBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = optionBtnBg,
        onEvent = onOptionBtnRelease	-- event listener function
    }
  )
	optionBtn.x = display.contentCenterX
	optionBtn.y = 225


	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( creditsBtn )
	sceneGroup:insert( tutorialBtn )
	sceneGroup:insert( optionBtn )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.

	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
