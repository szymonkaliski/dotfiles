local module = {}
local cache  = { callbacks = {} }
local keys   = require('ext.table').keys
local count  = 1

local startPing = function()
  -- check for online status every second
  cache.timer = hs.timer.doEvery(1, function()
    if #keys(cache.callbacks) == 0 then
      cache.timer:stop()
      return
    end

    hs.http.doAsyncRequest('http://google.com', 'HEAD', nil, nil, function(responseCode)
      local isOnline = responseCode >= 0

      for _, callback in pairs(cache.callbacks) do callback(isOnline) end
    end)
  end):start()
end

module.subscribe = function(callback)
  if not cache.timer then startPing() end

  local id = count
  count = count + 1

  cache.callbacks[id] = callback
end

module.unsubscribe = function(id)
  cache.callbacks[id] = nil
end

return module
