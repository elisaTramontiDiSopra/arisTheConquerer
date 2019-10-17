-- grid.lua creates the grid but doesn't do anything else

local M = {}
local physics = require "physics"
local widget = require "widget"
local constants = require("scene.const.constants")

-- TILES VARS
local gridMatrix = {}
local obstacleGrid = {}
local treeGrid = {}
local toReturn = {}
local marginX, marginY = 0, 0
local gridGroup --to insert it on the scene

-------------------------------------------------------------------------- EXTRA FUNCTIONS
local function initVars(lvl)
  -- reset grids
  gridMatrix = nil
  treeGrid = nil
  gridMatrix = {}
  treeGrid = {}
  -- init vars
  anchorXPoint = constants.anchorXPoint
  anchorYPoint = constants.anchorYPoint
  widthFrame = constants.widthFrame
  heightFrame = constants.heightFrame
  obstaclesSrc = constants.levelVars[lvl].obstaclesSrc
  obstacles = constants.obstacles
  pathTile = constants.levelVars[lvl].pathTile
  pathTracerMoves = constants.levelVars[lvl].pathTracerMoves
  totalLevelTrees = constants.levelVars[lvl].totalLevelTrees
  minPeeLevel = constants.levelVars[lvl].minPeeLevel
  maxPeeLevel = constants.levelVars[lvl].maxPeeLevel
  peeBarFrameWidth = constants.peeBarFrameWidth
  peeBarFrameHeight = constants.peeBarFrameHeight
  peeBarSrc = constants.peeBarSrc
  peeBarOptions = constants.peeBarOptions
  vanishingPee = constants.vanishingPee
end

local function createMarginsForPlayableScreen()
  if display.actualContentWidth > playableScreenWidth then
    marginX = (display.actualContentWidth - playableScreenWidth) / 2
  end
  if display.actualContentHeight > playableScreenHeight then
    marginY = (display.actualContentHeight - playableScreenHeight) / 2
  end
end

-- create the single tile with all the properties
local function createSingleTile(classTile, row, col, graphicGroup)
    -- xPos = col * widthFrame,
    -- yPos = i * heightFrame, (row - 1 to allign correctly on screen to 0, 0)
  xPos = col * widthFrame
  yPos = (row - 1) * heightFrame
  --myImage = display.newImage(graphicGroup, obstaclesSrc..classTile..'.png')
  myImage = display.newImage(graphicGroup, obstaclesSrc..classTile..'.jpg')
  myImage.anchorX = anchorXPoint
  myImage.anchorY = anchorYPoint
  myImage.x = xPos + marginX
  myImage.y = yPos + marginY
  myImage.row = row
  myImage.col = col
  myImage.obstacle = 1
  myImage.name = 'cell_'..row..'-'..col
  myImage.type = classTile

  -- graphicGroup:insert(myImage)

  return myImage
end

local function destroySingleTile(tile)
  display.remove(tile)
  tile = nil
end


-- Create the walking path in a graphic way (TO BE DEFINED BEFORE THE WALKING ALGORITHM)
local function openPath(rowNumber, colNumber, graphicGroup)
  -- choose the random tile and save it in the grid to remember it -------------------------- UNCOMMENT FOR MULTIPLE PATH TILES
  -- randomPath = pathTile..math.random(4)
  randomPath = pathTile..'1'
  -- remove old tile
  gridMatrix[rowNumber][colNumber]:removeSelf()
  gridMatrix[rowNumber][colNumber] = nil
  -- create the new image and save it on the grid
  cell = createSingleTile(randomPath, rowNumber, colNumber, graphicGroup)
  gridMatrix[rowNumber][colNumber] = cell
  gridMatrix[rowNumber][colNumber].obstacle = 0  -- set as path
  gridMatrix[rowNumber][colNumber].type = 'path'
end

local function randomWalking(pathGridX, pathGridY, graphicGroup)

  for count = 1, pathTracerMoves, 1 do
    -- 1 choose a random number between 1 and 4 (the 4 directions)
    randomDirection = math.random(4)
    if (randomDirection == 1 and pathGridY > 1) then -- moveUp
      pathGridY = pathGridY - 1
    elseif (randomDirection == 2 and pathGridX > 1) then -- moveLeft
      pathGridX = pathGridX - 1
    elseif (randomDirection == 3 and pathGridX < gridRows) then -- moveRIght
      pathGridX = pathGridX + 1
    elseif (randomDirection == 4 and pathGridY < gridCols) then -- moveDown
      pathGridY = pathGridY + 1
    end
    openPath(pathGridX,pathGridY, graphicGroup)
  end

