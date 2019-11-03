local M = {}
local physics = require "physics"
local constants = require("scene.const.constants")
-- pathfinder
local Grid = require ("jumper.grid")
local Pathfinder = require ("jumper.pathfinder")



local function findPath(walkableMap, startx, starty, endx, endy)
  print('walkableMap')
  print(walkableMap)
  print('startx')
  print(startx)
  print('starty')
  print(starty)
  print('endx')
  print(endx)
  print('endy')
  print(endy)
  -- Set up a collision map
  local walkableMap = {
    {0,1,0,1,0},
    {0,1,0,1,0},
    {0,1,1,1,0},
    {0,0,0,0,0},
  }

  -- Value for walkable tiles
  local walkable = 0

  -- Creates a grid object
  local grid = Grid(walkableMap)

  -- Creates a pathfinder object using Jump Point Search algorithm
  local myFinder = Pathfinder(grid, 'JPS', walkable)

  -- Define start and goal locations coordinates
  --[[ local startx, starty = 1,1
  local endx, endy = 5,1 ]]

  -- Calculates the path, and its length
  path = myFinder:getPath(startx, starty, endx, endy)
  return path
end


-- Pretty-printing the results
--[[ if path then
  print(('Path found! Length: %.2f'):format(path:getLength()))
	for node, count in path:nodes() do
	  print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
	end
end ]]






-- PLAYER VARS
local player, playerCol, playerRow
local collidedWith = {}
local lastDirection = ""
local path

------------------------------------- EXTRA FUNCTIONS
local function createMarginsForPlayableScreen()
  if display.actualContentWidth > playableScreenWidth then
    marginX = (display.actualContentWidth - playableScreenWidth) / 2
  end
  if display.actualContentHeight > playableScreenHeight then
    marginY = (display.actualContentHeight - playableScreenHeight) / 2
  end
  if display.actualContentWidth == playableScreenWidth then
    marginY = 0
    marginX = 0
  end
end

local function updateTreePeeBar(peeBar, peeLevel)
  peePerc = peeLevel / maxPeeLevel
  peeBar:setProgress(peePerc) -- percentage
end

local function findCharRowCol()
  charRow = math.ceil((char.y) / widthFrame)
  charCol = math.ceil((char.x) / widthFrame)
end

local function checkIfPlayerIsClose(tree)
  findPlayerRowCol()
  local diffRow = math.abs(charRow - tree.row)
  local diffCol = math.abs(charCol - tree.col)
  -- if it's close then return true
  if diffRow < 2 and diffCol < 2 then
    return true
  else
    return false
  end
end

local function charCollision(self, event)
  local nexToObject = false
  if (event.phase == "began" ) then
    -- check if we're close to the tree, less then 1 row and 1 col away
    nexToObject = checkIfPlayerIsClose(event.other)
    if nexToObject == true and event.other.type == 'tree' then
      collidedWith = event.other
    else
      -- NOTHING BECAUSE IT'S NOT A TREE
      -- collidedWith.type = event.other.type
    end
  end
  return true --limit event propagation
end

function callNewPath()
	path = myFinder:getPath(startx, starty, endx, endy)
	if path then
	touchStarted = 1
	print(('Path found! Length: %.2f'):format(path:getLength()))
		for node, count in path:nodes() do
		print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
		print(node:getX())
		print(node:getY())
		setX[#setX+1] = node:getX() -- populating coordinate table on each movement
		setY[#setY+1] = node:getY() -- populating coordinate table on each movement
		cellb[node:getY()][node:getX()].alpha = .8 -- see the path you've chosen!
		moveCount = moveCount+1
		end
	end
end

function printPairs(grid)
  for k,v in pairs(grid) do
    print( k,v )
  end
end


-------------------------------------


--ADD WALBABLE MAP
function M.new(gridRows, gridCols, charRow, charCol, lvl, sceneGroup, imageSrc, pathFinderGrid, treeGrid)

  -- init vars
  widthFrame = constants.widthFrame
  anchorXPoint = constants.anchorXPoint
  anchorYPoint = constants.anchorYPoint
  charSrc = imageSrc
  playerSpeed = constants.playerSpeed
  playerSequenceData = constants.playerSequenceData
  playerSheetOptions = constants.playerSheetOptions
  playerBodyOptions = constants.playerBodyOptions
  peeStream = constants.levelVars[lvl].peeStream
  vanishingPee = constants.levelVars[lvl].vanishingPee

  createMarginsForPlayableScreen()

  -- Create the player
  local imageSheet = graphics.newImageSheet(charSrc, playerSheetOptions)
  char = display.newSprite(imageSheet, playerSequenceData)
  char.anchorX = anchorXPoint
  char.anchorY = anchorYPoint
 -- print('charCol '..charCol)
  --print('charRow '..charRow)
  char.x = charCol * widthFrame + marginX -- -1 is for the anchorPoin 1
  char.y = charRow * heightFrame + marginY
  --print('my '..marginY)
  char.name = 'char'
  char:setSequence("walkingDown")
  char.objectType = char

  -- calculate the path to the first tree
  path = findPath(pathFinderGrid, charRow, charCol, treeGrid[1].row, treeGrid[1].col)
  print('path')
  print(path)

  -- Handle player collision
  char.collision = playerCollision
  char:addEventListener("collision", char)
  physics.addBody(char, "dynamic", playerBodyOptions)

  sceneGroup:insert(char)

  function char:animate(animation)
    char:setSequence(animation)
    char.rotation = 0 -- to prevent player from rotating if walking on an obstacle angle
  end

  function char:pee()
    -- if there is no collidedWith Object exit because you're not close to a tree
    if (collidedWith.peeLevel and collidedWith.peeLevel < maxPeeLevel) then
      collidedWith.peeLevel = collidedWith.peeLevel + peeStream
      peeAnimation = 'pee'..lastDirection
      char:setSequence(peeAnimation)
      updateTreePeeBar(collidedWith.peeBar, collidedWith.peeLevel)
      return collidedWith
    end
  end

  function char:move(path)
    --printPairs(path)
  end

  return char
end

return M -- create M returns the instance
