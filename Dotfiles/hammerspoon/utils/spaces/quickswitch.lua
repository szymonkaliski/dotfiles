local keys     = require('ext.table').keys
local spaces   = require('hs._asm.undocumented.spaces')
local template = require('ext.template')

local module = {}
local cache  = { switching = false }

-- sends proper amount of ctrl+left/right to move you to given space, even if it's fullscreen app!
module.switch = function(targetIdx)
  local activeSpace = spaces.activeSpace()
  local mousePoint  = hs.geometry.point(hs.mouse.getAbsolutePosition())

  -- get screen by current window if it's not desktop,
  -- otherwise ask for main screen (one that's focused)
  -- this fixes oddities with fullscreen apps and multiple screens
  local activeWindow = hs.window.focusedWindow()
  local activeScreen

  -- if we have active window, grab its screen
  -- otherwise use the screen where mouse cursor is
  if activeWindow and activeWindow:role() ~= 'AXScrollArea' then
    activeScreen = activeWindow:screen()
  else
    activeScreen = hs.fnutils.find(hs.screen.allScreens(), function(screen)
      return mousePoint:inside(screen:frame())
    end)
  end

  local screenSpaces = spaces.layout()[activeScreen:spacesUUID()]
  local targetSpace  = screenSpaces[targetIdx]
  local activeIdx    = hs.fnutils.indexOf(screenSpaces, activeSpace) or 1

  -- check if we really can send the keystrokes
  local shouldSendEvents = hs.fnutils.every({
    targetIdx <= #screenSpaces,
    targetSpace,
    activeIdx,
    activeIdx ~= targetIdx,
    not cache.switch
  }, function(test) return test end)

  if shouldSendEvents then
    cache.switching = true

    local eventCount     = math.abs(targetIdx - activeIdx)
    local eventDirection = targetIdx > activeIdx and 'right' or 'left'
    local activeFrame    = activeScreen:frame()

    -- "hide" cursor in the lower right side of screen
    -- it's invisible while we are changing spaces
    local newPosition    = {
      x = activeFrame.x + activeFrame.w - 1,
      y = activeFrame.y + activeFrame.h - 1
    }

    -- hs.mouse.setAbsolutePosition doesn't work for gaining proper screen focus (so ctrl + left/right works on that screen)
    -- moving the mouse pointer with cliclick (available on homebrew) works
    os.execute(template([[ /usr/local/bin/cliclick m:={X},{Y} ]], { X = newPosition.x, Y = newPosition.y }))
    hs.timer.usleep(1000)

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
        hs.mouse.setAbsolutePosition(mousePoint)
        cache.switching = false
      end,
      0.01 -- check every 1/100 of second
    )
  end
end

-- taps to ctrl + 1-9 overriding default functionality
module.start = function()
  cache.eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local key       = event:getCharacters()
    local modifiers = event:getFlags()
    local targetIdx = tonumber(key)

    -- break if it's not ctrl-1/0 (and propagate the event!)
    if not targetIdx or not (#keys(modifiers) == 1 and modifiers.ctrl) then
      return false
    end

    module.switch(targetIdx)

    -- stop propagation
    return true
  end):start()
end

module.stop = function()
  if cache.eventtap then cache.eventtap:stop() end
end

return module
