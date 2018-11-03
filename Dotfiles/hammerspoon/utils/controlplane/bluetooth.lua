local cache  = {}
local module = { cache = cache }

local bluetooth = require('hs._asm.undocumented.bluetooth')
local notify    = require('utils.controlplane.notify')

local screenWatcher = function(_, _, _, _, isThunderboltConnected)
  if cache.timer then cache.timer:stop() end

  -- wait time before turning bluetooth on/off, fixes problems with bluetooth adapter plugged in thunderbolt
  local timeout = 5

  cache.timer = hs.timer.doAfter(timeout, function()
    -- turn on only when using with thunderbolt display
    if isThunderboltConnected and not bluetooth.power() then
      bluetooth.power(true)
      notify('Bluetooth: On')
    end

    -- turn off otherwise
    if not isThunderboltConnected and bluetooth.power() then
      bluetooth.power(false)
      notify('Bluetooth: Off')
    end
  end)
end

module.start = function()
  cache.watcher = hs.watchable.watch('status.isThunderboltConnected', screenWatcher)
end

module.stop = function()
  cache.watcher:release()
end

return module
