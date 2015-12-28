local template = require('ext.template')
local module   = {}

local wrapInChromeSpotifyCall = function(str)
  return [[
    tell application "Google Chrome"
      repeat with currentWindow in windows
        repeat with currentTab in tabs of currentWindow
          if URL of currentTab starts with "https://play.spotify.com" then
            ]] .. str .. [[

          end if
        end repeat
      end repeat
    end tell
  ]]
end

-- call JS inside of proper Chrome tab,
-- hacky but works
local clickSpotifyId = function(domId)
  hs.applescript.applescript(wrapInChromeSpotifyCall(template([[
    execute currentTab javascript "document.getElementById('app-player').contentWindow.document.getElementById('{DOM_ID}').click()"
    return
  ]], { DOM_ID = domId })))
end

module.toggle = function()
  clickSpotifyId('play-pause')
end

module.previous = function()
  clickSpotifyId('previous')
end

module.next = function()
  clickSpotifyId('next')
end

module.isRunning = function()
  if not hs.application.get('Google Chrome') then return false end

  local _, res = hs.applescript.applescript(wrapInChromeSpotifyCall('return 1'))

  return res == 1
end

module.shouldProcessEvent = function(systemKey)
  return hs.fnutils.some({ 'PLAY', 'REWIND', 'FAST' }, function(key)
    return key == systemKey.key
  end)
end

module.processEvent = function(systemKey)
  if not module.isRunning() then return false end

  local spotifyMappings = {
    REWIND = 'previous',
    PLAY   = 'toggle',
    FAST   = 'next'
  }

  if systemKey.down then
    onlineSpotify[spotifyMappings[systemKey.key]]()
    return true -- stop propagation if we are controlling online Spotify
  end
end

return module
