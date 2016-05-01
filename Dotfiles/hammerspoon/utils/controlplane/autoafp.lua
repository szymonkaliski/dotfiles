local cache  = {}
local module = { cache = cache }

local notify = require('utils.controlplane.notify')

local isAFPConnected = function(name)
  local _, res = hs.applescript.applescript([[
    tell application "Finder"
      if exists disk "]] .. name .. [[" then
        return 1
      else
        return 0
      end if
    end tell
  ]])

  return res == 1
end

local connectAFPVolume = function(volume)
  hs.applescript.applescript([[
    tell application "Finder"
      try
        mount volume "]] .. volume .. [["
      end try
    end tell
  ]])
end

local connectAFPVolumes = function()
  hs.fnutils.each(controlplane.afpVolumes, connectAFPVolume)
  notify('Mounting AFP volumes')
end

local wifiWatcher = function()
  local currentNetwork = hs.wifi.currentNetwork()

  if (currentNetwork ~= cache.network or not cache.network) and currentNetwork == controlplane.homeNetwork and not isAFPConnected('szymon\'s home') then
    connectAFPVolumes()
  end

  cache.network = currentNetwork
end

module.start = function()
  cache.wifiWatcher = hs.wifi.watcher.new(wifiWatcher):start()
  wifiWatcher()
end

module.stop = function()
  cache.wifiWatcher:stop()
end

return module
