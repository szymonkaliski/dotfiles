local module    = {}
local cache     = {}
local callbacks = {}
local started   = false
local keys      = require('ext.table').keys

local startPing = function()
  -- check if online every second
  cache.timer = hs.timer.doEvery(1, function()
    if #keys(callbacks) == 0 then
      cache.timer:stop()
      return
    end

    hs.http.doAsyncRequest('http://google.com', 'HEAD', nil, nil, function(responseCode)
      local isOnline = responseCode >= 0

      for _, callback in pairs(callbacks) do
        callback(isOnline)
      end
    end)
  end):start()
end

module.subscribe = function(id, callback)
  if not started then startPing() end

  callbacks[id] = callback
end

module.unsubscribe = function(id)
  callbacks[id] = nil
end

return module
