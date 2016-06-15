local cache  = {}
local module = { cache = cache }

-- laptop screen should always be primary one
local screenWatcher = function()
  local laptopDisplay = hs.screen.findByName('Color LCD')
  if laptopDisplay then laptopDisplay:setPrimary() end
end

module.start = function()
  cache.watcher = hs.screen.watcher.new(screenWatcher):start()

  -- setup on start
  screenWatcher()
end

module.stop = function()
  if cache.watcher then cache.watcher:stop() end
end

return module
