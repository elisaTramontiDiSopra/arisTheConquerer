local composer = require( "composer" )
local widget = require "widget"
local progress = require("scene.widg.progress")
local constants = require("scene.const.constants")
local scene = composer.newScene()

-- MENU LOCAL VAR
local levelBtn, numberOfLevels, widthFrame, heightFrame
local marginRightLevelTiles, marginBottomLevelTiles = 20, 20
local levelChoice = 1
local levelButtons = {}
local marginX, marginY = 10, 30

--------------------------------------------------------------
local function playLevel(e)
  if e.target.done == true then
    composer.setVariable('playLevel', e.target.label)
    composer.gotoScene("scene.game", "fade", 500 )
  end
end

local function onCreditsBtnRelease()
	composer.gotoScene("scene.credits", "fade", 500 )
	return true	-- indicates successful touch
end

--------------------------------------------------------------

function scene:create( event )
  -- init vars
  numberOfLevels = constants.numberOfLevels
  widthFrame = constants.widthFrame
  heightFrame = constants.heightFrame

  local sceneGroup = self.view

	-- display a background image
	local background = display.newImageRect("background2.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
  background.y = 0 + display.screenOriginY
	sceneGroup:insert( background )

  -- get what is the last level passed
  lastLevel = progress.load()

  -- calculate margins for displaying level buttons
  usableXspace = display.actualContentWidth - 2*marginX
  totCols = math.floor( usableXspace / widthFrame) -- N levels for row
  marginRightLevelTiles = (usableXspace - (widthFrame*totCols)) / totCols - 1

  local col = 0
  -- find what levels are passed and create the different buttons for each level
  for l = 1, numberOfLevels, 1 do
    --check if the level is passed or not
    if l <= lastLevel then
      levelButtons[l] = widget.newButton(
        {
            width = widthFrame,
            height = heightFrame,
            defaultFile = "scene/img/levels/done.png",
            onEvent = playLevel	-- event listener function
        }
      )
      levelButtons[l].done = true
    else
      levelButtons[l] = widget.newButton(
        {
            width = widthFrame,
            height = heightFrame,
            defaultFile = "scene/img/levels/todo.png",
            onEvent = playLevel	-- event listener function
        }
      )
      levelButtons[l].done = false
    end

    row = math.ceil( l / totCols)         -- calculate the row for the Y position
    if row == 0 then row = 1 end

    -- manually calculate cols
    if col == totCols then
      col = 1
    else
      col = col + 1
    end

    --levelButtons[l].row = row
    --levelButtons[l].col = col
    levelTilesSpace = widthFrame + marginRightLevelTiles
    levelButtons[l].x = col*widthFrame
    levelButtons[l].y = row*(heightFrame + marginBottomLevelTiles)
    levelButtons[l].label = l
    label = display.newText(levelButtons[l], l, widthFrame/2, widthFrame/2, "fonts/8-BitMadness.ttf", 46)
    label:setFillColor( 0, 0, 0 )

    sceneGroup:insert( levelButtons[l] )
  end
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
