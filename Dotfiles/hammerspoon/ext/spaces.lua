local spaces       = require('hs._asm.undocumented.spaces')
local activeScreen = require('ext.screen').activeScreen

local cache  = {}
local module = { cache = cache }

module.activeSpaceIndex = function(screenSpaces)
  return hs.fnutils.indexOf(screenSpaces, spaces.activeSpace()) or 1
end

module.screenSpaces = function(currentScreen)
  currentScreen = currentScreen or activeScreen()
  return spaces.layout()[currentScreen:spacesUUID()]
end

module.spaceFromIndex = function(index)
  local currentScreen = activeScreen()
  return module.screenSpaces(currentScreen)[index]
end

module.spaceInDirection = function(direction)
  local screenSpaces = module.screenSpaces()
  local activeIdx    = module.activeSpaceIndex(screenSpaces)
  local targetIdx    = direction == 'west' and activeIdx - 1 or activeIdx + 1

  return screenSpaces[targetIdx]
end

module.isSpaceFullscreenApp = function(spaceID)
  return spaceID ~= nil and #spaces.spaceOwners(spaceID) > 0
end

-- spaceModifier has to be a number!
module.sendToSpace = function(win, spaceModifier)
  local clickPoint = win:zoomButtonRect()
  local sleepTime  = 1000

  -- check if all conditions are ok to move the window
  local shouldMoveWindow = hs.fnutils.every({
    clickPoint ~= nil,
    not cache.movingWindowToSpace
  }, function(test) return test end)

  if not shouldMoveWindow then return end

  cache.movingWindowToSpace = true

  clickPoint.x = clickPoint.x + clickPoint.w + 5
  clickPoint.y = clickPoint.y + clickPoint.h / 2

  -- fix for Chrome UI
  if win:application():title() == 'Google Chrome' then
    clickPoint.y = clickPoint.y - clickPoint.h
  end

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()
  hs.timer.usleep(sleepTime)

  hs.eventtap.keyStroke({ 'ctrl' }, spaceModifier)

  hs.timer.usleep(sleepTime)
  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()

  -- reset cache
  cache.movingWindowToSpace = false
end

return module
