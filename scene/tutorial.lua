local composer = require( "composer" )
local scene = composer.newScene()
local constants = require("scene.const.constants")

local bgTab = {
  "screens/tutorial1.jpg",
  "screens/tutorial2.jpg",
  "screens/tutorial3.jpg",
  "screens/tutorial4.jpg"
}
local i = 0
local background, centralBtn

------------------------------------------------------------

local function displayBackground(bgImage)
  -- display a background image
	background = display.newImageRect(bgImage, display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
  background.y = 0 + display.screenOriginY
end

local function moveOn()
  i = i + 1
  bgImage = bgTab[i]
  print(i)
  if i <= 4 then
    display.remove( background )
    display.remove( centralBtn )

    background = display.newImageRect(bgImage, display.actualContentWidth, display.actualContentHeight )
    background.anchorX = 0
    background.anchorY = 0
    background.x = 0 + display.screenOriginX
    background.y = 0 + display.screenOriginY

    centralBtn = display.newCircle(display.contentWidth / 2, display.contentHeight / 2, padButtonDimension, padButtonDimension / 1.5)
    centralBtn:setFillColor(0)
    centralBtn.alpha = 0.1
    centralBtn.name = "On"
    centralBtn:addEventListener("tap", moveOn)

  elseif i > 4 then
    display.remove( background )
    display.remove( centralBtn )
    composer.gotoScene("scene.menu", "fade", 500 )
  end
end


------------------------------------------------------------

function scene:create( event )
  -- UI vars
  padButtonDimension = constants.padButtonDimension

  local sceneGroup = self.view
  moveOn()

	-- all display objects must be inserted into group
  sceneGroup:insert( background )
  sceneGroup:insert( centralBtn )
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


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
