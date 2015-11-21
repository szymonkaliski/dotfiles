local cache  = {}
local module = {}

module.startAll = function()
  hs.fnutils.each(watchers.enabled, function(watchName)
    cache[watchName] = require('utils.watchers.' .. watchName)
    cache[watchName]:start()
  end)
end

module.stopAll = function()
  hs.fnutils.each(cache, function(watcher)
    watcher:stop()
  end)
end

return module
