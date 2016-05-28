local module = {}

local activateFrontmost = require('ext.application').activateFrontmost

-- show notification center
-- NOTE: you can do that from Settings > Keyboard > Mission Control
module.toggleNotificationCenter = function()
  hs.applescript.applescript([[
    tell application "System Events" to tell process "SystemUIServer"
      click menu bar item "Notification Center" of menu bar 2
    end tell
  ]])
end

module.toggleDoNotDisturb = function()
  local imagePath = os.getenv('HOME') .. '/.hammerspoon/assets/notification-center.png'

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

  local isEnabled = string.match(res, 'Do Not Disturb')
  local afterTime = isEnabled and 0.0 or 2.0

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

-- toggle hammerspoon console and refocus last window
module.toggleConsole = function()
  hs.toggleConsole()
  activateFrontmost()
end

return module

