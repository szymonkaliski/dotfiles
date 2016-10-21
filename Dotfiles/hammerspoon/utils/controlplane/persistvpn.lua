local cache      = { vpnSettings = hs.settings.get('vpnSettings') or {} }
local module     = { cache = cache }

local vpnTimeout = 10 -- timeout before re-connecting to VPN

local notify     = require('utils.controlplane.notify')

local iconOff    = os.getenv('HOME') .. '/.hammerspoon/assets/vpn-off.png'
local iconOn     = os.getenv('HOME') .. '/.hammerspoon/assets/vpn-on.png'

local currentBssid = function()
  return hs.wifi.interfaceDetails().bssid
end

local currentVPN = function()
  return cache.vpnSettings[currentBssid()]
end

local openVPNSettings = function(name)
  hs.applescript.applescript([[
    tell application "System Preferences"
      activate
      set the current pane to pane id "com.apple.preference.network"
    end tell
  ]])
end

local isVPNConnected = function(name)
  if name then
    local _, res = hs.applescript.applescript([[
      tell application "System Events"
        tell current location of network preferences
          set connection to the service "]] .. name .. [["
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
  else
    return false
  end
end

local isAnyVPNConnected = function()
  return hs.fnutils.some(controlplane.vpns, isVPNConnected)
end

local connectVPN = function(name)
  if name and not isVPNConnected(name) and not cache.connecting then
    hs.applescript.applescript([[
      tell application "System Events"
        tell current location of network preferences
          connect the service "]] .. name .. [["
        end tell
      end tell
    ]])

    -- give VPN some time to connect
    cache.connecting = true
    hs.timer.doAfter(vpnTimeout, function()
      cache.connecting = false
    end)

    notify('Connecting to ' .. name .. '...')
  end
end

local disconnectVPN = function(name)
  if isVPNConnected(name) then
    hs.applescript.applescript([[
      tell application "System Events"
        tell current location of network preferences
          disconnect the service "]] .. name .. [["
        end tell
      end tell
    ]])

    cache.connecting = false

    notify('Disconnecting from ' .. name .. '...')
  end
end

local disconnectAllVPNs = function()
  hs.fnutils.each(controlplane.vpns, disconnectVPN)
end

local updateMenuItem = function(isConnected)
  local VPN        = currentVPN()
  local bssid      = currentBssid()
  local headerText = isConnected and VPN .. ': Connected' or 'VPN: Disconnected'
  local vpnSubmenu = {}

  hs.fnutils.each(controlplane.vpns, function(vpn)
    table.insert(vpnSubmenu, {
      title = vpn,
      fn = function() cache.vpnSettings[bssid] = vpn end,
      checked = VPN == vpn
    })
  end)

  cache.menuItem:setMenu({
    { title = headerText, disabled = true },
    { title = 'Connect', menu = vpnSubmenu },
    {
      title = VPN and 'Disconnect' or 'Disconnected',
      fn = function() cache.vpnSettings[bssid] = false end,
      checked = not VPN
    },
    { title = '-' },
    {
      title = 'Open VPN Preferences...',
      fn = openVPNSettings
    }
  })

  cache.menuItem:setIcon(isConnected and iconOn or iconOff)
end

local checkTrustedNetwork = function()
  local currrentNetwork = hs.wifi.currentNetwork()
  local bssid           = currentBssid()

  if not currrentNetwork then return end

  local isInTrustedNetwork = hs.fnutils.some(controlplane.trustedNetworks, function(network)
    return network == currrentNetwork
  end)

  if not isInTrustedNetwork and not cache.vpnSettings[bssid] then
    cache.vpnSettings[bssid] = controlplane.vpns[1]
  end
end

module.start = function()
  -- create menu icon
  cache.menuItem = hs.menubar.new()

  -- setup
  checkTrustedNetwork()
  updateMenuItem(isVPNConnected(currentVPN()))

  -- watch for updates - would be great if we could get notifications on VPN change
  cache.timerHandle = hs.timer.doEvery(1, function()
    local isOnline       = hs.network.reachability.internet():status() == 2
    local updateMenu     = false
    local VPN            = currentVPN()
    local isAnyConnected = isAnyVPNConnected()
    local isConnected    = isVPNConnected(VPN)

    if not isOnline then
      return
    end

    if isAnyConnected and not VPN then
      disconnectAllVPNs()
      updateMenu = true
    end

    if not isConnected and VPN then
      disconnectAllVPNs()
      connectVPN(VPN)
      updateMenu = true
    end

    if updateMenu then
      updateMenuItem(isConnected)
    end

    -- -- we don't care about VPN if there's no internet connection
    -- if not isOnline then
    --   updateMenuItem(false)
    --   return
    -- end

    -- -- update menu on online state change
    -- if cache.wasOnline ~= isOnline or cache.wasConnected ~= isConnected then
    --   updateMenu = true
    -- end

    -- -- connect on VPN change
    -- if cache.lastVPN ~= VPN then
    --   disconnectAllVPNs()
    --   connectVPN(VPN)
    --   updateMenu = true
    -- end

    -- -- connect if not connected and should be
    -- if isOnline and not (cache.connecting or isConnected) then
    --   connectVPN(VPN)
    --   updateMenu = true
    -- end

    -- -- disconnected if connected and shouldn't be
    -- if isOnline and isConnected and not VPN then
    --   disconnectAllVPNs()
    --   updateMenu = true
    -- end

    -- -- update menu if needed
    -- if updateMenu then
    --   updateMenuItem(isConnected)
    -- end

    -- -- save previous status
    -- cache.wasOnline    = isOnline
    -- cache.wasConnected = isConnected
    -- cache.lastBssid    = bssid
    -- cache.lastVPN      = VPN
  end)

  -- auto connect on untrusted networks
  cache.wifiWatcher = hs.wifi.watcher.new(checkTrustedNetwork):start()
end

module.stop = function()
  -- store last vpn status
  hs.settings.set('vpnSettings', cache.vpnSettings)

  cache.timerHandle:stop()
  cache.wifiWatcher:stop()
end

return module
