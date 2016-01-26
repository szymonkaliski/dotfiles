local module        = {}
local cache         = {}
local vpnTimeout    = 10 -- timeout before re-connecting to VPN

local notify        = require('utils.controlplane.notify')
local onlineWatcher = require('ext.onlinewatcher')

local iconOff       = os.getenv('HOME') .. '/.hammerspoon/assets/vpn-off.png'
local iconOn        = os.getenv('HOME') .. '/.hammerspoon/assets/vpn-on.png'

local openVPNSettings = function()
  hs.applescript.applescript([[
    tell application "System Preferences"
      activate
      set the current pane to pane id "com.apple.preference.network"
      reveal anchor "VPN" of pane id "com.apple.preference.network"
    end tell
  ]])
end

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

local connectVPN = function()
  hs.applescript.applescript([[
    tell application "System Events"
      tell current location of network preferences
        connect the service "VPN"
      end tell
    end tell
  ]])

  -- give VPN some time to connect
  cache.connecting = true
  hs.timer.doAfter(vpnTimeout, function()
    cache.connecting = false
  end)

  notify('Connecting to VPN...')
end

local disconnectVPN = function()
  hs.applescript.applescript([[
    tell application "System Events"
      tell current location of network preferences
        disconnect the service "VPN"
      end tell
    end tell
  ]])

  cache.connecting = false

  notify('Disconnecting from VPN...')
end

local updateMenuItem = function()
  local isConnected = isVPNConnected()

  local generateMenu = function(options)
    return {
      { title = options.statusText,        disabled = true      },
      { title = options.subStatusText,     fn = options.fn      },
      { title = '-'                                             },
      { title = 'Open VPN Preferences...', fn = openVPNSettings }
    }
  end

  if isConnected then
    cache.menuItem
      :setMenu(generateMenu({
        statusText    = 'VPN: Connected',
        subStatusText = 'Disconnect from VPN',
        fn            = disconnectVPN
      }))
      :setIcon(iconOn)
  elseif cache.connecting then
    cache.menuItem
      :setMenu(generateMenu({
        statusText    = 'VPN: Connecting...',
        subStatusText = 'Disconnect from VPN',
        fn            = disconnectVPN
      }))
  else
    cache.menuItem
      :setMenu(generateMenu({
        statusText    = 'VPN: Disconnected',
        subStatusText = 'Connect to VPN',
        fn            = connectVPN
      }))
      :setIcon(iconOff)
  end
end

module.start = function()
  -- start with vpn enabled status from saved setting
  local vpnEnabled = hs.settings.get('vpnEnabled')
  if vpnEnabled == nil then hs.settings.set('vpnEnabled', true) end

  -- create menu icon for quick toggle
  cache.menuItem = hs.menubar.new()
  updateMenuItem()

  cache.onlineHandle = onlineWatcher.subscribe(function(isOnline)
    -- we don't care about VPN if there's no internet connection
    if not isOnline then return end

    local isConnected = isVPNConnected()
    local vpnEnabled  = hs.settings.get('vpnEnabled')

    -- connect if not connected and should be
    if vpnEnabled and not (cache.connecting or isConnected) then
      connectVPN()
    end

    -- disconnected if connected and shouldn't be
    if not vpnEnabled and isConnected then
      disconnectVPN()
    end

    -- always update icon
    updateMenuItem()
  end)
end

module.stop = function()
  onlineWatcher.unsubscribe(cache.onlineHandle)
end

return module
