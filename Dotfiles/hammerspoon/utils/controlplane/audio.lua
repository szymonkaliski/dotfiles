local cache  = {
  previousDevice   = hs.audiodevice.current().uid,
  wasJackConnected = hs.audiodevice.findDeviceByName('Built-in Input'):jackConnected(),
  builtInInput     = hs.audiodevice.findDeviceByName('Built-in Input'),
  builtInOutput    = hs.audiodevice.findDeviceByName('Built-in Output')
}

local module = { cache = cache }

local notify = require('utils.controlplane.notify')

local switchToPreferredDevice = function()
  local isJackConnected = cache.builtInOutput:jackConnected()

  if isJackConnected and not cache.wasJackConnected then
    cache.builtInInput:setDefaultInputDevice()
    cache.builtInOutput:setDefaultOutputDevice()

    notify('Audio device: Headphones')

    cache.previousDevice   = cache.builtInOutput:uid()
    cache.wasJackConnected = true
  end

  if not isJackConnected then
    local foundName = hs.fnutils.find(controlplane.audioPreference, function(name)
      return hs.audiodevice.findDeviceByName(name)
    end)

    local availableDevice = hs.audiodevice.findDeviceByName(foundName)

    if availableDevice and (cache.previousDevice ~= availableDevice:uid() or cache.wasJackConnected) then
      availableDevice:setDefaultInputDevice()
      availableDevice:setDefaultOutputDevice()

      notify('Audio device: ' .. availableDevice:name())

      cache.previousDevice = availableDevice:uid()
    end

    cache.wasJackConnected = false
  end
end

-- monitor for headphones and switch to them as default input device
-- useful for Skype and FaceTime
module.start = function(_)
  cache.builtInOutput:watcherCallback(switchToPreferredDevice)
  cache.builtInOutput:watcherStart()

  hs.audiodevice.watcher.setCallback(switchToPreferredDevice)
  hs.audiodevice.watcher.start()

  -- setup on start
  switchToPreferredDevice()
end

module.stop = function(_)
  if hs.audiodevice.watcher.isRunning() then
    hs.audiodevice.watcher.stop()
  end

  if cache.builtInOutput:watcherIsRunning() then
    cache.builtInOutput:watcherStop()
  end
end

return module
