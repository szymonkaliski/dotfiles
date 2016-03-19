local module        = {}
local brightnessMod = 5

module.shouldProcessEvent = function(event)
  local systemKey = event:systemKey()

  if not next(systemKey) then return false end

  return hs.fnutils.some({ 'BRIGHTNESS_UP', 'BRIGHTNESS_DOWN' }, function(key)
    return key == systemKey.key
  end)
end

-- NOTE: this doesn't work with apple wirless keyboard
module.processEvent = function(event)
  local systemKey = event:systemKey()

  -- ignore keyup
  if not systemKey.down then return true end

  if systemKey.key == 'BRIGHTNESS_UP' then
    hs.brightness.set(math.min(100, hs.brightness.get() + brightnessMod))
  end

  if systemKey.key == 'BRIGHTNESS_DOWN' then
    hs.brightness.set(math.max(0, hs.brightness.get() - brightnessMod))
  end

  -- stop propagation
  return true
end

return module
