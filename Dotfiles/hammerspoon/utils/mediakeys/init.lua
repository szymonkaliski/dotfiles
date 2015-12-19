local keys          = require('ext.table').keys
local onlineSpotify = require('utils.mediakeys.onlinespotify')

local module = {}
local cache  = {}

-- overrides prev/play/next
-- currently controls online spotify in Chrome if running,
-- defaults back to propagating event to os
module.start = function()
  cache.eventtap = hs.eventtap.new({ hs.eventtap.event.types.NSSystemDefined }, function(event)
    local object = event:systemKey()

    -- exit as soon as possible if we don't care about the event
    if not next(object) then return false end

    local shouldProcessEvent = hs.fnutils.some({ 'PLAY', 'REWIND', 'FAST' }, function(key) return key == object.key end)

    if not shouldProcessEvent        then return false end
    if not onlineSpotify.isRunning() then return false end

    local spotifyMappings = {
      REWIND = 'previous',
      PLAY   = 'toggle',
      FAST   = 'next'
    }

    if object.down then
      onlineSpotify[spotifyMappings[object.key]]()
      return true -- stop propagation if we are controlling online Spotify
    end
  end):start()
end

module.stop = function()
  if cache.eventtap then cache.eventtap:stop() end
end

return module
