local composer = require( "composer" )
local widget = require "widget"
local scene = composer.newScene()
local constants = require("scene.const.constants")

-- MENU LOCAL VAR
local nextBtn, homeBtn, bgUrl

--------------------------------------------------------------

local function onNextBtnRelease()
	composer.gotoScene("scene.game", "fade", 500 )
	return true	-- indicates successful touch
end

local function onHomeBtnRelease()
	composer.gotoScene("scene.menu", "fade", 500 )
	return true	-- indicates successful touch
end

--------------------------------------------------------------


function scene:create( event )
  -- init vars
  buttonSrc = constants.buttonSrc
  buttonWidth = constants.buttonWidth
  buttonHeight = constants.buttonHeight

  local sceneGroup = self.view

  -- set variables according to level result
  local winOrLose = composer.getVariable('winOrLose')
  if winOrLose == 'win' then
    bgUrl = "win.jpg"
    buttonUrl = 'next.png'
  else
    bgUrl = "lose.jpg"
    buttonUrl = 'replay.png'
  end

	-- display a background image
	local background = display.newImageRect(bgUrl, display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
	background.y = 0 + display.screenOriginY

  -- create a widget button (which will loads level1.lua on release)
  nextBtn = widget.newButton(
    {
        width = buttonWidth,
        height = buttonHeight,
        defaultFile = buttonUrl,
        onEvent = onNextBtnRelease	-- event listener function
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
