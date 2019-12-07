local composer = require( "composer" )
local constants = require("scene.const.constants")
local scene = composer.newScene()

-------------------------------------------------------------------------------------

local function goBackToHome()
	composer.gotoScene("scene.menu", "fade", 500 )
end

-------------------------------------------------------------------------------------

function scene:create( event )
  -- init vars
  creditsBg = constants.creditsBg

  local sceneGroup = self.view

  -- display a background image
  local background = display.newImageRect(creditsBg, display.actualContentWidth, display.actualContentHeight )
  background.anchorX = 0
  background.anchorY = 0
  background.x = 0 + display.screenOriginX
  background.y = 0 + display.screenOriginY

  -- all display objects must be inserted into group
  sceneGroup:insert( background )
end

function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
    elseif ( phase == "did" ) then
      -- Code here runs when the scene is entirely on screen
      local countDownTimer = timer.performWithDelay( 5000, goBackToHome)
    end

end

function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end

function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end

-------------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-------------------------------------------------------------------------------------

return scene
