local cache  = {}
local module = { cache = cache }

local bluetooth = require('hs._asm.undocumented.bluetooth')
local notify    = require('utils.controlplane.notify')

local screenWatcher = function()
  local isThunderboltConnected = hs.screen.findByName('Thunderbolt Display')

  if cache.timer then
    cache.timer:stop()
  end

  -- wait time before turning bluetooth on/off, hopefully will fix problems with bluetooth adapter and mouse
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
  cache.watcher = hs.screen.watcher.new(screenWatcher):start()

  -- setup on start
  screenWatcher()
end

module.stop = function()
  if cache.watcher then cache.watcher:stop() end
end

return module
