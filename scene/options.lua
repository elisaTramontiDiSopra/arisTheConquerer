local composer = require( "composer" )
local widget = require "widget"
local scene = composer.newScene()
local constants = require("scene.const.constants")

-- MENU LOCAL VAR
local nextBtn, homeBtn, bgUrl, winOrLose

--------------------------------------------------------------

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
        defaultFile = buttonUrl,
        onEvent = onNextBtnRelease	-- event listener function
    }
  )
	nextBtn.x = display.contentCenterX
	nextBtn.y = display.contentHeight - 85

display.setDefault( "anchorX", 0 )

local dot = display.newCircle( display.contentCenterX, display.contentCenterY, 20 )
dot:setFillColor( 0, 0, 1 )
dot.color = "blue"
dot.anchorX = 0.5

local xGravityLabel = display.newText( "xGravity:", 10, 15, native.systemFontBold, 12 )
local yGravityLabel = display.newText( "yGravity:", 10, 31, native.systemFontBold, 12 )
local zGravityLabel = display.newText( "zGravity:", 10, 47, native.systemFontBold, 12 )

local xGravity = display.newText( "", 80, 15, native.systemFont, 12 )
local yGravity = display.newText( "", 80, 31, native.systemFont, 12 )
local zGravity = display.newText( "", 80, 47, native.systemFont, 12 )

local xInstantLabel = display.newText( "xInstant:", 250, 15, native.systemFontBold, 12 )
local yInstantLabel = display.newText( "yInstant:", 250, 31, native.systemFontBold, 12 )
local zInstantLabel = display.newText( "zInstant:", 250, 47, native.systemFontBold, 12 )

local xInstant = display.newText( "", 330, 15, native.systemFont, 12 )
local yInstant = display.newText( "", 330, 31, native.systemFont, 12 )
local zInstant = display.newText( "", 330, 47, native.systemFont, 12 )

local function onTilt( event )
    xGravity.text = event.xGravity
    yGravity.text = event.yGravity
    zGravity.text = event.zGravity
    xInstant.text = event.xInstant
    yInstant.text = event.yInstant
    zInstant.text = event.zInstant

    dot.x = dot.x + event.xGravity + 2
    dot.y = dot.y - event.yGravity - 2

    if dot.x > display.contentWidth then
        dot.x = display.contentWidth
    end
    if dot.x < 0 then
        dot.x = 0
    end
    if dot.y > display.contentHeight then
        dot.y = display.contentHeight
    end
    if dot.y < 0 then
        dot.y = 0
    end

    if event.isShake then
        if dot.color == "blue" then
            dot:setFillColor( 1, 0, 0 )
            dot.color = "red"
        else
            dot:setFillColor( 0, 0, 1 )
            dot.color = "blue"
        end
    end
    return true
end

Runtime:addEventListener( "accelerometer", onTilt )


	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( nextBtn )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		audio.play( soundName,{ channel = 3, loops = 0} )
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
