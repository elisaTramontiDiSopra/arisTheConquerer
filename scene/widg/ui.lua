local M = {}
local constants = require("scene.const.constants")

local ply
local buttonPressed = {Down = false, Up = false, Left = false, Right = false}

------------------------------------- EXTRA FUNCTIONS
local function move(event)
  -- set walking animation
  if (event.phase == "began") then
    buttonPressed[event.target.name] = true
    walkAnimation = "walking" .. event.target.name
    ply:setSequence(walkAnimation)
    ply:play()
  elseif (event.phase == "ended") then
    buttonPressed[event.target.name] = false
    ply:pause()
  end
end

function checkIfIsATree(cell)
    if cell == nil then return false end
    if cell and cell.type == 'tree' or cell.type == 'tree1' or cell.type ==
        'tree2' or cell.type == 'tree3' or cell.type == 'tree4' then
        return true
    else
        return false
    end
end

-------------------------------------

function M.new(gridMatrix, player, lvl)

  -- init vars
  playerSequenceData = constants.playerSequenceData
  playerSheetOptions = constants.playerSheetOptions
  timerBarSrc = constants.timerBarSrc
  fillOuterWidth = constants.fillOuterWidth
  timerBarOptions = constants.timerBarOptions
  timerSeconds = constants.levelVars[lvl].timerSeconds     -- seconds to decrease
  totalTimerSeconds = constants.levelVars[lvl].timerSeconds -- to compute the perc for the timer bar

  local instance = display.newGroup()
  ply = player

    -- init vars
    padButtonDimension = constants.padButtonDimension

    upBtn = display.newRect(display.contentWidth - 2 * padButtonDimension,
                            display.contentHeight - 3 * padButtonDimension,
                            padButtonDimension, padButtonDimension)
    upBtn:setFillColor(0, 0, 0)
    upBtn.name = "Up"
    instance:insert(upBtn)
    upBtn:addEventListener("touch", move)

    downBtn = display.newRect(display.contentWidth - 2 * padButtonDimension,
                              display.contentHeight - padButtonDimension,
                              padButtonDimension, padButtonDimension)
    downBtn.name = "Down"
    downBtn:setFillColor(0, 0, 0)
    instance:insert(downBtn)
    downBtn:addEventListener("touch", move)

    leftBtn = display.newRect(display.contentWidth - 3 * padButtonDimension,
                              display.contentHeight - 2 * padButtonDimension,
                              padButtonDimension, padButtonDimension)
    leftBtn.name = "Left"
    leftBtn:setFillColor(0, 0, 0)
    instance:insert(leftBtn)
    leftBtn:addEventListener("touch", move)

    rightBtn = display.newRect(display.contentWidth - padButtonDimension,
                               display.contentHeight - 2 * padButtonDimension,
                               padButtonDimension, padButtonDimension)
    rightBtn.name = "Right"
    rightBtn:setFillColor(0, 0, 0)
    instance:insert(rightBtn)
    rightBtn:addEventListener("touch", move)

    -- peeBtn = display.newRect(playableScreenWidth/2 + padButtonDimension/2, playableScreenHeight - padButtonDimension, padButtonDimension, padButtonDimension)
    peeBtn = display.newCircle(display.contentWidth / 2,
                               display.contentHeight / 2, padButtonDimension,
                               padButtonDimension / 1.5)
    peeBtn:setFillColor(0)
    peeBtn.alpha = 0.3
    peeBtn.name = "Pee"
    peeBtn:addEventListener("touch", pee)

    return ui
end

return M -- create M returns the instance
