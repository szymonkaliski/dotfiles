local cache = {
  network = hs.wifi.currentNetwork()
}

local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/airport.png'

return hs.wifi.watcher.new(function()
  local network  = hs.wifi.currentNetwork()
  local subTitle = network and 'Network: ' .. network or 'Disconnected'

  if cache.network ~= network then
    hs.notify.new({
      title        = 'Wi-Fi Status',
      subTitle     = subTitle,
      contentImage = imagePath
    }):send()

    cache.network = network
  end
end)
