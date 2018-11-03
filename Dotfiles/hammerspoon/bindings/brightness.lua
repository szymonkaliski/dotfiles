-- FIXME: this usually works for a while, but then getBrightness() stops
-- returning updated values and screens get stuck with some brightness value

local cache  = { modules = {} }
local module = { cache = cache }

local KEYCODE_BRIGHTNESS_UP   = 113
local KEYCODE_BRIGHTNESS_DOWN = 107
local SLEEP_TIME              = 0.1

module.start = function()
  cache.eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local keyCode = event:getKeyCode()

    -- ignore anything that's not KEYCODE_BRIGHTNESS_UP or KEYCODE_BRIGHTNESS_DOWN
    if keyCode ~= KEYCODE_BRIGHTNESS_UP and keyCode ~= KEYCODE_BRIGHTNESS_DOWN then
      return false
    end

    if cache.timer then
      cache.timer:stop()
      cache.timer = nil
    end

    -- update with small timeout, so primaryScreen():getBrightness() has true value
    cache.timer = hs.timer.doAfter(SLEEP_TIME, function()
      local targetBrightness = hs.screen.primaryScreen():getBrightness()

      hs.fnutils.each(hs.screen.allScreens(), function(screen)
        screen:setBrightness(targetBrightness)
      end)

      cache.timer:stop()
      cache.timer = nil
    end)

    -- propagate the event so main screen sets the brightness
    return false
  end):start()
end

module.stop = function()
  if cache.eventtap then cache.eventtap:stop() end
end

return module
