local cache      = { shouldConnect = hs.settings.get('vpnShouldConnect') or false }
local module     = { cache = cache }

local keys       = require('ext.table').keys
local notify     = require('utils.controlplane.notify')

local iconOff    = os.getenv('HOME') .. '/.hammerspoon/assets/vpn-off.png'
local iconOn     = os.getenv('HOME') .. '/.hammerspoon/assets/vpn-on.png'

local CONFIG_KEY = "State:/Network/Global/Proxies"
local TIMEOUT    = 5

local openVPNSettings = function(name)
  hs.applescript.applescript([[
    tell application "System Preferences"
      activate
      set the current pane to pane id "com.apple.preference.network"
    end tell
  ]])
end

local connectVPN = function()
  if not cache.connecting then
    hs.applescript.applescript([[
      tell application "System Events"
        tell current location of network preferences
          connect the service "]] .. controlplane.persistVPN .. [["
        end tell
      end tell
    ]])

    -- give VPN some time to connect
    cache.connecting = true
    hs.timer.doAfter(TIMEOUT, function()
      cache.connecting = false
    end)

    notify('VPN: Connecting...')
  end
end

local disconnectVPN = function(name)
  if cache.connected then
    hs.applescript.applescript([[
      tell application "System Events"
        tell current location of network preferences
          disconnect the service "]] .. controlplane.persistVPN .. [["
        end tell
      end tell
    ]])

    cache.connecting = false

    notify('VPN: Disconnecting...')
  end
end

local toggleVPN = function()
  cache.shouldConnect = not cache.connected

  if cache.connected then
    disconnectVPN()
  else
    connectVPN()
  end
end

local updateMenuItem = function()
  local headerText = cache.connected and 'VPN: Connected' or 'VPN: Disconnected'

  cache.menuItem
    :setMenu({
      { title = headerText, disabled = true },
      { title = cache.connected and 'Disconnect' or 'Connect', fn = toggleVPN },
      { title = '-' },
      { title = 'Open VPN Preferences...', fn = openVPNSettings }
    })
    :setIcon(cache.connected and iconOn or iconOff)
end

local updateConfiguration = function(_, _)
  local contents         = cache.configuration:contents(CONFIG_KEY)[CONFIG_KEY]
  local hasConfiguration = #keys(contents) > 0

  if hasConfiguration then
    cache.connected = contents["__SCOPED__"]["ppp0"] ~= nil

    if cache.connected and not cache.shouldConnect then
      disconnectVPN()
    end

    if not cache.connected and cache.shouldConnect then
      connectVPN()
    end
  else
    cache.connected = false
  end

  updateMenuItem()
end

module.start = function()
  cache.menuItem      = hs.menubar.new()
  cache.configuration = hs.network.configuration.open()

  cache.configuration
    :monitorKeys({ CONFIG_KEY })
    :setCallback(updateConfiguration)
    :start()

  -- begin with setting up config
  updateConfiguration()
end

module.stop = function()
  cache.configuration:stop()

  -- store last vpn settings
  hs.settings.set('vpnShouldConnect', cache.shouldConnect)
end

return module

