local module = {}
local cache  = {
  builtInInput  = hs.audiodevice.findDeviceByName('Built-in Input'),
  builtInOutput = hs.audiodevice.findDeviceByName('Built-in Output')
}

local notify = require('utils.controlplane.notify')

local switchToPreferredDevice = function()
  local foundName = hs.fnutils.find(controlplane.audioPreference, function(name)
    return hs.audiodevice.findDeviceByName(name)
  end)

  local availableDevice = hs.audiodevice.findDeviceByName(foundName)

  if availableDevice then
    availableDevice:setDefaultInputDevice()
    availableDevice:setDefaultOutputDevice()

    notify('Current device: ' .. availableDevice:name())
  end
end

local jackWatcher = function(_, eventName)
  if eventName ~= 'jack' then return end

  if cache.builtInOutput:jackConnected() then
    cache.builtInInput:setDefaultInputDevice()
    cache.builtInOutput:setDefaultOutputDevice()

    notify('Current device: Headphones')
  else
    switchToPreferredDevice()
  end
end

local deviceWatcher = function()
  if cache.builtInOutput:jackConnected() then return end
  switchToPreferredDevice()
end

-- monitor for headphones and switch to them as default input device
-- useful for Skype and FaceTime
module.start = function(module)
  cache.builtInOutput:watcherCallback(jackWatcher)
  cache.builtInOutput:watcherStart()

  hs.audiodevice.watcher.setCallback(deviceWatcher)
  hs.audiodevice.watcher.start()
end

module.stop = function(module)
  if hs.audiodevice.watcher.isRunning() then
    hs.audiodevice.watcher.stop()
  end

  if cache.builtInOutput:watcherIsRunning() then
    cache.builtInOutput:watcherStop()
  end
end

return module
