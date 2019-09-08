local M = {}
local widget = require "widget"
local constants = require("scene.const.constants")

-- TIMER VARS
local timerBar
local timerSeconds
local test

------------------------------------- EXTRA FUNCTIONS
--[[ function updateTime()
  minutes = math.floor( timerSeconds / 60 )
  seconds = timerSeconds % 60
  timerDisplay = string.format( "%02d:%02d", minutes, seconds )
  timerText.text = timerDisplay

  timerPerc = timerSeconds / totalTimerSeconds
  print(timerSeconds)
  print(totalTimerSeconds)
  print(timerPerc)
  timerBar:setProgress(timerPerc)
  timerSeconds = timerSeconds - 1
  test = test - 1
  print (test)
end ]]
-------------------------------------

function M.new(playableScreenWidth, lvl)

  -- init vars
  timerBarFrameWidth = constants.timerBarFrameWidth
  timerBarFrameHeight = constants.timerBarFrameHeight
  timerBarSrc = constants.timerBarSrc
  fillOuterWidth = constants.fillOuterWidth
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
  timerBar:setProgress(1.0)
  --gameLoopTimer = timer.performWithDelay(1000, updateTime(), 15)

  return timerText

end

function M.update()
  timerSeconds = timerSeconds - 1
  minutes = math.floor( timerSeconds / 60 )
  seconds = timerSeconds % 60
  timerDisplay = string.format( "%02d:%02d", minutes, seconds )
  timerText.text = timerDisplay

  timerPerc = timerSeconds / totalTimerSeconds
  timerBar:setProgress(timerPerc)
  print(totalTimerSeconds)

  print(timerSeconds)
  print(timerPerc)
end

return M -- create M returns the instance
