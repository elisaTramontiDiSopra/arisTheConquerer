local M = {
  -- menu screen vars
  logoWidth = 280,
  logoHeight = 85,
  buttonSrc = "scene/img/play.png",
  buttonWidth = 176,
  buttonHeight = 57,
  -- timer vars
  timerBarFrameWidth = 20,
  timerBarFrameHeight = 25,
  timerBarSrc = "scene/img/timerBarMini.png",
  fillOuterWidth = 20, -- Set this to horizontally offset the fill region of the progress view. Default is 0
  timerBarOptions = {width = 64, height = 38, numFrames = 6, sheetContentWidth = 384, sheetContentHeight = 38},
  -- peeBar vars
  --[[ peeBarFrameWidth = 10,
  peeBarFrameHeight = 10,
  peeBarSrc = "scene/img/peeBar.png",
  peeBarOptions = {width = 10, height = 10, numFrames = 6, sheetContentWidth = 60, sheetContentHeight = 10}, ]]
  peeBarFrameWidth = 10,
  peeBarFrameHeight = 13,
  peeBarSrc = "scene/img/peeBarMini.png",
  fillOuterWidth = 20, -- Set this to horizontally offset the fill region of the progress view. Default is 0
  peeBarOptions = {width = 10, height = 10, numFrames = 6, sheetContentWidth = 60, sheetContentHeight = 10},
  -- ui vars
  padButtonDimension = 50,
  -- tiles vars
  widthFrame = 64,
  heightFrame = 64,
  anchorXPoint = 1,
  anchorYPoint = 1,
  obstacles = {'flower','rock','tree'},
  -- player vars
  playerSrc = "scene/img/mainDog.png",
  playerSpeed = 5,
  playerSheetOptions = {width = 50, height = 50, numFrames = 28}, -- use widthFrame & heightFrame
  playerBodyOptions = {radius = 20}, -- to add a physics body, use circle or it wouldn't be realistic
  playerSequenceData = {
    {name = "walkingDown", start = 1, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "walkingLeft", start = 5, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "walkingRight", start = 9, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "walkingUp", start = 13, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeDown", start = 17, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeRight", start = 21, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeLeft", start = 25, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeUp", start = 17, count = 4, time = 100, loopCount = 0, loopDirection = "forward"}
  },
  -- level vars
  numberOfLevels = 16,
  levelVars = {
    { lvl = 1, timerSeconds = 10, pathTracerMoves = 200,
      obstaclesSrc = "scene/img/tiles/country/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 1, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 2
    },
    { lvl = 2, timerSeconds = 10, pathTracerMoves = 100,
      obstaclesSrc = "scene/img/tiles/pole/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 1, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 2
    },
    { lvl = 3, timerSeconds = 10, pathTracerMoves = 100,
      obstaclesSrc = "scene/img/tiles/desert/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 1, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 2
    },
    { lvl = 4, timerSeconds = 10, pathTracerMoves = 100,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 1, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 2
    }
  }
}

return M
