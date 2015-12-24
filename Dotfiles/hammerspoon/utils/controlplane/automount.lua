local module = {}
local cache  = { watchers = {} }

local notify = require('utils.controlplane.notify')

local stopMountTasks = function()
  hs.fnutils.each({ 'mountTask', 'umountTask' }, function(task)
    if cache[task] then cache[task]:terminate() end
  end)
end

local runMountTask = function(name, script, callback)
  stopMountTasks()

  cache[name] = hs.task.new(scriptsPath .. script, callback)
  cache[name]:start()
end

local umountAll = function(callback)
  runMountTask('umountTask', 'umount-all', function() notify('Disks ejected') end)
end

local mountAll = function(callback)
  runMountTask('mountTask', 'mount-all', function() notify('Disks mounted') end)
end

local batteryWatcher = function()
  local powerSource = hs.battery.powerSource()

  if cache.powerSource ~= nil and cache.powerSource ~= powerSource then
    if powerSource == 'Battery Power' then
      umountAll()
    end

    if powerSource == 'AC Power' then
      mountAll()
    end
  end

  cache.powerSource = powerSource
end

local sleepWatcher = function()
  if event == hs.caffeinate.watcher.systemWillSleep then
    umountAll()
  end

  if event == hs.caffeinate.watcher.systemDidWake then
    mountAll()
  end
end

module.start = function()
  cache.watchers.battery = hs.screen.watcher.new(batteryWatcher):start()
  cache.watchers.sleep   = hs.caffeinate.watcher.new(sleepWatcher):start()
end

module.stop = function()
  hs.fnutils.each(cache.watchers, function(watcher)
    watcher:stop()
  end)

  stopMountTasks()
end

return module
