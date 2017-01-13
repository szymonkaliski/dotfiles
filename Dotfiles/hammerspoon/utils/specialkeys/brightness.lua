local module        = {}
local brightnessMod = 5

-- override brightness buttons so they set the same brightness for multiple displays at once
-- tested only on ergodox with custom QMK config
-- this doesn't work with apple wirless keyboard last time I checked

local KEYCODE_BRIGHTNESS_UP   = 113
local KEYCODE_BRIGHTNESS_DOWN = 107

module.shouldProcessEvent = function(event)
  local keyCode = event:getKeyCode()

  return keyCode == KEYCODE_BRIGHTNESS_UP or keyCode == KEYCODE_BRIGHTNESS_DOWN
end

module.processEvent = function(event)
  local keyCode = event:getKeyCode()

  if keyCode == KEYCODE_BRIGHTNESS_UP then
    hs.brightness.set(math.min(100, hs.brightness.get() + brightnessMod))
  end

  if keyCode == KEYCODE_BRIGHTNESS_DOWN then
    hs.brightness.set(math.max(0, hs.brightness.get() - brightnessMod))
  end

  -- stop propagation
  return true
end

return module
