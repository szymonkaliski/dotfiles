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

module.playpause = function()
  clickSpotifyId('play-pause')
end

module.previous = function()
  clickSpotifyId('previous')
end

module.next = function()
  clickSpotifyId('next')
end

module.getCurrentArtist = function()
  if not module.isRunning() then return false end

  local _, res = hs.applescript.applescript(wrapInChromeSpotifyCall([[
    return execute currentTab javascript "document.getElementById('app-player').contentWindow.document.getElementById('track-artist').textContent"
  ]]))

  return res
end

module.getCurrentTrack = function()
  if not module.isRunning() then return false end

  local _, res = hs.applescript.applescript(wrapInChromeSpotifyCall([[
    return execute currentTab javascript "document.getElementById('app-player').contentWindow.document.getElementById('track-name').textContent"
  ]]))

  return res
end

module.isPlaying = function()
  if not module.isRunning() then return false end

  local _, res = hs.applescript.applescript(wrapInChromeSpotifyCall([[
    return execute currentTab javascript "document.getElementById('app-player').contentWindow.document.getElementById('play-pause').className.indexOf('playing') >= 0 ? 1 : 0"
  ]]))

  return res == 1
end

module.isRunning = function()
  if not hs.application.get('Google Chrome') then return false end

  local _, res = hs.applescript.applescript(wrapInChromeSpotifyCall('return 1'))

  return res == 1
end

return module
