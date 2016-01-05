local focusScreen = require('ext.screen').focusScreen
local keys        = require('ext.table').keys
local spaces      = require('hs._asm.undocumented.spaces')

local module = {}
local cache  = { switching = false }

-- grabs screen with active window, unless it's Finder's desktop
-- then we use mouse position
local getActiveScreen = function()
  local mousePoint   = hs.geometry.point(hs.mouse.getAbsolutePosition())
  local activeWindow = hs.window.focusedWindow()

  if activeWindow and activeWindow:role() ~= 'AXScrollArea' then
    return activeWindow:screen()
  else
    return hs.fnutils.find(hs.screen.allScreens(), function(screen)
      return mousePoint:inside(screen:frame())
    end)
  end
end

-- sends proper amount of ctrl+left/right to move you to given space, even if it's fullscreen app!
module.switchToIndex = function(targetIdx)
  -- save mouse pointer to reset after switch is done
  local mousePosition = hs.mouse.getAbsolutePosition()

  -- grab spaces for screen with active window
  local activeScreen  = getActiveScreen()
  local screenSpaces  = spaces.layout()[activeScreen:spacesUUID()]

  -- grab index of currently active space
  local activeIdx     = hs.fnutils.indexOf(screenSpaces, spaces.activeSpace()) or 1
  local targetSpace   = screenSpaces[targetIdx]

  -- check if we really can send the keystrokes
  local shouldSendEvents = hs.fnutils.every({
    targetIdx <= #screenSpaces,
    targetSpace,
    activeIdx,
    activeIdx ~= targetIdx,
    not cache.switching
  }, function(test) return test end)

  if shouldSendEvents then
    cache.switching = true

    local eventCount     = math.abs(targetIdx - activeIdx)
    local eventDirection = targetIdx > activeIdx and 'right' or 'left'

    -- gain focus on the screen
    focusScreen(activeScreen)

    for _ = 1, eventCount do
      hs.eventtap.keyStroke({ 'ctrl' }, eventDirection)
    end

    -- wait for switching to end (spaces.isAnimating() doesn't work)
    -- and move cursor back to original position
    hs.timer.waitUntil(
      function()
        return spaces.activeSpace() == targetSpace
      end,
      function()
        hs.mouse.setAbsolutePosition(mousePosition)
        cache.switching = false
      end,
      0.01 -- check every 1/100 of second
    )
  end
end

module.switchInDirection = function(direction)
  local mousePosition = hs.mouse.getAbsolutePosition()
  local activeScreen  = getActiveScreen()
  local screenSpaces  = spaces.layout()[activeScreen:spacesUUID()]
  local activeIdx     = hs.fnutils.indexOf(screenSpaces, spaces.activeSpace()) or 1
  local targetIdx

  if direction == 'left' then
    targetIdx = math.max(1, activeIdx - 1)
  else
    targetIdx = math.min(#screenSpaces, activeIdx + 1)
  end

  local targetSpace = screenSpaces[targetIdx]

  cache.switching = true

  focusScreen(activeScreen)

  hs.timer.waitUntil(
    function()
      return spaces.activeSpace() == targetSpace
    end,
    function()
      hs.mouse.setAbsolutePosition(mousePosition)
      cache.switching = false
    end,
    0.01 -- check every 1/100 of second
  )
end

-- taps to ctrl + 1-9 overriding default functionality
module.start = function()
  cache.eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local keyCode   = event:getKeyCode()
    local modifiers = event:getFlags()
    local isCtrl    = #keys(modifiers) == 1 and modifiers.ctrl
    local isCtrlFn  = #keys(modifiers) == 2 and modifiers.ctrl and modifiers.fn
    local targetIdx = tonumber(event:getCharacters())

    -- switch to index if it's ctrl + 0-9
    if isCtrl and targetIdx then
      module.switchToIndex(targetIdx)
      return true
    end

    -- switch left/right if it's ctrl + left(123)/right(124)
    if isCtrlFn and (keyCode == 123 or keyCode == 124) then
      module.switchInDirection(keyCode == 123 and 'left' or 'right')
      return false
    end

    -- propagate everything else back to the system
    return false
  end):start()
end

module.stop = function()
  if cache.eventtap then cache.eventtap:stop() end
end

return module
