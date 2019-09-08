local composer = require( "composer" )
local physics = require "physics"
local widget = require "widget"
local grid = require("scene.widg.grid")
local ply = require("scene.widg.player")
local constants = require("scene.const.constants")

function printPairs(grid)
  for k,v in pairs(grid) do
    print( k,v )
  end
end

------------------------------------------------------------------- EXTRA FUNCTIONS
local function initLevelSettings()

end
---------------------------------------------------------------------------------------

function scene:create( event )

end

function scene:show( event )

end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		-- physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end

end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.

end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
