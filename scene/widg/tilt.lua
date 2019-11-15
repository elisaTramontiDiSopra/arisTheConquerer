-- tilt.lua handles accelerometer
local M = {}

centerX = display.contentCenterX
centerY = display.contentCenterY

function M.tilt(obj, event)
  obj.x = centerX + (centerX * event.xGravity * 1.8)  --
  obj.y = centerY + (centerY * event.yGravity * -2.5) -- y faster than x, to make the inclination less severe

  -- contain within screen
  if obj.x > display.contentWidth then
    obj.x = display.contentWidth
  end
  if obj.x < 0 then
    obj.x = 0
  end
  if obj.y > display.contentHeight then
    obj.y = display.contentHeight
  end
  if obj.y < 0 then
    obj.y = 0
  end
end

return M
