local module    = {}

local bluetooth   = require('hs._asm.undocumented.bluetooth')
local template    = require('ext.template')
local imagePath   = os.getenv('HOME') .. '/.hammerspoon/assets/macbook.png'
local scriptsPath = os.getenv('HOME') .. '/Documents/Code/Scripts/'

local watchers  = {}
local cache     = { powerSource = hs.battery.powerSource() }

local runMountTask = function(name, script)
  hs.fnutils.each({ 'mountTask', 'umountTask' }, function(task)
    if cache[task] then cache[task]:terminate() end
  end)

  cache[name] = hs.task.new(scriptsPath .. script, callback)
  cache[name]:start()
end

local umountAll = function(callback)
  runMountTask('umountTask', 'umount-all')
end

local mountAll = function(callback)
  runMountTask('mountTask', 'mount-all')
end

local setVPN = function(options)
  hs.applescript.applescript(template([[
    tell application "System Events"
      tell current location of network preferences
        {COMMAND} the service "VPN"
      end tell
    end tell
  ]], { COMMAND = options.connect == true and 'connect' or 'disconnect' }))
end

local disconnectVPN = function()
  setVPN({ connect = false })
end

local connectVPN = function()
  setVPN({ connect = true })
end

local notify = function(message)
  hs.notify.new({
    title        = 'ControlPlane',
    subTitle     = message,
    contentImage = imagePath
  }):send()
end

-- unmount when switched to battery
-- disable bluetooth when on battery, re-anble when on AC
local batteryWatcher = function()
  local powerSource = hs.battery.powerSource()

  if cache.powerSource ~= nil and cache.powerSource ~= powerSource then
    if powerSource == 'Battery Power' then
      bluetooth.power(false)

      umountAll(function()
        notify('Disks ejected, Bluetooth off')
      end)
    end

    if powerSource == 'AC Power' then
      bluetooth.power(true)

      mountAll(function()
        notify('Disks mounted, Bluetooth on')
      end)
    end
  end

  cache.powerSource = powerSource
end

-- unmount on sleep, mount on wake
local sleepWatcher = function(event)
  if event == hs.caffeinate.watcher.systemWillSleep then
    umountAll(function()
      notify('Disks ejected')
    end)
  end

  if event == hs.caffeinate.watcher.systemDidWake then
    mountAll(function()
      notify('Disks mounted')
    end)
  end
end

-- connect to VPN if wifi other than home
local wifiWatcher = function()
  local network = hs.wifi.currentNetwork()

  if network ~= cache.network and network ~= controlplane.homeNetwork then
    connectVPN()
    notify('VPN connected')
  else
    disconnectVPN()
    notify('VPN disconnected')
  end
end

module.start = function()
  watchers.battery = hs.battery.watcher.new(batteryWatcher)
  watchers.sleep   = hs.caffeinate.watcher.new(sleepWatcher)
  watchers.wifi    = hs.wifi.watcher.new(wifiWatcher)

  -- run wifi watcher on start to be sure we are on VPN if needed
  wifiWatcher()

  hs.fnutils.each(watchers, function(watcher)
    watcher:start()
  end)
end

module.stop = function()
  hs.fnutils.each(watchers, function(watcher)
    watcher:stop()
  end)
end

return module
