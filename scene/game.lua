local composer = require( "composer" )
local physics = require "physics"
local widget = require "widget"
local grid = require("scene.widg.grid")
local ply = require("scene.widg.player")
local tmr = require("scene.widg.timer")
local ui = require("scene.widg.ui")
local constants = require("scene.const.constants")

-- SCENE
local lvl, timerSeconds
local player, buttonPressed
local buttonPressed = {Down = false, Up = false, Left = false, Right = false}

local scene = composer.newScene()


function printPairs(grid)
  for k,v in pairs(grid) do
    print( k,v )
  end
end



------------------------------------------------------------------- EXTRA FUNCTIONS
local function initLevelSettings()

  -- get level var
  lvl = composer.getVariable("level")

  -- find the grid dimensions
  gridCols = math.floor(display.actualContentWidth / constants.widthFrame)
  gridRows = math.floor(display.actualContentHeight / constants.heightFrame)
  centerHoriz = math.floor(gridRows/2)
  centerVert = math.floor(gridCols/2)
 -- print(gridRows..' '..gridCols)

  -- set screen dimensions if there are black bands
  playableScreenWidth = constants.widthFrame * gridCols
  playableScreenHeight = constants.widthFrame * gridRows

  -- UI vars
  padButtonDimension = constants.padButtonDimension

  -- timer vars
  timerBarFrameWidth = constants.timerBarFrameWidth
  timerBarFrameHeight = constants.timerBarFrameHeight
  timerBarSrc = constants.timerBarSrc
  timerBarOptions = constants.timerBarOptions
  timerSeconds = constants.levelVars[lvl].timerSeconds     -- seconds to decrease
  totalTimerSeconds = constants.levelVars[lvl].timerSeconds -- to compute the perc for the timer bar

  -- visualize text with a random text inside
  timerText = display.newText( "00:00", display.contentWidth - 50, display.contentHeight, native.systemFont, 18 )
  timerText:setFillColor( 1, 1, 1 )
  timerText.seconds = timerSeconds

  timerBarSheet = graphics.newImageSheet(timerBarSrc, timerBarOptions)
  timerBar = widget.newProgressView(
    {sheet = timerBarSheet,
      fillOuterLeftFrame = 1, fillOuterMiddleFrame = 2, fillOuterRightFrame = 3,
      fillOuterWidth = timerBarFrameWidth, fillOuterHeight = timerBarFrameHeight,
      fillInnerLeftFrame = 4, fillInnerMiddleFrame = 5, fillInnerRightFrame = 6,
      fillWidth = timerBarFrameWidth, fillHeight = timerBarFrameHeight,
      left = marginX, top = display.contentHeight - 10, width = playableScreenWidth, isAnimated = true
    }
  )


  obstacleTile = constants.levelVars[lvl].obstacleTile
  treeTile = constants.levelVars[lvl].treeTile
  pathTile = constants.levelVars[lvl].pathTile

  --totalLevelTrees = levelVars[lvl].trees
  --peeStream = levelVars [lvl].peeStream
  --[[ maxPeeLevel = constants.levelVars[lvl].maxPeeLevel
  minPeeLevel = constants.levelVars[lvl].minPeeLevel
  vanishingPee = constants.levelVars[lvl].vanishingPee ]]
end

-- TIMER CREATION AND UPDATE
local function createTimer()
  -- visualize text with a random text inside
  timerText = display.newText( "00:00", display.contentWidth - 50, display.contentHeight - 30, native.systemFont, 18 )
  --timerText:setFillColor( 1, 1, 1 )
  timerBar = widget.newProgressView(
    {sheet = timerBarSheet,
      fillOuterLeftFrame = 1, fillOuterMiddleFrame = 2, fillOuterRightFrame = 3,
      fillOuterWidth = 10, fillOuterHeight = timerBarFrameHeight,
      fillInnerLeftFrame = 4, fillInnerMiddleFrame = 5, fillInnerRightFrame = 6,
      fillWidth = 10, fillHeight = timerBarFrameHeight,
      left = marginX, top = display.contentHeight - 25, width = playableScreenWidth, isAnimated = true
    }
  )
  timerBar:setProgress(1.0)

end

local function updateTime()
  timerSeconds = timerSeconds - 1
  minutes = math.floor( timerSeconds / 60 )
  seconds = timerSeconds % 60
  timerDisplay = string.format( "%02d:%02d", minutes, seconds )
  timerText.text = timerDisplay
  timerPerc = timerSeconds / totalTimerSeconds
  timerBar:setProgress(timerPerc)

  if timerSeconds < 0 then
    print("END")
    return
  end

end

local function move(event)
  -- set walking animation
  if (event.phase == "began") then
    buttonPressed[event.target.name] = true
    walkAnimation = "walking" .. event.target.name
    player:animate(walkAnimation)
  elseif (event.phase == "ended") then
    buttonPressed[event.target.name] = false
    player:pause()
    --ply:pause()
  end
