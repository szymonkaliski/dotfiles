local module    = {}

local bluetooth = require('hs._asm.undocumented.bluetooth')
local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/macbook.png'

local watchers  = {}
local cache     = {
  powerSource = hs.battery.powerSource()
}

local umountAll = function()
  hs.applescript.applescript([[
    tell application "Finder"
      eject (every disk)
    end tell
  ]])
end

local mountAll = function()
  os.execute([[
    /usr/sbin/diskutil list | awk '/Apple_HFS/ {print $NF}' | xargs -I{} /usr/sbin/diskutil mount {} > /dev/null 2>&1 &
  ]])
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
      umountAll()
      bluetooth.power(false)
      notify('Disks ejected, Bluetooth off')
    end

    if powerSource == 'AC Power' then
      bluetooth.power(true)
      notify('Bluetooth on')
    end
  end

  cache.powerSource = powerSource
end

-- unmount on sleep, mount on wake
local sleepWatcher = function(event)
  if event == hs.caffeinate.watcher.systemWillSleep then
    umountAll()
    notify('Disks ejected')
  end

  if event == hs.caffeinate.watcher.systemDidWake then
    mountAll()
    notify('Disks mounted')
  end
end

module.start = function()
  watchers.battery = hs.battery.watcher.new(batteryWatcher)
  watchers.sleep   = hs.caffeinate.watcher.new(sleepWatcher)

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
