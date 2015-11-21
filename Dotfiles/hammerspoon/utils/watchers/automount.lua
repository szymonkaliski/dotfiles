local module   = {}
local watchers = {}
local cache    = {
  powerSource = hs.battery.powerSource()
}

local log = hs.logger.new('automount', 'info')

local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/macbook.png'

local umountAll = function()
  hs.applescript.applescript([[
    tell application "Finder"
      eject (every disk)
    end tell
  ]])

  hs.notify.new({
    title        = 'Automount',
    subTitle     = 'All disks ejected',
    contentImage = imagePath
  }):send()
end

local mountAll = function()
  os.execute([[
    /usr/sbin/diskutil list | awk '/Apple_HFS/ {print $NF}' | xargs -I{} /usr/sbin/diskutil mount {} > /dev/null 2>&1 &
  ]])

  hs.notify.new({
    title        = 'Automount',
    subTitle     = 'All disks mounted',
    contentImage = imagePath
  }):send()
end

-- unmount when switched to battery
local batteryWatcher = function()
  local powerSource = hs.battery.powerSource()

  if cache.powerSource ~= nil and cache.powerSource ~= powerSource and powerSource == 'Battery Power' then
    log.i('power source unmounting all')
    umountAll()
  end

  cache.powerSource = powerSource
end

-- unmount on sleep, mount on wake
local sleepWatcher = function(event)
  if event == hs.caffeinate.watcher.systemWillSleep then
    log.i('sleep unmounting all')
    umountAll()
  end

  if event == hs.caffeinate.watcher.systemDidWake then
    log.i('sleep mounting all')
    mountAll()
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
