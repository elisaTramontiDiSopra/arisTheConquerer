local composer = require( "composer" )
local physics = require "physics"
local widget = require "widget"
local grid = require("scene.widg.grid")
local ply = require("scene.widg.player")
local char = require("scene.widg.otherCharacter")
local ui = require("scene.widg.ui")
local progress = require("scene.widg.progress")
local constants = require("scene.const.constants")

-- pathfinder
local Grid = require ("jumper.grid")
local Pathfinder = require ("jumper.pathfinder")
local serpent = require("libs.serpent")

-- SCENE
local lvl, timerSeconds, sceneToPass
local player, buttonPressed, collidedWith
local buttonPressed = {Down = false, Up = false, Left = false, Right = false}
local scene = composer.newScene()
local entryEnemyCel = {}
local path
local steps = 1
local movementGrid = {}


function printPairs(grid)
  for k,v in pairs(grid) do
    print( k,v )
  end
end

------------------------------------------------------------------- EXTRA FUNCTIONS
local function loadLevel()
  -- get level from local var because it's been memorized in the levels view
  lvl = composer.getVariable('playLevel')
  --[[ if (lvl) then
    print("level "..lvl)
  else
    print("C'e' qualche problema con il caricamento del livello salvato")
  end ]]
end

local function initLevelSettings()

  -- find the grid dimensions
  gridCols = math.floor(display.actualContentWidth / constants.widthFrame)
  --gridRows = math.floor(display.actualContentHeight / constants.heightFrame)
  gridRows = math.floor(display.actualContentHeight / constants.heightFrame) -- subtract 1 row for the timer
  centerHoriz = math.floor(gridRows/2)
  centerVert = math.floor(gridCols/2)

  -- set screen dimensions if there are black bands
  playableScreenWidth = constants.widthFrame * gridCols
  playableScreenHeight = constants.widthFrame * gridRows

  -- UI vars
  arrowPadOn = composer.getVariable('arrowPadOn')
  padButtonDimension = constants.padButtonDimension

  -- timer vars
  timerBarFrameWidth = constants.timerBarFrameWidth
  timerBarFrameHeight = constants.timerBarFrameHeight
  timerBarSrc = constants.timerBarSrc
  timerBarOptions = constants.timerBarOptions
  timerSeconds = constants.levelVars[lvl].timerSeconds     -- seconds to decrease
  totalTimerSeconds = constants.levelVars[lvl].timerSeconds -- to compute the perc for the timer bar

  timerBarSheet = graphics.newImageSheet(timerBarSrc, timerBarOptions)

  -- vars to calculate if level is passed
  totalLevelTrees = constants.levelVars[lvl].totalLevelTrees
  minPeeLevel = constants.levelVars[lvl].minPeeLevel

  obstacleTile = constants.levelVars[lvl].obstacleTile
  treeTile = constants.levelVars[lvl].treeTile
  pathTile = constants.levelVars[lvl].pathTile

  -- player vars
  playerSpeed = constants.playerSpeed
  playerSrc = constants.playerSrc

  -- player vars
  enemyDogSrc = constants.enemyDogSrc

  -- pee vars
  maxPeeLevel = constants.levelVars[lvl].maxPeeLevel
  vanishingPee = constants.levelVars[lvl].vanishingPee

  --enemyDog vars
  enemyTransitionTime = constants.levelVars[lvl].enemyTransitionTime
end

-- TIMER CREATION AND UPDATE
local function createTimer(sceneGroup)
  -- visualize text with a random text inside
  timerText = display.newText( "00:00", display.contentWidth - 40, display.contentHeight + 12, "fonts/8-BitMadness.ttf", 22 )
  timerBar = widget.newProgressView(
    {sheet = timerBarSheet,
      fillOuterLeftFrame = 1, fillOuterMiddleFrame = 2, fillOuterRightFrame = 3,
      fillOuterWidth = 10, fillOuterHeight = timerBarFrameHeight,
      fillInnerLeftFrame = 4, fillInnerMiddleFrame = 5, fillInnerRightFrame = 6,
      fillWidth = 10, fillHeight = timerBarFrameHeight,
      left = marginX, top = display.contentHeight, width = playableScreenWidth, isAnimated = true
    }
  )
  timerBar:setProgress(1.0)
  sceneGroup:insert( timerBar )
  sceneGroup:insert( timerText )
