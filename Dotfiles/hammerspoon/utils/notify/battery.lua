-- initial status
local cache  = {
  batteryCharged    = hs.battery.isCharged(),
  batteryPercentage = hs.battery.percentage(),
  powerSource       = hs.battery.powerSource(),
  isBurnRateHigh    = false
}

local module = { cache = cache }

local HIGH_BURNRATE = 5
local IMAGE_PATH    = os.getenv('HOME') .. '/.hammerspoon/assets/battery.png'

local round = function(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

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

  local isBurnRateHigh = status.burnRate < HIGH_BURNRATE

  if (isBurnRateHigh and status.burnRate ~= cache.burnRate) or (not isBurnRateHigh and cache.isBurnRateHigh) then
    local subTitle = isBurnRateHigh and 'High 🚨' or 'Back To Normal'

    hs.notify.new({
      title        = 'Burn Rate',
      subTitle     = subTitle,
      contentImage = IMAGE_PATH
    }):send()

    cache.isBurnRateHigh = status.isBurnRateHigh
    cache.burnRate       = status.burnRate
  end
end

module.start = function()
  cache.watcher = hs.watchable.watch('status.battery', notifyBattery)
end

module.stop = function()
  cache.watcher:release()
end

return module
