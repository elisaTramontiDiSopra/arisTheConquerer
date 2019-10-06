local M = {}
local physics = require "physics"
local constants = require("scene.const.constants")

-- PLAYER VARS
local player
--local peeing = false
local collidedWith = {}
local lastDirection = ""

------------------------------------- EXTRA FUNCTIONS
local function createMarginsForPlayableScreen()
   print("1 ")
    print("1 "..display.actualContentWidth)
    print("2 "..playableScreenWidth)
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

local function playerCollision(self, event)
  -- print("collision")
  if (event.phase == "began" ) then
    if event.other.type == 'tree' then
      collidedWith = event.other
    else
      -- NOTHING BECAUSE IT'S NOT A TREE
      -- collidedWith.type = event.other.type
    end
  end
  return true --limit event propagation
end

-------------------------------------

function M.new(gridRows, gridCols, lvl, sceneGroup)

  -- init vars
  anchorXPoint = constants.anchorXPoint
  anchorYPoint = constants.anchorYPoint
  playerSrc = constants.playerSrc
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
    --player.play()
    player.rotation = 0 -- to prevent player from rotating if walking on an obstacle angle
    --[[ if animation == 'walkingDown' and player.y < (gridRows * heightFrame) - heightFrame/2 then
      player.y = player.y + playerSpeed
      lastDirection = 'Down'
    elseif animation == 'walkingUp' and player.y > (0 + heightFrame) then
      player.y = player.y - playerSpeed
      lastDirection = 'Up'
    elseif animation == 'walkingRight' and player.x < (gridCols * widthFrame) then
      player.x = player.x + playerSpeed
      lastDirection = 'Right'
    elseif animation == 'walkingLeft' and player.x > (0 + widthFrame) then
      player.x = player.x - playerSpeed
      lastDirection = 'Left'
    end ]]
  end

  function player:pee()
    -- if there is no collidedWith Object exit because you're not close to a tree
    if (collidedWith.peeLevel) then
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
