local module = {}

local activateFrontmost = require('ext.application').activateFrontmost
local bluetooth         = require('hs._asm.undocumented.bluetooth')

-- show notification center
-- NOTE: you can do that from Settings > Keyboard > Mission Control
module.toggleNotificationCenter = function()
  hs.applescript.applescript([[
    tell application "System Events" to tell process "SystemUIServer"
      click menu bar item "Notification Center" of menu bar 2
    end tell
  ]])
end

module.isDNDEnabled = function()
  -- check if enabled
  local _, res = hs.applescript.applescript([[
    tell application "System Events"
      tell application process "SystemUIServer"
        tell (every menu bar whose title of menu bar item 1 contains "Notification")
          return title of (1st menu bar item whose title contains "Notification")
        end tell
      end tell
    end tell
  ]])

  local isEnabled = string.match(res[1], 'Do Not Disturb')
  return isEnabled
end

module.toggleDND = function()
  local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/notification-center.png'

  local isEnabled = module.isDNDEnabled()
  local afterTime = isEnabled and 0.0 or 4.0

  -- is not enabled, will be enabled
  if not isEnabled then
    hs.notify.new({
      title        = 'Do Not Disturb',
      subTitle     = 'Enabled',
      contentImage = imagePath
    }):send()
  end

  -- toggle, wait a bit if we've send notification
  hs.timer.doAfter(afterTime, function()
    hs.applescript.applescript([[
      tell application "System Events"
        option key down

        tell application process "SystemUIServer"
          tell (every menu bar whose title of menu bar item 1 contains "Notification")
            click (1st menu bar item whose title contains "Notification")
          end tell
        end tell

        option key up
      end tell
    ]])

    -- is enabled, was disabled
    if isEnabled then
      hs.notify.new({
        title        = 'Do Not Disturb',
        subTitle     = 'Disabled',
        contentImage = imagePath
      }):send()
    end
  end)
end

module.toggleBluetooth = function()
  local newStatus = not bluetooth.power()

  bluetooth.power(newStatus)

  local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/bluetooth.png'

  hs.notify.new({
    title        = 'Bluetooth',
    subTitle     = 'Power: ' .. (newStatus and 'On' or 'Off'),
    contentImage = imagePath
  }):send()
end

module.toggleWiFi = function()
  local newStatus = not hs.wifi.interfaceDetails().power

  hs.wifi.setPower(newStatus)

  local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/airport.png'

  hs.notify.new({
    title        = 'Wi-Fi',
    subTitle     = 'Power: ' .. (newStatus and 'On' or 'Off'),
    contentImage = imagePath
  }):send()
end

module.toggleConsole = function()
  hs.toggleConsole()
  activateFrontmost()
end

module.displaySleep = function()
  hs.task.new('/usr/bin/pmset', nil, { 'displaysleepnow' }):start()
end

module.reloadHS = function()
  hs.reload()

  hs.notify.new({
    title    = 'Hammerspoon',
    subTitle = 'Reloaded'
  }):send()
end

return module

