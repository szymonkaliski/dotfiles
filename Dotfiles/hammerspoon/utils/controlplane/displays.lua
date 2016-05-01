local cache  = {}
local module = { cache = cache }

-- set Thunderbolt Display as primary when available
local screenWatcher = function()
  local thunderboltDisplay = hs.screen.findByName('Thunderbolt Display')
  local laptopDisplay      = hs.screen.findByName('Color LCD')

  if thunderboltDisplay then
    thunderboltDisplay:setPrimary()
  elseif laptopDisplay then
    laptopDisplay:setPrimary()
  end
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
