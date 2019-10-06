local composer = require( "composer" )
local widget = require "widget"
local scene = composer.newScene()
local constants = require("scene.const.constants")

-- MENU LOCAL VAR
local nextBtn, homeBtn

--------------------------------------------------------------

local function onPlayBtnRelease()
	composer.gotoScene("scene.levels", "fade", 500 )
	return true	-- indicates successful touch
end

local function onHomeBtnRelease()
	composer.gotoScene("scene.menu", "fade", 500 )
	return true	-- indicates successful touch
end

--------------------------------------------------------------


function scene:create( event )
	--remobe game scene to reset it
	--composer.removeScene("game.lua")

  -- init vars
  buttonSrc = constants.buttonSrc
  buttonWidth = constants.buttonWidth
  buttonHeight = constants.buttonHeight

  local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect("lose.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
	background.y = 0 + display.screenOriginY

  -- create a widget button (which will loads level1.lua on release)
  nextBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = "next.png",
        onEvent = onPlayBtnRelease	-- event listener function
    }
  )
	nextBtn.x = display.contentCenterX
	nextBtn.y = display.contentHeight - 85

	-- create a widget button (which will loads level1.lua on release)
  homeBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = "home.png",
        onEvent = onHomeBtnRelease	-- event listener function
    }
  )
	homeBtn.x = display.contentCenterX
	homeBtn.y = display.contentHeight - 20

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( nextBtn )
	sceneGroup:insert( homeBtn )
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
