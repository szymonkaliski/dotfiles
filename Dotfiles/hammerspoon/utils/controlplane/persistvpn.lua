local log     = hs.logger.new('persistvpn', 'debug')

local cache   = { shouldConnect = hs.settings.get('vpnShouldConnect') or false }
local module  = { cache = cache }

local keys    = require('ext.table').keys
local notify  = require('utils.controlplane.notify')

local ICON_OFF = os.getenv('HOME') .. '/.hammerspoon/assets/vpn-off.png'
local ICON_ON  = os.getenv('HOME') .. '/.hammerspoon/assets/vpn-on.png'

local openVPNSettings = function()
  hs.applescript.applescript([[
    tell application "System Preferences"
      activate
      set the current pane to pane id "com.apple.preference.network"
    end tell
  ]])
end

local connectVPN = function()
  hs.applescript.applescript([[
    tell application "System Events"
      tell current location of network preferences
        connect the service "]] .. controlplane.persistVPN .. [["
      end tell
    end tell
  ]])

  notify('VPN: Connecting...')
end

local disconnectVPN = function()
  hs.applescript.applescript([[
    tell application "System Events"
      tell current location of network preferences
        disconnect the service "]] .. controlplane.persistVPN .. [["
      end tell
    end tell
  ]])

  notify('VPN: Disconnecting...')
end

module.toggleVPN = function()
  cache.shouldConnect = not cache.shouldConnect

  log.d('toggling; connected:', cache.connected, 'shouldConnect:', cache.shouldConnect)

  if cache.connected then
    disconnectVPN()
  else
    connectVPN()
  end

  module.updateMenuItem()
end

module.updateMenuItem = function()
  local headerText = cache.connected and 'VPN: Connected' or 'VPN: Disconnected'
  local actionText = cache.connected and 'Disconnect' or 'Connect'

  cache.menuItem
    :setMenu({
      { title = headerText, disabled = true },
      { title = actionText, fn = module.toggleVPN },
      { title = '-' },
      { title = 'Open VPN Preferences...', fn = openVPNSettings }
    })
    :setIcon(cache.connected and ICON_ON or ICON_OFF)
end

local updateConfiguration = function(_, _, _, _, vpnConfiguration)
  local hasConfiguration = #keys(vpnConfiguration) > 0
  cache.connected = hasConfiguration and vpnConfiguration['__SCOPED__']['ppp0'] ~= nil or false

  log.d('updated configuration; connected:', cache.connected, 'shouldConnect:', cache.shouldConnect)

  if cache.connected and not cache.shouldConnect then
    disconnectVPN()
  end

  if not cache.connected and cache.shouldConnect then
    connectVPN()
  end

  if cache.connected == cache.shouldConnect then
    -- equals when done connecting/disconnecting, flush DNS info to be safe
    hs.task.new('/usr/bin/dscacheutil', nil, { '-flushcache' }):start()
    notify('VPN: ' .. (cache.connected and 'Connected' or 'Disconnected'))
  end

  module.updateMenuItem()
end

module.start = function()
  cache.menuItem = hs.menubar.new()

  cache.watcher = hs.watchable.watch('status.vpnConfiguration', updateConfiguration)

  module.updateMenuItem()
end

module.stop = function()
  -- store last vpn settings
  hs.settings.set('vpnShouldConnect', cache.shouldConnect)

  cache.watcher:release()
end

return module

