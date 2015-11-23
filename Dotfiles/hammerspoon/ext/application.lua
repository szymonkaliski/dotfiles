local cache = {
  bindings    = {},
  launchTimer = nil
}

local log = hs.logger.new('application', 'debug')

local module = {}

-- activate frontmost window if exists
function module.activateFrontmost()
  local frontmostWindow = hs.window.frontmostWindow()
  if frontmostWindow then frontmostWindow:focus() end
end

-- toggle hammerspoon console and refocus last window
function module.toggleConsole()
  hs.toggleConsole()
  module.activateFrontmost()
end

-- force application launch or focus
function module.forceLaunchOrFocus(appName)
  -- first focus with hammerspoon
  hs.application.launchOrFocus(appName)

  -- clear timer if exists
  if cache.launchTimer then cache.launchTimer:stop() end

  -- wait 500ms for window to appear and try hard to show the window
  cache.launchTimer = hs.timer.doAfter(0.5, function()
    local frontmostApp     = hs.application.frontmostApplication()
    local frontmostWindows = hs.fnutils.filter(frontmostApp:allWindows(), function(win) return win:isStandard() end)

    -- break if this app is not frontmost (when/why?)
    if frontmostApp:title() ~= appName then
      log.d('Expected app in front: ' .. appName .. ' got: ' .. frontmostApp:title())
      return
    end

    if #frontmostWindows == 0 then
      -- check if there's app name in window menu (Calendar, Messages, etc...)
      if frontmostApp:findMenuItem({ 'Window', appName }) then
        -- select it, usually moves to space with this window
        frontmostApp:selectMenuItem({ 'Window', appName })
      else
        -- otherwise send cmd-n to create new window
        hs.eventtap.keyStroke({ 'cmd' }, 'n')
      end
    end
  end)
end

-- smart app launch or focus or cycle windows
function module.smartLaunchOrFocus(launchApps)
  local frontmostWindow = hs.window.frontmostWindow()
  local runningApps     = hs.application.runningApplications()
  local runningWindows  = {}

  -- filter running applications by apps array
  local runningApps = hs.fnutils.map(launchApps, function(launchApp)
    return hs.application.get(launchApp)
  end)

  -- create table of sorted windows per application
  hs.fnutils.each(runningApps, function(runningApp)
    local standardWindows = hs.fnutils.filter(runningApp:allWindows(), function(win)
      return win:isStandard()
    end)

    -- sort by id, so windows don't jump randomly every time
    table.sort(standardWindows, function(a, b) return a:id() < b:id() end)

    -- concat with all running windows
    hs.fnutils.concat(runningWindows, standardWindows);
  end)

  if #runningApps == 0 then
    -- if no apps are running then launch first one in list
    module.forceLaunchOrFocus(launchApps[1])
  elseif #runningWindows == 0 then
    -- if some apps are running, but no windows - force create one
    module.forceLaunchOrFocus(runningApps[1]:title())
  else
    -- check if one of windows is already focused
    local currentIndex = hs.fnutils.indexOf(runningWindows, frontmostWindow)

    if not currentIndex then
      -- if none of them is selected focus the first one
      runningWindows[1]:focus()
    else
      -- otherwise cycle through all the windows
      local newIndex = currentIndex + 1
      if newIndex > #runningWindows then newIndex = 1 end

      runningWindows[newIndex]:focus()
    end
  end
end

-- count all windows on all spaces
function module.allWindowsCount(appName)
  local _, result = hs.applescript.applescript(string.gsub([[
    tell application "{APP_NAME}"
      count every window where visible is true
    end tell
  ]], '{(.-)}', { APP_NAME = appName }))

  return tonumber(result) or 0
end

-- quit app using applescript
-- faster than :kill() for some reason
function module.quit(appName)
  local _, result = hs.applescript.applescript(string.gsub([[
    tell application "{APP_NAME}"
      quit
    end tell
  ]], '{(.-)}', { APP_NAME = appName }))

  return result
end

-- ask before quitting app when there are multiple windows
function module.askBeforeQuitting(appName, enabled)
  if not enabled and cache.bindings[appName] then
    cache.bindings[appName]:disable()
    return
  end

  if cache.bindings[appName] then
    cache.bindings[appName]:enable()
  else
    cache.bindings[appName] = hs.hotkey.bind({ 'cmd' }, 'q', function()
      local windowsCount = module.allWindowsCount(appName)
      local shouldKill   = true

      if windowsCount > 1 then
        local _, result = hs.applescript.applescript(string.gsub([[
          tell application "{APP_NAME}"
            button returned of (display dialog "There are multiple windows opened: {NUM_WINDOWS}\nAre you sure you want to quit?" with icon 1 buttons {"Cancel", "Quit"} default button "Quit")
          end tell
        ]], '{(.-)}', { APP_NAME = appName, NUM_WINDOWS = windowsCount }))

        shouldKill = result == 'Quit'
      end

      if shouldKill then
        module.quit(appName)
      else
        module.activateFrontmost()
      end
    end)
  end
end

-- show notification center
function module.showNotificationCenter()
  hs.applescript.applescript([[
    tell application "System Events" to tell process "SystemUIServer"
      click menu bar item "Notification Center" of menu bar 2
    end tell
  ]])
end

return module
