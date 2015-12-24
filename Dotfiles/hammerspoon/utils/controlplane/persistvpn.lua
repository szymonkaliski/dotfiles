local module = {}

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

local setVPN = function(options)
  hs.applescript.applescript(template([[
    tell application "System Events"
      tell current location of network preferences
        {COMMAND} the service "VPN"
      end tell
    end tell
  ]], { COMMAND = options.connect == true and 'connect' or 'disconnect' }))
end

local disconnectVPN = function()
  setVPN({ connect = false })
end

local connectVPN = function()
  setVPN({ connect = true })
end

module.start = function()
  onlineWatcher.subscribe('persistVPN', function(isOnline)
    -- don't connect if we already are connected
    if not isOnline or isVPNConnected() then return end

    connectVPN()
    notify('Reconnecting to VPN')
  end)
end

module.stop = function()
  onlineWatcher.unsubscribe('persistVPN')
end

return module
