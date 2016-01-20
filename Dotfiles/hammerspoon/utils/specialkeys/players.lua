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

local executeWithPlayer = function(player, action)
  log.d(player.name, action)
  player[action]()
end

module.shouldProcessEvent = function(systemKey)
  return hs.fnutils.some({ 'PLAY', 'REWIND', 'FAST' }, function(key)
    return key == systemKey.key
  end)
end

module.processEvent = function(systemKey)
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
