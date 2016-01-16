local activeScreen     = require('ext.screen').activeScreen
local activeSpaceIndex = require('ext.spaces').activeSpaceIndex
local focusScreen      = require('ext.screen').focusScreen
local keys             = require('ext.table').keys
local screenSpaces     = require('ext.spaces').screenSpaces
local spaceFromIndex   = require('ext.spaces').spaceFromIndex
local spaceInDirection = require('ext.spaces').spaceInDirection
local spaces           = require('hs._asm.undocumented.spaces')

local module = {}
local cache  = { switching = false }

-- sends proper amount of ctrl+left/right to move you to given space, even if it's fullscreen app!
module.switchToIndex = function(targetIdx)
  -- save mouse pointer to reset after switch is done
  local mousePosition = hs.mouse.getAbsolutePosition()

  -- grab spaces for screen with active window
  local currentScreen = activeScreen()
  local screenSpaces  = screenSpaces()

  -- grab index of currently active space
  local activeIdx     = activeSpaceIndex(screenSpaces)
  local targetSpace   = spaceFromIndex(targetIdx)

  -- check if we really can send the keystrokes
  local shouldSendEvents = hs.fnutils.every({
    not cache.switching,
    targetSpace ~= nil,
    activeIdx ~= targetIdx
  }, function(test) return test end)

  if shouldSendEvents then
    cache.switching = true

    local eventCount     = math.abs(targetIdx - activeIdx)
    local eventDirection = targetIdx > activeIdx and 'right' or 'left'

    -- gain focus on the screen
    focusScreen(currentScreen)

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
  local currentScreen = activeScreen()
  local mousePosition = hs.mouse.getAbsolutePosition()
  local targetSpace   = spaceInDirection(direction)

  cache.switching = true

  local changedFocus = focusScreen(currentScreen)

  if changedFocus then
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
  else
    cache.switching = false
  end
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
      module.switchInDirection(keyCode == 123 and 'west' or 'east')
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
