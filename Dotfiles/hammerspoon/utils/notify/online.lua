local cache  = {}
local module = { cache = cache }

local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/airport.png'

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
  cache.onlineHandle = hs.network.reachability.internet():setCallback(function(_, status)
    notifyOnOffline(status == 0)
  end):start()
end

module.stop = function()
  cache.onlineHandle:stop()
end

return module
