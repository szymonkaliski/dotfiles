local module = {}
local cache  = {}

local onlineWatcher = require('ext.onlinewatcher')
local notify        = require('utils.controlplane.notify')

local isVPNConnected = function()
  local _, res = hs.applescript.applescript([[
    tell application "System Events"
      tell current location of network preferences
        set connection to the service "VPN"
        set config to the current configuration of connection

        if config is connected then
          return 1
        else
          return 0
        end if
      end tell
    end tell
  ]])

  return res == 1
end

local connectVPN = function(options)
  hs.applescript.applescript([[
    tell application "System Events"
      tell current location of network preferences
        connect the service "VPN"
      end tell
    end tell
  ]])
end

module.start = function()
  onlineWatcher.subscribe('persistVPN', function(isOnline)
    -- don't connect if we already are connected
    if not isOnline or isVPNConnected() then return end

    -- ignore if we are connecting
    if cache.connecting then return end

    -- otherwise connect and notify
    connectVPN()
    notify('Reconnecting to VPN...')

    -- give VPN some time to connect
    local vpnTimeout = 5
    cache.connecting = true
    hs.timer.doAfter(vpnTimeout, function() cache.connecting = false end)
  end)
end

module.stop = function()
  onlineWatcher.unsubscribe('persistVPN')
end

return module
