local highlightWindow = require('ext.drawing').highlightWindow
local template        = require('ext.template')
local log             = hs.logger.new('application', 'debug')

local cache = {
  bindings    = {},
  launchTimer = nil
}

local module = { cache = cache }

-- activate frontmost window if exists
module.activateFrontmost = function()
  local frontmostWindow = hs.window.frontmostWindow()
  if frontmostWindow then frontmostWindow:focus() end
end

-- force application launch or focus
module.forceLaunchOrFocus = function(appName)
  -- first focus with hammerspoon
  hs.application.launchOrFocus(appName)

  -- clear timer if exists
  if cache.launchTimer then cache.launchTimer:stop() end

  -- wait 1s for window to appear and try hard to show the window
  cache.launchTimer = hs.timer.doAfter(1.0, function()
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
module.smartLaunchOrFocus = function(launchApps)
  local frontmostWindow = hs.window.frontmostWindow()
  local runningApps     = hs.application.runningApplications()
  local runningWindows  = {}

  launchApps = type(launchApps) == 'table' and launchApps or { launchApps }

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

    highlightWindow()
  end
end

-- count all windows on all spaces
module.allWindowsCount = function(appName)
  local _, result = hs.applescript.applescript(template([[
    tell application "{APP_NAME}"
      count every window where visible is true
    end tell
  ]], { APP_NAME = appName }))

  return tonumber(result) or 0
end

-- ask before quitting app when there are multiple windows
module.askBeforeQuitting = function(appName, options)
  local enabled = options.enabled or false

  if not enabled and cache.bindings[appName] then
    cache.bindings[appName]:disable()
    return
  end

  if cache.bindings[appName] then
    cache.bindings[appName]:enable()
  else
    cache.bindings[appName] = hs.hotkey.bind({ 'cmd' }, 'q', function()
      local windowsCount = module.allWindowsCount(appName)

      if windowsCount > 1 then
        -- for some reason this is way more responsive that calling to hs.applescript...
        hs.task.new(os.getenv('HOME') .. '/.hammerspoon/assets/ask-to-quit.scpt', nil, { appName }):start()
      else
        hs.application.find(appName):kill()
      end
    end)
  end
end

return module
