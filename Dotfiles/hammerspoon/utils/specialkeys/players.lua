local module = {}

local log           = hs.logger.new('players', 'debug');
local onlineSpotify = require('ext.onlinespotify');

local keyMappings = {
  REWIND = 'previous',
  PLAY   = 'playpause',
  FAST   = 'next'
}

local playerMappings = {
  iTunes        = hs.itunes,
  Spotify       = hs.spotify,
  OnlineSpotify = onlineSpotify
}

local notify = function(player)
  local name    = player.name
  local app     = hs.application.find(name)
  local appIcon = app and hs.image.imageFromAppBundle(app:bundleID())

  hs.notify.new({
    title        = player.getCurrentArtist(),
    subTitle     = player.getCurrentTrack(),
    contentImage = appIcon
  }):send()
end

local executeWithPlayer = function(player, action)
  log.d(player.name, action)

  player[action]()
  notify(player)
end

module.shouldProcessEvent = function(event)
  local systemKey = event:systemKey()

  if not next(systemKey) then return false end

  return hs.fnutils.some({ 'PLAY', 'REWIND', 'FAST' }, function(key)
    return key == systemKey.key
  end)
end

module.processEvent = function(event)
  local systemKey = event:systemKey()

  if systemKey.down then
    local action = keyMappings[systemKey.key]

    -- build up running players from settings preferences
    local playerInstances = {}

    hs.fnutils.each(specialkeys.playerPreference, function(playerName)
      local player = playerMappings[playerName]

      if player and player.isRunning() then
        player.name = playerName
        table.insert(playerInstances, player)
      end
    end)

    if #playerInstances == 0 then
      -- if there's no players, then ignore media keys
      return true
    elseif #playerInstances == 1 then
      -- if we have only one, then send events there
      executeWithPlayer(playerInstances[1], action)
    else
      -- otherwise try finding the one that's playing
      local playingPlayer = hs.fnutils.find(playerInstances, function(player) return player.isPlaying() end)

      -- if it's playing then send events there
      -- default to first one from preffered players
      executeWithPlayer(playingPlayer or playerInstances[1], action)
    end
  end

  return true -- stop propagation
end

return module
