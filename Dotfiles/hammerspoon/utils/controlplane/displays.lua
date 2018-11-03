local cache  = {}
local module = { cache = cache }
local log    = hs.logger.new('control:displays', 'debug');

-- laptop screen should always be primary one
local screenWatcher = function(_, _, _, wasLaptopScreenConnected, isLaptopScreenConnected)
  if not wasLaptopScreenConnected and isLaptopScreenConnected then
    log.d('setting laptop screen as primary')
    hs.screen.findByName('Color LCD'):setPrimary()
  end
end

module.start = function()
  cache.watcher = hs.watchable.watch('status.isLaptopScreenConnected', screenWatcher)
end

module.stop = function()
  cache.watcher:release()
end

return module
