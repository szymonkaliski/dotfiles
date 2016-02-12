local module = {}
local cache  = {}

local notify        = require('utils.controlplane.notify')
local onlineWatcher = require('ext.onlinewatcher')

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

  if (currentNetwork ~= cache.network or not cache.network) and currentNetwork == controlplane.homeNetwork then
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
