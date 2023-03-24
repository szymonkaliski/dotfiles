local cache  = {}
local module = { cache = cache }

module.start = function()
  -- set hs console theme when os theme changes
  cache.watcher = hs.watchable.watch('status.theme', function(_, _, _, _, theme)
    hs.console.darkMode(theme == 'dark')
  end)
end

module.stop = function()
  cache.watcher:release()
end

return module
