local cache  = {}
local module = { cache = cache }

module.start = function()
  hs.fnutils.each(spaces.enabled, function(controlName)
    cache[controlName] = require('utils.spaces.' .. controlName)
    cache[controlName]:start()
  end)
end

module.stop = function()
  hs.fnutils.each(cache, function(control)
    control:stop()
  end)
end

return module
