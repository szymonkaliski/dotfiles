local log    = hs.logger.new('automount', 'debug')

local cache  = { tasks = {} }
local module = { cache = cache }

local SCRIPTS_PATH  = os.getenv('HOME') .. '/Documents/Code/Scripts/'
local MOUNT_TIMEOUT = 5

local logTask = function(_, stdOut, stdErr)
  log.d("\n", stdOut, stdErr)
end

local stopMountTasks = function()
  for _, task in pairs(cache.tasks) do
    task:terminate()
  end
end

local runMountTask = function(script, callback)
  stopMountTasks()

  cache.tasks[script] = hs.task.new(SCRIPTS_PATH .. script, callback)
  cache.tasks[script]:start()
end

-- local

local umountLocal = function()
  log.d('umount-local triggered')

  if cache.timer then cache.timer:stop() end

  runMountTask('umount-local', logTask)
end

local mountLocal = function()
  log.d('mount-local triggered')

  cache.timer = hs.timer.doAfter(MOUNT_TIMEOUT, function()
    log.d('mount-local starting')
    runMountTask('mount-local', logTask)
  end)
end

-- remote

local umountRemote = function()
  log.d('umount-remote triggered')

  runMountTask('umount-remote', logTask)
end

local mountRemote = function()
  log.d('mount-remote triggered')

  runMountTask('mount-remote', logTask)
end

-- watchers

local batteryWatcher = function(_, _, _, prevPowerSource, powerSource)
  if prevPowerSource ~= powerSource then
    if powerSource == 'Battery Power' then
      umountLocal()
    end

    if powerSource == 'AC Power' then
      mountLocal()
    end
  end
end

local sleepWatcher = function(_, _, _, _, event)
  if event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.systemWillPowerOff then
    umountLocal()
  end

  if event == hs.caffeinate.watcher.systemDidWake then
    mountLocal()
  end
end

local wifiWatcher = function(_, _, _, _, currentNetwork)
  if currentNetwork == config.network.home then
    mountRemote()
  else
    umountRemote()
  end
end

-- module

module.start = function()
  cache.watcherBattery = hs.watchable.watch('status.battery.powerSource', batteryWatcher)
  cache.watcherSleep   = hs.watchable.watch('status.sleepEvent',          sleepWatcher)
  cache.watcherWifi    = hs.watchable.watch('status.currentNetwork',      wifiWatcher)
end

module.stop = function()
  stopMountTasks()

  cache.watcherBattery:release()
  cache.watcherSleep:release()
  cache.watcherWifi:release()
end

return module