end

-- LEVEL WRITING
local function createLevelWriting(sceneGroup)
  levelText = display.newText( "level "..lvl, 50, display.contentHeight + 12, "fonts/8-BitMadness.ttf", 22 )
  sceneGroup:insert( levelText )
end

local function checkIfLevelIsPassed()
  local conqueredTrees = 0

  -- calculate how many trees you have conquered based on the pee level
  for key, value in pairs(gridTree) do
    treeRow = gridTree[key].row
    treeCol = gridTree[key].col
    peeLevel = gridMatrix[treeRow][treeCol].peeLevel
    if (peeLevel > minPeeLevel) then
      conqueredTrees = conqueredTrees + 1
    end
  end

  -- based on the conquered trees visualize the right page
  if conqueredTrees < totalLevelTrees then
    composer.setVariable('winOrLose', 'lose' )
  else
    composer.setVariable('winOrLose', 'win' )
    lvl = lvl + 1
    progress.save(lvl)
  end
  composer.gotoScene("scene.nextLevel", "fade", 500 )

end

local function updateTime()
  timerSeconds = timerSeconds - 1
  minutes = math.floor( timerSeconds / 60 )
  seconds = timerSeconds % 60
  timerDisplay = string.format( "%02d:%02d", minutes, seconds )
  timerText.text = timerDisplay
  timerPerc = timerSeconds / totalTimerSeconds
  timerBar:setProgress(timerPerc)

  if timerSeconds == 0 then
    checkIfLevelIsPassed()
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
  end
end

local function updatePeeBar(peeLevel, peeBar)
  peePerc = peeLevel / maxPeeLevel
  peeBar:setProgress(peePerc) -- percentage
end

local function decreasePeeInAllBars()
  for key, value in pairs(gridTree) do
    treeRow = gridTree[key].row
    treeCol = gridTree[key].col
    peeLevel = gridMatrix[treeRow][treeCol].peeLevel

    if (peeLevel > 0) then
      peeLevel = peeLevel - vanishingPee
      peePerc = peeLevel / maxPeeLevel
      -- set new values in the table and for the bar
      gridMatrix[treeRow][treeCol].peeLevel = peeLevel
      updatePeeBar(peeLevel, gridMatrix[treeRow][treeCol].peeBar)
    end
  end
end

local function pee()
   player:pee()
end

local function createUI(sceneGroup)

  upBtn = display.newRect(display.contentWidth - 2 * padButtonDimension, display.contentHeight - 3 * padButtonDimension, padButtonDimension, padButtonDimension)
  upBtn:setFillColor(0, 0, 0, 0.3)
  upBtn.name = "Up"
  upBtn:addEventListener("touch", move)

  downBtn = display.newRect(display.contentWidth - 2 * padButtonDimension,  display.contentHeight - padButtonDimension, padButtonDimension, padButtonDimension)
  downBtn.name = "Down"
  downBtn:setFillColor(0, 0, 0, 0.3)
  downBtn:addEventListener("touch", move)

  leftBtn = display.newRect(display.contentWidth - 3 * padButtonDimension, display.contentHeight - 2 * padButtonDimension, padButtonDimension, padButtonDimension)
  leftBtn.name = "Left"
  leftBtn:setFillColor(0, 0, 0, 0.3)
  leftBtn:addEventListener("touch", move)

  rightBtn = display.newRect(display.contentWidth - padButtonDimension, display.contentHeight - 2 * padButtonDimension, padButtonDimension, padButtonDimension)
  rightBtn.name = "Right"
  rightBtn:setFillColor(0, 0, 0, 0.3)
  rightBtn:addEventListener("touch", move)

  peeBtn = display.newCircle(display.contentWidth / 2, display.contentHeight / 2, padButtonDimension, padButtonDimension / 1.5)
  peeBtn:setFillColor(0)
  peeBtn.alpha = 0.3
  peeBtn.name = "Pee"
  peeBtn:addEventListener("touch",pee)

  -- add all buttons to scene
  sceneGroup:insert( upBtn )
  sceneGroup:insert( downBtn )
  sceneGroup:insert( leftBtn )
  sceneGroup:insert( rightBtn )
  sceneGroup:insert( peeBtn )