end

-- function to determine if a cell is reachable, needed for transformObstaclesIntoTrees
local function checkIfReachable(r, c)
  r0 = r - 1
  r1 = r + 1
  c0 = c - 1
  c1 = c + 1
  reachable = 0

  if c1 <= gridCols and gridMatrix[r][c1].obstacle == 0 then
    reachable = reachable + 1
  end
  if r1 <= gridRows and gridMatrix[r1][c].obstacle == 0 then
    reachable = reachable + 1
  end
  if c0 > 0 and gridMatrix[r][c0].obstacle == 0 then
    reachable = reachable + 1
  end
  if r0 > 0 and gridMatrix[r0][c].obstacle == 0 then
    reachable = reachable + 1
  end
  if reachable > 0 then
    return true
  end
end

local function checkIfIsATree(cell)
  local isItATree = false

  if cell and cell.type == 'tree' then
    isItATree = true
  end

  return isItATree

  --[[ if cell == nil then   KEEEP IT JUST IN CASE IT STARTS THROWING ERRORS BUT IT SHOULD'T BE NECESSARY
    return false
  end ]]
end

local function visualizeTreePeeBar(xPos, yPos, graphicGroup)
  -- auto change of position based on general anchor point of the project
  if anchorXPoint == 1 then
    xPos = xPos - widthFrame
    yPos = yPos - heightFrame
  --[[ elseif anchorXPoint == 0.5 then
    xPos = xPos - widthFrame + 5
    yPos = yPos - 10 ]]
  end

  peeBarSheet = graphics.newImageSheet(peeBarSrc, peeBarOptions)
  peeBar = widget.newProgressView(
    {sheet = peeBarSheet,
      fillOuterLeftFrame = 1, fillOuterMiddleFrame = 2, fillOuterRightFrame = 3,
      fillOuterWidth = peeBarFrameWidth, fillOuterHeight = peeBarFrameHeight,
      fillInnerLeftFrame = 4, fillInnerMiddleFrame = 5, fillInnerRightFrame = 6,
      fillWidth = peeBarFrameWidth, fillHeight = peeBarFrameHeight,
      left = xPos, top = yPos, width = widthFrame, isAnimated = true
    }
  )

  peeBar:setProgress(0.0)
  graphicGroup:insert(peeBar)
  return peeBar
end

local function transformObstaclesIntoTrees(graphicGroup)
  while actualTrees < totalLevelTrees do
    randomCell = math.random(table.maxn(obstacleGrid))    -- choose a random cell
    -- check if it's close to path
    isReachable = checkIfReachable(obstacleGrid[randomCell].row, obstacleGrid[randomCell].col)
    alreadyChosenAsTree = checkIfIsATree(obstacleGrid[randomCell])
    if isReachable == true and alreadyChosenAsTree == false then
      actualTrees = actualTrees + 1
      -- substitute the cell with the new background
      randomTree = 'tree'..math.random(4)

      localRow = obstacleGrid[randomCell].row
      localCol = obstacleGrid[randomCell].col

      -- destroy the old cell image
      destroySingleTile(obstacleGrid[randomCell])
      obstacleGrid[randomCell] = nil
      destroySingleTile(gridMatrix[localRow][localCol])
      gridMatrix[localRow][localCol] = nil

      cell = createSingleTile(randomTree, localRow, localCol, graphicGroup)
      obstacleGrid[randomCell] = cell
      gridMatrix[localRow][localCol] = cell

      -- add the pee loading bar
      --peeBar = visualizeTreePeeBar(localCol * widthFrame, localRow * heightFrame + heightFrame / 2, actualTrees)
      peeBar = visualizeTreePeeBar(localCol * widthFrame, localRow * heightFrame + heightFrame / 2, graphicGroup)

      -- set the current cell as tree
      gridMatrix[localRow][localCol].type = 'tree'
      gridMatrix[localRow][localCol].peeLevel = 0
      gridMatrix[localRow][localCol].maxPeeLevel = maxPeeLevel
      gridMatrix[localRow][localCol].minPeeLevel = minPeeLevel
      gridMatrix[localRow][localCol].actualTrees = actualTrees --tree number
      gridMatrix[localRow][localCol].peeBar = peeBar

      physics.addBody(gridMatrix[localRow][localCol], "static")

      -- add the current tree to a tree table to decrease the peeLevel in auto function
      table.insert(treeGrid, {row = localRow, col = localCol, number = actualTrees})

    end
  end
