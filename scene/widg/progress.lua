-- progress.lua handles saving and loading of highest game level
local M = {}

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
    --print( "ERROR: could not load score (score may not exist in storage)" )
  end
end


return M
