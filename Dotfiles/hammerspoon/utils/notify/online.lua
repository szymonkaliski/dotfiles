local module = {}
local cache  = {}

local onlineWatcher = require('ext.onlinewatcher')
local imagePath     = os.getenv('HOME') .. '/.hammerspoon/assets/airport.png'

local openNetworkSettings = function()
  hs.applescript.applescript([[
    tell application "System Preferences"
      activate
      set the current pane to pane id "com.apple.preference.network"
    end tell
  ]])
end

local notifyOnOffline = function(offline)
  local subTitle = offline and 'Offline' or 'Online'

  if cache.offline ~= nil and cache.offline ~= offline then
    hs.notify.new(openNetworkSettings, {
      title        = 'Network Status',
      subTitle     = subTitle,
      contentImage = imagePath
    }):send()
  end

  cache.offline = offline
end

module.start = function()
  cache.onlineHandle = onlineWatcher.subscribe(function(isOnline)
    notifyOnOffline(not isOnline)
  end)
end

module.stop = function()
  onlineWatcher.unsubscribe(cache.onlineHandle)
end

return module
