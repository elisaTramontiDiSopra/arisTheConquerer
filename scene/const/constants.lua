local M = {
  -- options
  musicOn = false,
  arrowPadOn = true, -- initially padOn
  -- buttons
  padOn = 'pad.png',
  padOff = 'padOff.png',
  accelerometerOn = 'accelerometer.png',
  accelerometerOff = 'accelerometerOff.png',
  save = 'save.png',
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
  playerSpeed = 2,
  playerSrc = "scene/img/mainDog.png",
  playerSheetOptions = {width = 50, height = 50, numFrames = 32}, -- use widthFrame & heightFrame
  playerBodyOptions = {radius = 20}, -- to add a physics body, use circle or it wouldn't be realistic
  --playerSrc = "scene/img/mainDog_64.png",                         -- 64PX VERSION
  --playerSheetOptions = {width = 64, height = 64, numFrames = 32}, -- 64PX VERSION
  --playerBodyOptions = {radius = 30},                              -- 64PX VERSION
  playerSequenceData = {
    {name = "walkingDown", start = 1, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "walkingLeft", start = 5, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "walkingRight", start = 9, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "walkingUp", start = 13, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeDown", start = 17, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeLeft", start = 21, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeRight", start = 25, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeUp", start = 29, count = 4, time = 100, loopCount = 0, loopDirection = "forward"}
  },
  -- meanDog vars
  enemyDogSrc = "scene/img/mainDogMean.png",
  --enemyDogSrc = "scene/img/mainDogMean_64.png",                   -- 64PX VERSION
  enemySheetOptions = {width = 50, height = 50, numFrames = 36}, -- use widthFrame & heightFrame
  enemySequenceData = {
    {name = "walkingDown", start = 1, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "walkingLeft", start = 5, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "walkingRight", start = 9, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "walkingUp", start = 13, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeDown", start = 17, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeLeft", start = 21, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeRight", start = 25, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "peeUp", start = 29, count = 4, time = 100, loopCount = 0, loopDirection = "forward"},
    {name = "puff", start = 33, count = 4, time = 100, loopCount = 0, loopDirection = "forward"} -- THIS IS ADDED
  },
  -- level vars
  numberOfLevels = 20,
  levelVars = {
    { lvl = 1, timerSeconds = 20, pathTracerMoves = 200,
      obstaclesSrc = "scene/img/tiles/country/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 1, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 2,
      enemyPeeVelocity = 300, enemyPeeTrees = 1, visualizeEnemy = true, enemyTransitionTime = 500
    },
    { lvl = 2, timerSeconds = 20, pathTracerMoves = 100,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 2, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 2,
      enemyPeeVelocity = 300, enemyPeeTrees = 1,  visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 3, timerSeconds = 20, pathTracerMoves = 100,
      obstaclesSrc = "scene/img/tiles/pole/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 3, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 2,
      enemyPeeVelocity = 300, enemyPeeTrees = 1,  visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 4, timerSeconds = 20, pathTracerMoves = 100,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 3, minPeeLevel = 10, maxPeeLevel = 100, peeStream = 6, vanishingPee = 2,
      enemyPeeVelocity = 300, enemyPeeTrees = 1,  visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 5, timerSeconds = 20, pathTracerMoves = 200,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 4, minPeeLevel = 10, maxPeeLevel = 100, peeStream = 6, vanishingPee = 2,
      enemyPeeVelocity = 300, enemyPeeTrees = 1,  visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 6, timerSeconds = 20, pathTracerMoves = 100,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 4, minPeeLevel = 10, maxPeeLevel = 100, peeStream = 6, vanishingPee = 4,
      visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 7, timerSeconds = 30, pathTracerMoves = 100,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 4, minPeeLevel = 10, maxPeeLevel = 100, peeStream = 6, vanishingPee = 4,
      visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 8, timerSeconds = 30, pathTracerMoves = 100,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 4, minPeeLevel = 10, maxPeeLevel = 100, peeStream = 6, vanishingPee = 4,
      visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 9, timerSeconds = 20, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/desert/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 4, minPeeLevel = 10, maxPeeLevel = 100, peeStream = 6, vanishingPee = 4,
      visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 10, timerSeconds = 30, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/desert/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 4, minPeeLevel = 10, maxPeeLevel = 100, peeStream = 6, vanishingPee = 4,
      visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 11, timerSeconds = 30, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/desert/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 5, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 4,
      visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 12, timerSeconds = 20, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/desert/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 4, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 4,
      visualizeEnemy = false, enemyTransitionTime = 500
    },
    { lvl = 13, timerSeconds = 30, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/pole/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 4, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 4
    },
    { lvl = 14, timerSeconds = 30, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/pole/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 5, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 6
    },
    { lvl = 15, timerSeconds = 20, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/pole/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 4, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 6
    },
    { lvl = 16, timerSeconds = 30, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/pole/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 4, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 6
    },
    { lvl = 17, timerSeconds = 30, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 5, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 6
    },
    { lvl = 18, timerSeconds = 30, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 5, minPeeLevel = 5, maxPeeLevel = 100, peeStream = 6, vanishingPee = 6
    },
    { lvl = 19, timerSeconds = 50, pathTracerMoves = 300,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 8, minPeeLevel = 20, maxPeeLevel = 100, peeStream = 6, vanishingPee = 6
    },
    { lvl = 20, timerSeconds = 50, pathTracerMoves = 90,
      obstaclesSrc = "scene/img/tiles/isle/", obstacleTile = 'obstacle', treeTile = 'tree', pathTile = 'path',
      totalLevelTrees = 8, minPeeLevel = 20, maxPeeLevel = 100, peeStream = 6, vanishingPee = 6
    }
  }
}

return M
