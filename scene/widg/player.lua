local M = {}
local physics = require "physics"
local constants = require("scene.const.constants")
local composer = require( "composer" )

-- PLAYER VARS
local player, playerCol, playerRow
local collidedWith = {}
local lastDirection = ""

function printPairs(grid)
  for k,v in pairs(grid) do
    print( k,v )
  end
end

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

local function findPlayerRowCol()
  playerRow = math.ceil((player.y) / widthFrame)
  playerCol = math.ceil((player.x) / widthFrame)
  -- consider if the anchor point is at the end of the picture cause it could change the colliding point
  --[[ if anchorXPoint == 1 then
    playerRow = math.ceil((player.y - widthFrame + 10) / widthFrame)
    playerCol = math.ceil((player.x - widthFrame + 10) / widthFrame)
  end ]]
end

local function checkIfPlayerIsClose(tree)
  findPlayerRowCol()

  -- if it hit the enemy exit otherwise it might throw an
  if tree.name == 'enemy' then return end

  local diffRow = math.abs(playerRow - tree.row)
  local diffCol = math.abs(playerCol - tree.col)
  -- if it's close then return true
  if diffRow < 2 and diffCol < 2 then
    return true
  else
    return false
  end
end

local function playerCollision(self, event)
  --print("collision")
  local nexToObject = false
  if (event.phase == "began" ) then

    -- if you hit the enemy dog lose the game and go to the appropriate scene
    if (event.phase == "began" ) then
      if event.other.name == 'enemy' then
        composer.setVariable('winOrLose', 'lose' )
        composer.gotoScene("scene.brawl", "fade", 500 )
      end
    end

    -- check if we're close to the tree, less then 1 row and 1 col away
    nexToObject = checkIfPlayerIsClose(event.other)

    if nexToObject == true and event.other.type == 'tree' then
      collidedWith = event.other
    elseif nexToObject == true and event.other.type == 'char' then
      -- dog collided with other dog
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
  playerSrc = imageSrc
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
  local imageSheet = graphics.newImageSheet(playerSrc, playerSheetOptions)
  player = display.newSprite(imageSheet, playerSequenceData)
  player.anchorX = anchorXPoint
  player.anchorY = anchorYPoint
  player.x = centerVert * heightFrame + marginX
  player.y = centerHoriz * widthFrame + marginY
  player.name = 'player'
  player:setSequence("walkingDown")
  player.objectType = player

  -- Handle player collision
  player.collision = playerCollision
  player:addEventListener("collision", player)
  physics.addBody(player, "dynamic", playerBodyOptions)

  sceneGroup:insert(player)

  function player:animate(animation)
    player:setSequence(animation)
    player.rotation = 0 -- to prevent player from rotating if walking on an obstacle angle
    lastDirection = animation:sub(8) -- take what's after 'walking'
  end

  function player:pee()
    -- if there is no collidedWith Object exit because you're not close to a tree
    if (collidedWith.peeLevel and collidedWith.peeLevel < maxPeeLevel) then
      collidedWith.peeLevel = collidedWith.peeLevel + peeStream
      peeAnimation = 'pee'..lastDirection
      player:setSequence(peeAnimation)
      updateTreePeeBar(collidedWith.peeBar, collidedWith.peeLevel)
      return collidedWith
    end
  end

  return player
end

return M -- create M returns the instance
