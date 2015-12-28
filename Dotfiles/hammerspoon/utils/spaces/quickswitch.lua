local spaces = require('hs._asm.undocumented.spaces')
local keys   = require('ext.table').keys

local module = {}
local cache  = {}

-- sends proper amount of ctrl+left/right to move you to given space, even if it's fullscreen app!
module.switch = function(targetIdx)
  local activeSpace  = spaces.activeSpace()

  -- get screen by current window if it's not desktop,
  -- otherwise ask for main screen (one that's focused)
  -- this fixes oddities with fullscreen apps and multiple screens
  local activeWindow = hs.window.focusedWindow()
  local activeScreen = (activeWindow and activeWindow:role() ~= 'AXScrollArea') and activeWindow:screen() or hs.screen.mainScreen()

  local screenSpaces = spaces.layout()[activeScreen:spacesUUID()]
  local targetSpace  = screenSpaces[targetIdx]
  local activeIdx    = hs.fnutils.indexOf(screenSpaces, activeSpace) or 1

  -- check if we really can send the keystrokes
  local shouldSendEvents = hs.fnutils.every({
    targetIdx <= #screenSpaces,
    targetSpace,
    activeIdx,
    activeIdx ~= targetIdx,
    not spaces.isAnimating()
  }, function(test) return test end)

  if shouldSendEvents then
    local eventCount     = math.abs(targetIdx - activeIdx)
    local eventDirection = targetIdx > activeIdx and 'right' or 'left'

    for _ = 1, eventCount do
      hs.eventtap.keyStroke({ 'ctrl' }, eventDirection)
    end
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
      return
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
