-- progress.lua handles saving and loading of highest game level, some "fake" global variables that are not _G
local M = {}

-- function to save and load progress
function M.save(lvl)
  -- get the load level and the current played level
  highestSavedLevel = M.load()
  -- save only if the level you reached is new, otherwise you were re-playing an old level and do nothing
  if lvl > highestSavedLevel then
    local saved = system.setPreferences( "app", { currentLevel = lvl } ) -- save in local storage under currentLevel
    if ( saved == false ) then
      print( "ERROR: could not save score" )
    end
  end
end

function reset()
  lvl = 1
  M.save(lvl)
end

function M.load()
  local lvl = system.getPreference( "app", "currentLevel", "number" )
  if ( lvl ) then
    return tonumber( lvl )
  else
    -- if there is no score is the first load and return lvl = 1
    return 1
  end
end

-- fake global vars to help passing data between modules in case of player collision
local playerCollidedWithEnemy = false


return M
