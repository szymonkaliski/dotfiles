local module = {}
local keys   = require('ext.table').keys

module.shouldProcessEvent = function(event)
  local focusedWindow = hs.window.focusedWindow()

  if not focusedWindow then return false end

  local isFullscreen  = focusedWindow:isFullscreen()
  local isEscape      = event:getKeyCode() == 53
  local noFlags       = #keys(event:getFlags()) == 0

  return isEscape and isFullscreen and noFlags
end

-- ignore Escape in specific apps - un-fullscreens some of them, and we don't want that
-- NOTE: this breaks a lot of things, so I don't use it
module.processEvent = function(event)
  local blockedApps    = { 'Safari', 'Calendar' }
  local focusedApp     = hs.window.focusedWindow():application()
  local focusedAppName = focusedApp:name()

  local matchesApp = hs.fnutils.some(blockedApps, function(appName)
    return appName == focusedAppName
  end)

  if not matchesApp then return false end

  return true
end

return module;
