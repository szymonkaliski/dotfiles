local module = {}
local cache  = {}

local onlineWatcher = require('ext.onlinewatcher')
local notify        = require('utils.controlplane.notify')
local vpnTimeout    = 10 -- timeout before re-connecting to VPN

local iconOn = hs.image.imageFromASCII([[
.....................
.....................
..........3..........
.....................
.....2.........4.....
...1......c......5...
.......b.....d.......
.....................
......a.......e......
.....................
.....................
.......h.....f.......
....A.....g.....6....
.....................
........9...7........
.....................
..........8..........
.....................
.....................
.....................
]], {
  {
    lineWidth = 1.2,
    fillColor = { alpha = 0 }
  },
  { fillColor = { alpha = 1 } }
})

local iconOff = hs.image.imageFromASCII([[
.....................
.....................
..........3..........
.....................
.....2.........4.....
...1.............5...
.....................
.....................
.....................
.....................
.....................
.....................
....A...........6....
.....................
........9...7........
.....................
..........8..........
.....................
.....................
.....................
]], {
  {
    lineWidth = 1.2,
    fillColor = { alpha = 0 }
  }
})

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

  if isConnected then
    cache.menuItem
      :setTooltip('VPN connected')
      :setIcon(iconOn)
  elseif cache.connecting then
    cache.menuItem:setTooltip('VPN connecting...')
  else
    cache.menuItem
      :setTooltip('VPN disconnected')
      :setIcon(iconOff)
  end
end

module.start = function()
  -- start with vpn enabled status from saved setting
  local vpnEnabled = hs.settings.get('vpnEnabled')
  if vpnEnabled == nil then hs.settings.set('vpnEnabled', true) end

  -- create menu icon for quick toggle
  cache.menuItem = hs.menubar.new()

  cache.menuItem:setClickCallback(function()
    local vpnEnabled = hs.settings.get('vpnEnabled')
    hs.settings.set('vpnEnabled', not vpnEnabled)

    if vpnEnabled then
      connectVPN()
    else
      disconnectVPN()
    end
  end)

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
