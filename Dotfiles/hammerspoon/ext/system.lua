local activateFrontmost = require('ext.application').activateFrontmost
local bluetooth         = require('hs._asm.undocumented.bluetooth')
local capitalize        = require('ext.utils').capitalize
local template          = require('ext.template')

local module = {}

-- show notification center
-- NOTE: you can do that from Settings > Keyboard > Mission Control
module.toggleNotificationCenter = function()
  hs.applescript.applescript([[
    tell application "System Events" to tell process "SystemUIServer"
      click menu bar item "Notification Center" of menu bar 2
    end tell
  ]])
end

-- DND is not working on Big Sur anymore

-- module.isDNDEnabled = function()
--   local _, _, _, rc = hs.execute('do-not-disturb status | grep -q "on"', true)
--   return rc == 0
-- end

-- module.toggleDND = function()
--   local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/notification-center.png'

--   local isEnabled = module.isDNDEnabled()
--   local afterTime = isEnabled and 0.0 or 6.0

--   -- is not enabled, will be enabled
--   if not isEnabled then
--     hs.notify.new({
--       title        = 'Do Not Disturb',
--       subTitle     = 'Enabled',
--       contentImage = imagePath
--     }):send()
--   end

--   -- toggle, wait a bit if we've send notification
--   hs.timer.doAfter(afterTime, function()
--     hs.execute('do-not-disturb ' .. (isEnabled == true and 'off' or 'on'), true)

--     -- is enabled, was disabled
--     if isEnabled then
--       hs.notify.new({
--         title        = 'Do Not Disturb',
--         subTitle     = 'Disabled',
--         contentImage = imagePath
--       }):send()
--     end
--   end)
-- end

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

module.isDarkModeEnabled = function()
  local _, res = hs.osascript.javascript([[
    Application("System Events").appearancePreferences.darkMode()
  ]])

  return res == true -- getting nil here sometimes
end

module.setTheme = function(theme)
  hs.osascript.javascript(template([[
    var systemEvents = Application("System Events");
    var alfredApp = Application("Alfred 5");

    ObjC.import("stdlib");

    systemEvents.appearancePreferences.darkMode = {DARK_MODE};

    // has to be done this way so template function works, lol
    alfredApp && alfredApp.setTheme("{ALFRED_THEME}");
  ]], {
    ALFRED_THEME = 'Mojave ' .. capitalize(theme),
    DARK_MODE = theme == 'dark' and 'true' or 'false',
  }))
end

module.toggleTheme = function()
  local isDarkModeEnabled = module.isDarkModeEnabled()

  module.setTheme(isDarkModeEnabled and 'light' or 'dark')

  local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/theme.png'

  hs.notify.new({
    title        = 'Theme',
    subTitle     = 'Switched to: ' .. (isDarkModeEnabled and 'Light' or 'Dark'),
    contentImage = imagePath
  }):send()
end

module.restartHammerspoon = function()
  -- hs.relaunch()
  hs.reload()
end

return module

