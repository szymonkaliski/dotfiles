-- initial status
local cache = {
  batteryCharged    = hs.battery.isCharged(),
  batteryPercentage = hs.battery.percentage(),
  powerSource       = hs.battery.powerSource()
}

local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/battery.png'

local stringifyMinutes = function(minutes)
  local hours   = math.floor(minutes / 60)
  local minutes = minutes % 60
  return string.format('%02d', hours) .. ':' .. string.format('%02d', minutes)
end

return hs.battery.watcher.new(function()
  local batteryPercentage = hs.battery.percentage()
  local isCharged         = hs.battery.isCharged()
  local powerSource       = hs.battery.powerSource()
  local timeRemaining     = hs.battery.timeRemaining()

  if batteryPercentage < 100 then
    cache.batteryCharged = false
  end

  if isCharged ~= cache.batteryCharged and batteryPercentage == 100 and powerSource == 'AC Power' then
    hs.notify.new({
      title        = 'Battery Status',
      subTitle     = 'Charged completely!',
      contentImage = imagePath
    }):send()

    cache.batteryCharged = true
  end

  if powerSource ~= cache.powerSource then
    hs.notify.new({
      title        = 'Power Source Status',
      subTitle     = 'Current source: ' .. powerSource,
      contentImage = imagePath
    }):send()

    cache.powerSource = powerSource
  end
end)

