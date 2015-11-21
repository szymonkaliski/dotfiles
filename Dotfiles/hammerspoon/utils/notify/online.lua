local cache = {
  offline = nil
}

local openNetworkSettings = function()
  hs.applescript.applescript([[
    tell application "System Preferences"
      activate
      set the current pane to pane id "com.apple.preference.network"
    end tell
  ]])
end

return hs.timer.doEvery(1, function()
  -- ask for headers only - minimum network strain, ping would be best here though...
  hs.http.doAsyncRequest('http://google.com', 'HEAD', nil, nil, function(code, body, response)
    local offline   = code < 0
    local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/airport.png'
    local subTitle  = offline and 'Offline' or 'Online'

    if cache.offline ~= nil and cache.offline ~= offline then
      hs.notify.new(openNetworkSettings, {
        title        = 'Network Status',
        subTitle     = subTitle,
        contentImage = hs.image.imageFromPath(imagePath)
      }):send()
    end

    cache.offline = offline
  end)
end)
