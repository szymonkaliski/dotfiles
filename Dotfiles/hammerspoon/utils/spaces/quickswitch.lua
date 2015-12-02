local spaces = require('hs._asm.undocumented.spaces')
local keys   = require('ext.table').keys

local module = {}
local cache  = {}

-- sends proper amount of ctrl+left/right to move you to given space, even if it's fullscreen app!
module.start = function()
  cache.eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local key       = event:getCharacters()
    local modifiers = event:getFlags()
    local targetIdx = tonumber(key)

    -- break if it's not ctrl-1/0 (and propagate the event!)
    if not targetIdx or not (#keys(modifiers) == 1 and modifiers.ctrl) then
      return
    end

    local activeSpace  = spaces.activeSpace()
    local screenSpaces = spaces.layout()[hs.screen.mainScreen():spacesUUID()]
    local targetSpace  = screenSpaces[targetIdx]
    local activeIdx    = hs.fnutils.indexOf(screenSpaces, activeSpace)

    -- check if we really can send the keystrokes
    local shouldSendEvents = hs.fnutils.every({
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

    -- stop propagation
    return true
  end):start()
end

module.stop = function()
  if cache.eventtap then cache.eventtap:stop() end
end

return module
