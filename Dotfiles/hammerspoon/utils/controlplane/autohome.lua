local homebridge = require('ext.homebridge')
local log        = hs.logger.new('autohome', 'debug')

local cache      = {}
local module     = { cache = cache }

local sleepWatcher = function(_, _, _, _, event)
  local isTurningOff = event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.systemWillPowerOff
  local isAtHome     = hs.wifi.currentNetwork() == config.network.home

  if isTurningOff and isAtHome and not hs.itunes.isPlaying() then
    homebridge.set(config.homebridge.studioSpeakers, 0)
  end
end

module.start = function()
  cache.watcherSleep = hs.watchable.watch('status.sleepEvent', sleepWatcher)
end

module.stop = function()
  -- cache.watcherSleep:release()
end

return module