end

--[[ local function updateTreePeeBar(peeBar, peeLevel)
  peePerc = peeLevel / maxPeeLevel
  peeBar:setProgress(peePerc) -- percentage
end

local function decreasePeeBar(peeBar, peeLevel)
  peeLevel = peeLevel - vanishingPee
  updateTreePeeBar(peeBar, peeLevel)
  return peeLevel
end ]]

local function pee()
  player:pee()
end


local function createUI()
  upBtn = display.newRect(display.contentWidth - 2 * padButtonDimension, display.contentHeight - 3 * padButtonDimension, padButtonDimension, padButtonDimension)
  upBtn:setFillColor(0, 0, 0)
  upBtn.name = "Up"
  upBtn:addEventListener("touch", move)

  downBtn = display.newRect(display.contentWidth - 2 * padButtonDimension,  display.contentHeight - padButtonDimension, padButtonDimension, padButtonDimension)
  downBtn.name = "Down"
  downBtn:setFillColor(0, 0, 0)
  downBtn:addEventListener("touch", move)

  leftBtn = display.newRect(display.contentWidth - 3 * padButtonDimension, display.contentHeight - 2 * padButtonDimension, padButtonDimension, padButtonDimension)
  leftBtn.name = "Left"
  leftBtn:setFillColor(0, 0, 0)
  leftBtn:addEventListener("touch", move)

  rightBtn = display.newRect(display.contentWidth - padButtonDimension, display.contentHeight - 2 * padButtonDimension, padButtonDimension, padButtonDimension)
  rightBtn.name = "Right"
  rightBtn:setFillColor(0, 0, 0)
  rightBtn:addEventListener("touch", move)

    -- peeBtn = display.newRect(playableScreenWidth/2 + padButtonDimension/2, playableScreenHeight - padButtonDimension, padButtonDimension, padButtonDimension)
  peeBtn = display.newCircle(display.contentWidth / 2, display.contentHeight / 2, padButtonDimension, padButtonDimension / 1.5)
  peeBtn:setFillColor(0)
  peeBtn.alpha = 0.3
  peeBtn.name = "Pee"
  peeBtn:addEventListener("touch",pee)
end


local function frameUpdate()
  if timerSeconds == 0 then
    --checkIfLevelIsPassed()
  end

  player.rotation = 0 -- to prevent player from rotating if walking on an obstacle angle

  if buttonPressed['Down'] == true and player.y <
    (gridRows * heightFrame) - heightFrame/2 then
    --collidedWith = nil
    --collidedWith.type = 'empty'
    player.y = player.y + playerSpeed
    lastDirection = 'Down'
  elseif buttonPressed['Up'] == true and player.y >
    (0 + heightFrame) then
    --collidedWith = nil -- as soon as you move delete the last collision
    --collidedWith.type = 'empty'
    player.y = player.y - playerSpeed
    lastDirection = 'Up'
  elseif buttonPressed['Right'] == true and player.x <
    (gridCols * widthFrame) then
    --collidedWith = nil -- as soon as you move delete the last collision
    --collidedWith.type = 'empty'
    player.x = player.x + playerSpeed
    lastDirection = 'Right'
  elseif buttonPressed['Left'] == true and player.x >
    (0 + widthFrame) then
    player.x = player.x - playerSpeed
    lastDirection = 'Left'
  end
end

--[[ local function frameUpdate()
  if timerSeconds == 0 then
    --checkIfLevelIsPassed()
  end
end ]]
---------------------------------------------------------------------------------------



-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create( event )

  -- init vars
  playerSpeed = constants.playerSpeed

	-- Called when the scene's view does not exist.
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	local sceneGroup = self.view
  physics.start()

  -- init game vars
  initLevelSettings()

  -- create the grid
  gridMatrix = grid.new(gridRows, gridCols, lvl)
  printPairs(gridMatrix)

  -- create the player
  player = ply.new(gridRows, gridCols, lvl)
  print(player.isBodyActive)

  -- create the timer
  createTimer()
  local countDownTimer = timer.performWithDelay( 1000, updateTime, timerSeconds)

  -- create the ui
  createUI()
  --ui = ui.new(gridMatrix, lvl)
  --sceneGroup:insert(ui)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen
    -- create the timer
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
    physics.start()
    physics.setGravity( 0,0 )
    Runtime:addEventListener("enterFrame", frameUpdate) -- if the move buttons are pressed MOVE!
    --Runtime:addEventListener("gyroscope", onGyroscopeUpdate)

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
	local sceneGroup = self.view
  -- remove required packages
	package.loaded[physics] = nil
  physics = nil
  package.loaded[grid] = nil
  grid = nil
  package.loaded[ply] = nil
  ply = nil
  package.loaded[tmr] = nil
  tmr = nil
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
