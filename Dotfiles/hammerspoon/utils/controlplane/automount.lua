local cache  = {
  powerSource = hs.battery.powerSource(),
  watchers    = {},
  tasks       = {}
}

local module = { cache = cache }

local scriptsPath = os.getenv('HOME') .. '/Documents/Code/Scripts/'
local notify      = require('utils.controlplane.notify')

local stopMountTasks = function()
  for _, task in pairs(cache.tasks) do
    task:terminate()
  end
end

local runMountTask = function(script, callback)
  stopMountTasks()

  cache.tasks[script] = hs.task.new(scriptsPath .. script, callback)
  cache.tasks[script]:start()
end

local umountAll = function(callback)
  runMountTask('umount-all', function() notify('Disks ejected') end)
end

local mountAll = function(callback)
  runMountTask('mount-all', function() notify('Disks mounted') end)
end

local batteryWatcher = function()
  local powerSource = hs.battery.powerSource()

  if cache.powerSource ~= powerSource then
    if powerSource == 'Battery Power' then
      umountAll()
    end

    if powerSource == 'AC Power' then
      mountAll()
    end
  end

  cache.powerSource = powerSource
end

local sleepWatcher = function(event)
  if event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.systemWillPowerOff then
    umountAll()
  end

  if event == hs.caffeinate.watcher.systemDidWake then
    mountAll()
  end
end

module.start = function()
  cache.watchers.battery = hs.battery.watcher.new(batteryWatcher):start()
  cache.watchers.sleep   = hs.caffeinate.watcher.new(sleepWatcher):start()
end

module.stop = function()
  hs.fnutils.each(cache.watchers, function(watcher)
    watcher:stop()
  end)

  stopMountTasks()
end

return module
