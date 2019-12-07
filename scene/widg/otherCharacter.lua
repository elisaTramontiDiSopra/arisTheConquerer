local M = {}
local physics = require "physics"
local constants = require("scene.const.constants")
-- pathfinder
local Grid = require ("jumper.grid")
local Pathfinder = require ("jumper.pathfinder")
local serpent = require("libs.serpent")

local function moveBasedOnPath(path)
  for node, count in path:nodes() do
    print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
    -- move following the steps
    transition.to(char, { time=500, x=node:getX()*widthFrame, y = node:getY()*heightFrame, onComplete=listener2 } )
  end
end

-- PLAYER VARS
local player, playerCol, playerRow, collidedWith
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

function printPairs(grid)
  for k,v in pairs(grid) do
    print( k,v )
  end
end


-------------------------------------

function M.new(gridRows, gridCols, charRow, charCol, lvl, sceneGroup, imageSrc, pathFinderGrid, treeGrid, gridMatrix)

  -- init vars
  widthFrame = constants.widthFrame
  anchorXPoint = constants.anchorXPoint
  anchorYPoint = constants.anchorYPoint
  charSrc = imageSrc
  playerSpeed = constants.playerSpeed
  playerSequenceData = constants.enemySequenceData
  playerSheetOptions = constants.enemySheetOptions
  playerBodyOptions = constants.playerBodyOptions
  peeStream = constants.levelVars[lvl].peeStream
  vanishingPee = constants.levelVars[lvl].vanishingPee

  createMarginsForPlayableScreen()

  -- Create the player
  local imageSheet = graphics.newImageSheet(charSrc, playerSheetOptions)
  char = display.newSprite(imageSheet, playerSequenceData)
  char.anchorX = anchorXPoint
  char.anchorY = anchorYPoint
  char.x = charCol * widthFrame + marginX -- -1 is for the anchorPoin 1
  char.y = (charRow - 1 )* heightFrame + marginY
  char.name = 'enemy'
  char:setSequence("walkingDown")
  char.objectType = char   -- is itusefeul??? can I delete it???
  char.type = 'enemy'

  physics.addBody(char, "dynamic", playerBodyOptions)

  sceneGroup:insert(char)

  function char:animate(animation)
    print(animation)
    char:setSequence(animation)
    char:play()
    char.rotation = 0 -- to prevent player from rotating if walking on an obstacle angle
  end

  local pee
  function char:pee(obj)
    -- decrease pee level till it gets to 0
    collidedWith = obj
    if obj.peeLevel > 0 then
      obj.peeLevel = obj.peeLevel - peeStream
      peeAnimation = 'peeLeft' -- shortcut, pee animation is always the same
      char:setSequence(peeAnimation)
      updateTreePeeBar(obj.peeBar, obj.peeLevel)
      local c = timer.performWithDelay( 300, pee, 1)
    end
    -- when it's done return something
    return true
  end

  function pee() -- to be used for other functions such as delay
    char:pee(collidedWith)
  end

  function char:move(path)
    --printPairs(path)
  end

  return char
end

return M -- create M returns the instance
