local cache = {
  offline = nil
}

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

-- ask for headers only - minimum network usage
local asyncRequest = function()
  hs.http.doAsyncRequest('http://google.com', 'HEAD', nil, nil, function(responseCode)
    notifyOnOffline(responseCode < 0)
  end)
end

-- experimental version with ping, doesn't work that well
local taskPing = function()
  if cache.task then return end

  cache.task = hs.task.new('/sbin/ping', function(exitCode)
    notifyOnOffline(exitCode ~= 0)
    cache.task = nil
  end, { '-q', '-c2', '8.8.8.8' }):start()
end

-- check if online every second
return hs.timer.doEvery(1, asyncRequest)
