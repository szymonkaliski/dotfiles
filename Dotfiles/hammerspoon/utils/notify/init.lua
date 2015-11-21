local cache  = {}
local module = {}

module.startAll = function()
  hs.fnutils.each(notify.enabled, function(notifyName)
    cache[notifyName] = require('utils.notify.' .. notifyName)
    cache[notifyName]:start()
  end)
end

module.stopAll = function()
  hs.fnutils.each(cache, function(notify)
    notify:stop()
  end)
end

return module
