local cache  = {}
local module = { cache = cache }
local log    = hs.logger.new('random-mac', 'debug');

-- sudo commands have to be configured in /etc/sudoers for passwordless access, e.g.:
-- szymon ALL=(root) NOPASSWD: /usr/local/bin/spoof

-- FIXME: this works, but if I turn wi-fi off, it turns it on when randomizing mac...
local randomizeMAC = function(_, _, _, prevNetwork, network)
  if network == nil and network ~= prevNetwork then
    log.d("wi-fi connected, randomizing MAC")

    hs.execute('/usr/bin/sudo /usr/local/bin/spoof randomize wi-fi', true)
  end
end

module.start = function()
  cache.watcher = hs.watchable.watch('status.currentNetwork', randomizeMAC)
end

module.stop = function()
  cache.watcher:release()
end

return module
