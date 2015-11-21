local cache = {
  network = hs.wifi.currentNetwork()
}

return hs.wifi.watcher.new(function()
  local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/airport.png'
  local network   = hs.wifi.currentNetwork()
  local subTitle  = network and 'Network: ' .. network or 'Disconnected'

  if cache.network ~= network then
    hs.notify.new({
      title        = 'Wi-Fi Status',
      subTitle     = subTitle,
      contentImage = hs.image.imageFromPath(imagePath)
    }):send()
  end
end)
