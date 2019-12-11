local composer = require( "composer" )
local physics = require "physics"
local widget = require "widget"
local grid = require("scene.widg.grid")
local ply = require("scene.widg.player")
local char = require("scene.widg.otherCharacter")
local progress = require("scene.widg.progress")
local tilt = require("scene.widg.tilt")
local constants = require("scene.const.constants")

-- pathfinder
local Grid = require ("jumper.grid")
local Pathfinder = require ("jumper.pathfinder")
local serpent = require("libs.serpent")

-- SCENE
local lvl, timerSeconds, sceneToPass
local player, buttonPressed --collidedWith,
local enemyDog, enemyCollidedWith, visualizeEnemy, peeStream, enemyPeeActions, enemyPeeVelocity, enemyPeeTrees
local buttonPressed = {Down = false, Up = false, Left = false, Right = false}
local scene = composer.newScene()
local entryEnemyCel = {}
local entryPoint = {}
local path
local countDownTimer
local lastPath = false
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
  gyro = composer.getVariable('gyroscope')
  --[[ if (lvl) then
    print("level "..lvl)
  else
    print("C'e' qualche problema con il caricamento del livello salvato")
  end ]]
end

local function initLevelSettings()

  -- find the grid dimensions
  gridCols = math.floor(display.actualContentWidth / constants.widthFrame)
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

  -- reset global var for player hitting enemy
  progress.playerCollidedWithEnemy = false

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
  visualizeEnemy = constants.levelVars[lvl].visualizeEnemy
  enemyTransitionTime = constants.levelVars[lvl].enemyTransitionTime
  peeStream = constants.levelVars[lvl].peeStream
  enemyPeeVelocity = constants.levelVars[lvl].enemyPeeVelocity
  enemyPeeTrees = constants.levelVars[lvl].enemyPeeTrees
  enemyDogTreesDone = 0

  print('timerSeconds')
  print(timerSeconds)
end

local findPath -- placed here because I call it on higher functions

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
  -- check if the player collided with the enemy and in that case stop timer and go to brawl page
  if countDownTimer and progress.playerCollidedWithEnemy == true then -- countDownTimer is needed because when it gets called the first time countDownTimer is nil
    timerSeconds = 0
    timer.cancel(countDownTimer) -- stop the count down
    composer.gotoScene("scene.brawl", "fade", 150 )
  else
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
  animation = 'walkDown'
  if event.xGravity > 0 then animation = 'walkLeft'
  elseif event.yGravity > 0 then animation = 'walkUp'
  elseif event.xGravity < 0 then animation = 'walkRight' end
  player:animate(animation)
  tilt.tilt(player, event)
end

-----------------------------------------------
-- ENEMY DOG FUNCTIONS
-----------------------------------------------
local findThePathToATree
local function whereToEnterTheEnemyDog()

  for c = 1, gridCols do
    for r = 1, gridRows do
      if gridMatrix[r][c].type == 'path' then -- if it's not an obstacle
        entryEnemyCel.row = r
        entryEnemyCel.col = c
        entryPoint.row = r -- use them later to exit the dog, keep them here to avoid overwriting
        entryPoint.col = c -- use them later to exit the dog
        return
      end
    end
  end

end

local function enemyDogPees()
  if enemyDog == nil then return end -- safe escape for problems if hitting the player when the scene is deleting
  enemyDog:pee(enemyCollidedWith)
end

local function checkIfEnemyDogIsDone()
  if enemyDog == nil then return end -- safe escape for problems if hitting the player when the scene is deleting

  -- if you've done the trees youre supposed to visit then return to the entry point
  if enemyDogTreesDone == enemyPeeTrees then
    -- find the path to the point where you entered, use true as third parameter to say this is the exit path
    lastPath = true
    findPath(entryPoint.row, entryPoint.col)
  else
    -- reset the position and find another tree
    enemyDogTreesDone = enemyDogTreesDone + 1
    entryEnemyCel.row = math.floor(enemyDog.y/heightFrame)
    entryEnemyCel.col = math.floor(enemyDog.x/widthFrame)
    findThePathToATree()
  end
end

local function checkDirectionForAnimation(steps)
  local previousStep = steps - 1
  local animation = 'walkingDown'
  -- check the direction of movment
  if movementGrid[steps].x > movementGrid[previousStep].x then
    animation = 'walkingRight'
  elseif movementGrid[steps].x < movementGrid[previousStep].x then
    animation = 'walkingLeft'
  elseif movementGrid[steps].y < movementGrid[previousStep].y then
    animation = 'walkingUp'
  end
  return animation
end

local function removeEnemy()
  display.remove(enemyDog)
end

local function followPath()

  if steps <= #movementGrid then
    transition.to(enemyDog, { x = movementGrid[steps].x, y = movementGrid[steps].y, time = enemyTransitionTime, onComplete = followPath })
    if enemyDog == nil then return end -- safe escape for problems if hitting the player when the scene is deleting
    enemyDog:animate(movementGrid[steps].animation)
    steps = steps + 1
  else
    -- if it was the lastPath then make enemyDog disappear
    if lastPath == true then
      -- play the puff! animation then remove the enemy from the game
      --print('PUF!')
      local anim = 'puff'
      enemyDog:animate(anim)

      timer.performWithDelay( 1000, removeEnemy)
      return
    end

    -- you're arrived, pee till peelevel reaches 0
    for i = 0, enemyPeeActions do
      timer.performWithDelay( enemyPeeVelocity, enemyDogPees)
      i = i + 1
    end

    checkIfEnemyDogIsDone()

  end