end

local function onTilt( event )
  player.x = player.x - event.xGravity - playerSpeed
  player.y = player.y - event.yGravity - playerSpeed

  -- contein within screen
  if player.x > display.contentWidth then
    player.x = display.contentWidth
  end
  if player.x < 0 then
    player.x = 0
  end
  if player.y > display.contentHeight then
    player.y = display.contentHeight
  end
  if player.y < 0 then
    player.y = 0
  end

  return true
end

-- ENEMY DOG FUNCTIONS
local function whereToEnterTheEnemyDog()

  for c = 1, gridCols do
    for r = 1, gridRows do
      if gridMatrix[r][c].type == 'path' then -- if it's not an obstacle
        entryEnemyCel.row = r
        entryEnemyCel.col = c
        return
      end
    end
  end

end

local function followPath()
  print("# "..#movementGrid)
  print("steps"..steps)
  if steps <= #movementGrid then
    transition.to(enemyDog, { x = movementGrid[steps].x, y = movementGrid[steps].y, time = enemyTransitionTime, onComplete = followPath })
    steps = steps + 1
  end
end

local function moveBasedOnPath(path)
  -- reset path vars
  steps = 1
  movementGrid = {}
  print(path)
  -- populate movementGrid with new path
  for node, count in path:nodes() do
    movementGrid[count] = { x = node:getX() * widthFrame, y = node:getY() * heightFrame }
  end
  followPath()
end


-- PATH FINDING
-- Find a random tree that will be the end point
-- Select the first tree as target then look for the closest free cell and set it as the end point
-- Launch jumper to find the shortest path to the end point and save it in movementGrid

local function findClosestAvailableCell(treeX, treeY)
  print('treeX '..treeX..' treeY '..treeY)
  -- create an array with all the position sourrounding the target tree
  local cellsToChek = {
    {x = treeX - 1, y = treeY + 1 }, {x = treeX, y = treeY + 1 }, {x = treeX + 1, y = treeY + 1 },
    {x = treeX - 1, y = treeY},                                   {x = treeX + 1, y = treeY},
    {x = treeX + 1, y = treeY - 1 }, {x = treeX, y = treeY - 1 }, {x = treeX + 1, y = treeY + 1 },
  }
  -- loop trough those cells, make sure they're on the grid (not < 0), then return the first that is free
  for n, cell in pairs(cellsToChek) do
    row = cellsToChek[n].x
    col = cellsToChek[n].y
    print(row)
    print(col)
    -- if row == 0 or col == 0 there is a possible error in pathFInderGrid, since there is no continue to skip do x+1
    if row == 0 then row = 1 end
    if col == 0 then col = 1 end
    -- if it's a valid row and it's not an obstacle (wlkable == 0), return the cell coords
    if row > 0 and row <= gridRows and pathFinderGrid[row][col] == 0 then
      print('row ok')
      print('pathFinderGrid[row][col] '..pathFinderGrid[row][col] )
      return cellsToChek[n]
    elseif col > 0 and col <= gridRows and pathFinderGrid[row][col] == 0 then
      print('col ok')
      return cellsToChek[n]
    end
  end
end

local function findPath(endX, endY)
  -- init vars for pathfinding
  local walkable = 0
  local grid = Grid(pathFinderGrid)
  local myFinder = Pathfinder(grid, 'JPS', walkable) -- use A* instead of JPS to avoid diagonal passages and possible problems with bodies
  myFinder:setMode('ORTHOGONAL')

  path = myFinder:getPath(entryEnemyCel.col, entryEnemyCel.row, endY, endX)
  print('path')
  print(path)
  moveBasedOnPath(path)

end

local function findThePathToATree()
  -- pick a random tree
  local r = math.random(#gridTree)
  -- find the closest available cell to make it the end path cell
  local endPathCell = findClosestAvailableCell(gridTree[r].row, gridTree[r].col)
  -- find the path
  print('x '..endPathCell.x)

  print('y '..endPathCell.y)
  findPath(endPathCell.x, endPathCell.y)

end


local function visualizeEnemyDog(sceneGroup)
  -- calculate where to make the dog enter: 1 column, down row till you find an empty one
  whereToEnterTheEnemyDog()

  -- create the enemy dog
  enemyDog = char.new(gridRows, gridCols, entryEnemyCel.row, entryEnemyCel.col, lvl, sceneToPass, enemyDogSrc, pathFinderGrid, gridTree)

  findThePathToATree()

end





local function frameUpdate()
  --print('p x'..player.x)
  if buttonPressed['Down'] == true and player.y <
    (gridRows * heightFrame) - heightFrame/2 then
    --collidedWith = nil
    --collidedWith.type = 'empty'
    player.y = player.y + playerSpeed
    lastDirection = 'Down'
  elseif buttonPressed['Up'] == true and player.y >
    (0 + heightFrame/4) then
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

---------------------------------------------------------------------------------------

local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create( event )
  -- Enable auto-recycle on scene change
  composer.recycleOnSceneChange = true

  -- load level
  loadLevel()

	local sceneGroup = self.view
  physics.start()
  physics.setGravity(0,0)

  -- init game vars
  initLevelSettings()

  -- create the grid
  twoGrids = grid.new(gridRows, gridCols, lvl, sceneGroup)
  gridMatrix = twoGrids.gridMatrix          -- I returned multiple grids
  gridTree = twoGrids.gridTree              -- I returned multiple grids
  pathFinderGrid = twoGrids.pathFinderGrid  -- I returned multiple grids

  -- create the player
  player = ply.new(gridRows, gridCols, lvl, sceneGroup, playerSrc)

  -- create the enemy dog after 5 seconds
  sceneToPass = sceneGroup
  timer.performWithDelay( 5000, visualizeEnemyDog)

  -- create the timer
  createTimer(sceneGroup)
  local countDownTimer = timer.performWithDelay( 1000, updateTime, timerSeconds)

  -- create the level text
  createLevelWriting(sceneGroup)

  -- decrease pee levels in trees for all the game
  local countDownPee = timer.performWithDelay( 1000, decreasePeeInAllBars, timerSeconds)

  -- create the ui
  if arrowPadOn then
    createUI(sceneGroup)
  end
  --sceneGroup:insert(player)

end

function scene:show( event )
	local phase = event.phase

	if phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen INSERT code here to make the scene come alive
    -- randomly play bark sounds during the game
    audio.play( barkSound, {channel = 2})

    Runtime:addEventListener("enterFrame", frameUpdate) -- if the move buttons are pressed MOVE!
    Runtime:addEventListener( "accelerometer", onTilt )
    --Runtime:addEventListener("gyroscope", onGyroscopeUpdate)

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
	-- Called prior to the removal of scene's "view" (sceneGroup)
	local sceneGroup = self.view
  -- remove required packages
	package.loaded[physics] = nil
  physics = nil
  package.loaded[grid] = nil
  grid = nil
  package.loaded[ply] = nil
  ply = nil
  package.loaded[constants] = nil
  constants = nil
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene


--[[
  insert the enemy dog at 1.1 check if it.s free, if it's not go t 1.2, if it's not free go to 1.3 ...
  create a matrix and using the dixtra algorithm or minimum spanning tree mst go to the first tree


]]
-- algoritmo di dixtra (pesato) non pesato  minumium spanning tree mst