end

--------------------------------------------------------------------------

function M.new(gridRows, gridCols, lvl, graphicGroup)

  -- init vars and grids
  initVars(lvl)

  createMarginsForPlayableScreen()
  centerHoriz = math.floor(gridRows/2)
  centerVert = math.floor(gridCols/2)

  -- Populate the grid matrix for the level
  for i = 1, gridRows do -- change to 0 and -1 to position correctly on the screen
    gridMatrix[i] = {} -- create a new row
    for j = 1, gridCols do
      tile = obstacleTile..math.random(4)
      gridMatrix[i][j] = createSingleTile(tile, i, j, graphicGroup)
    end
  end

  -- Random walking algorithm, clearing the path (start from the center)
  pathGridX = centerHoriz
  pathGridY = centerVert
  openPath(pathGridX, pathGridY, graphicGroup)      -- free the central cell
  randomWalking(pathGridX, pathGridY, graphicGroup) -- open a random path (for cycle based on n of moves)

  -- Count the ramaining obstacles, add body to them and eventually select and create random trees
  for i = 1, gridRows do
    for j = 1, gridCols do
      if (gridMatrix[i][j].obstacle == 1) then
        tile = obstacleTile..math.random(4)
        gridMatrix[i][j] = createSingleTile(tile, i, j, graphicGroup) -- all obstacles have grass background
        table.insert(obstacleGrid, gridMatrix[i][j])
        physics.addBody(gridMatrix[i][j], "static")
      end
    end
  end

  -- Transform obstacles into trees
  actualTrees = 0
  transformObstaclesIntoTrees(graphicGroup)
  --[[ while actualTrees < totalLevelTrees do
    randomCell = math.random(table.maxn(obstacleGrid))    -- choose a random cell
    -- check if it's close to path
    isReachable = checkIfReachable(obstacleGrid[randomCell].row, obstacleGrid[randomCell].col)
    alreadyChosenAsTree = checkIfIsATree(obstacleGrid[randomCell])
    if isReachable == true and alreadyChosenAsTree == false then
      actualTrees = actualTrees + 1
      -- substitute the cell with the new background
      randomTree = 'tree'..math.random(4)

      localRow = obstacleGrid[randomCell].row
      localCol = obstacleGrid[randomCell].col

      -- destroy the old cell image
      destroySingleTile(obstacleGrid[randomCell])
      obstacleGrid[randomCell] = nil
      destroySingleTile(gridMatrix[localRow][localCol])
      gridMatrix[localRow][localCol] = nil

      cell = createSingleTile(randomTree, localRow, localCol, graphicGroup)
      obstacleGrid[randomCell] = cell
      gridMatrix[localRow][localCol] = cell

      -- add the pee loading bar
      --peeBar = visualizeTreePeeBar(localCol * widthFrame, localRow * heightFrame + heightFrame / 2, actualTrees)
      peeBar = visualizeTreePeeBar(localCol * widthFrame, localRow * heightFrame + heightFrame / 2, graphicGroup)

      -- set the current cell as tree
      gridMatrix[localRow][localCol].type = 'tree'
      gridMatrix[localRow][localCol].peeLevel = 0
      gridMatrix[localRow][localCol].maxPeeLevel = maxPeeLevel
      gridMatrix[localRow][localCol].minPeeLevel = minPeeLevel
      gridMatrix[localRow][localCol].actualTrees = actualTrees --tree number
      gridMatrix[localRow][localCol].peeBar = peeBar

      physics.addBody(gridMatrix[localRow][localCol], "static")

      -- add the current tree to a tree table to decrease the peeLevel in auto function
      table.insert(treeGrid, {row = localRow, col = localCol, number = actualTrees})

    end
  end ]]

  toReturn.gridMatrix = gridMatrix
  toReturn.gridTree = treeGrid

  return toReturn
end

return M -- create M returns the instance