end

local function moveBasedOnPath(path, lastPath)
  -- reset path vars
  steps = 1
  movementGrid = {}
  -- populate movementGrid with new path
  for node, count in path:nodes() do
    movementGrid[count] = { x = (node:getX() * heightFrame) , y = (node:getY() * widthFrame) }
    print('X '..node:getX()..' y '..node:getY()  )

    -- add movment direction for animation
    if count == 1 then
      -- this is the first step, the default start animation is walkingDown
      movementGrid[count].animation = 'walkingDown'
    else
      -- calculate direction and set the animation
      local animation = checkDirectionForAnimation(count)
      movementGrid[count].animation = animation
    end
  end
  followPath()
end

local function findClosestAvailableCell(treeX, treeY)
  -- create an array with all the position sourrounding the target tree
  local cellsToChek = {
                                {x = treeX, y = treeY + 1 },
    {x = treeX - 1, y = treeY},                              {x = treeX + 1, y = treeY},
                                {x = treeX, y = treeY - 1 },
  }
  -- loop trough those cells, make sure they're on the grid (not < 0), then return the first that is free
  for n, cell in pairs(cellsToChek) do
    row = cellsToChek[n].x
    col = cellsToChek[n].y
    -- if row == 0 or col == 0 there is a possible error in pathFInderGrid, since there is no continue to skip do x+1
    if row == 0 then row = 1 end
    if col == 0 then col = 1 end
    -- if it's a valid row and it's not an obstacle (wlkable == 0), return the cell coords
    if row > 0 and row <= gridRows and pathFinderGrid[row][col] == 0 then
      return cellsToChek[n]
    elseif col > 0 and col <= gridCols and pathFinderGrid[row][col] == 0 then
      return cellsToChek[n]
    end
  end
end

function findPath(endX, endY)
  -- init vars for pathfinding
  local walkable = 0
  local grid = Grid(pathFinderGrid)
  local myFinder = Pathfinder(grid, 'JPS', walkable) -- use A* instead of JPS to avoid diagonal passages and possible problems with bodies
  myFinder:setMode('ORTHOGONAL')
  path = myFinder:getPath(entryEnemyCel.col, entryEnemyCel.row, endY, endX)
  moveBasedOnPath(path)
end

function findThePathToATree()
  -- pick a random tree and save it as enemyCollidedWith object so I can pass it along later for the pee function
  local r = math.random(#gridTree)
  treeRow = gridTree[r].row
  treeCol = gridTree[r].col
  enemyCollidedWith = gridMatrix[treeRow][treeCol]
  -- calculate how many pee actions are needed to take the pee level to 0
  enemyPeeActions = (enemyCollidedWith.peeLevel / peeStream ) + 1 -- +1 is to cover if there is an eventual reminder

  -- find the closest available cell to make it the end path cell
  local endPathCell = findClosestAvailableCell(gridTree[r].row, gridTree[r].col)
  -- find the path
  findPath(endPathCell.x, endPathCell.y, false)
end

local function visualizeEnemyDog(sceneGroup)
  -- calculate where to make the dog enter: 1 column, down row till you find an empty one
  whereToEnterTheEnemyDog()
  -- create the enemy dog
  print('entro row and col')
  print(entryEnemyCel.row..' '..entryEnemyCel.col)
  enemyDog = char.new(gridRows, gridCols, entryEnemyCel.row, entryEnemyCel.col, lvl, sceneToPass, enemyDogSrc, pathFinderGrid, gridTree, gridMatrix)
  findThePathToATree()
end

local function frameUpdate()
  if buttonPressed['Down'] == true and player.y <
    (gridRows * heightFrame) - heightFrame/2 then
    player.y = player.y + playerSpeed
    --lastDirection = 'Down'
  elseif buttonPressed['Up'] == true and player.y >
    (0 + heightFrame/4) then
    player.y = player.y - playerSpeed
    --lastDirection = 'Up'
  elseif buttonPressed['Right'] == true and player.x <
    (gridCols * widthFrame) then
    player.x = player.x + playerSpeed
    --lastDirection = 'Right'
  elseif buttonPressed['Left'] == true and player.x >
    (0 + widthFrame) then
    player.x = player.x - playerSpeed
    --lastDirection = 'Left'
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
  --physics.setDrawMode( "hybrid" )

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
  if visualizeEnemy == true then
    timer.performWithDelay( 5000, visualizeEnemyDog)
  end

  -- create the timer
  createTimer(sceneGroup)
  countDownTimer = timer.performWithDelay( 1000, updateTime, timerSeconds) -- countDownTimer is the handler to cancel, it's a tab
  print('countDownTimer CREATED')
  print(countDownTimer)

  -- create the level text
  createLevelWriting(sceneGroup)

  -- decrease pee levels in trees for all the game
  local countDownPee = timer.performWithDelay( 1000, decreasePeeInAllBars, timerSeconds)

  -- create the ui or activate gyroscope
  if arrowPadOn then
    createUI(sceneGroup)
  end

end

function scene:show( event )
	local phase = event.phase

	if phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
    -- Called when the scene is now on screen INSERT code here to make the scene come alive

    -- play bark sounds during the game
    audio.play( barkSound, {channel = 2})

    Runtime:addEventListener("enterFrame", frameUpdate) -- if the move buttons are pressed MOVE!

    -- create the ui or activate gyroscope
    if arrowPadOn == false then
      Runtime:addEventListener( "accelerometer", onTilt )
    end
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
  package.loaded[char] = nil
  char = nil
  enemyDog = nil
end

---------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
