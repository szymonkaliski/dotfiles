-- initial status
local cache  = {
  batteryCharged    = hs.battery.isCharged(),
  batteryPercentage = hs.battery.percentage(),
  powerSource       = hs.battery.powerSource()
}

local module = { cache = cache }

local IMAGE_PATH = os.getenv('HOME') .. '/.hammerspoon/assets/battery.png'

local notifyBattery = function(_, _, _, _, status)
  if status.percentage < 100 then
    cache.batteryCharged = false
  end

  if status.isCharged ~= cache.batteryCharged and status.percentage == 100 and status.powerSource == 'AC Power' then
    hs.notify.new({
      title        = 'Power Status',
      subTitle     = 'Battery: Charged',
      contentImage = IMAGE_PATH
    }):send()

    cache.batteryCharged = true
  end

  if status.powerSource ~= cache.powerSource then
    hs.notify.new({
      title        = 'Power Status',
      subTitle     = 'Source: ' .. status.powerSource,
      contentImage = IMAGE_PATH
    }):send()

    cache.powerSource = status.powerSource
  end
end

module.start = function()
  cache.watcher = hs.watchable.watch('status.battery', notifyBattery)
end

module.stop = function()
  cache.watcher:release()
end

return module
