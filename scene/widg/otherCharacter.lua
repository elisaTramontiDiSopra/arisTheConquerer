local M = {}
local physics = require "physics"
local constants = require("scene.const.constants")

-- PLAYER VARS
local player, playerCol, playerRow
local collidedWith = {}
local lastDirection = ""

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

-------------------------------------

function M.new(gridRows, gridCols, lvl, sceneGroup, imageSrc)

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
  centerHoriz = math.floor(gridRows/2)
  centerVert = math.floor(gridCols/2)

  -- Create the player
  local imageSheet = graphics.newImageSheet(charSrc, playerSheetOptions)
  char = display.newSprite(imageSheet, playerSequenceData)
  char.anchorX = anchorXPoint
  char.anchorY = anchorYPoint
  char.x = centerVert * heightFrame + marginX
  char.y = centerHoriz * widthFrame + marginY
  char.name = 'char'
  char:setSequence("walkingDown")
  char.objectType = char

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

  return char
end

return M -- create M returns the instance
