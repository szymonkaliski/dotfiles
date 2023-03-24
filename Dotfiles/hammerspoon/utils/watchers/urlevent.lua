local template = require('ext.template')
local module   = {}

-- watch for http and https events and open in currently running browser
-- click with 'cmd' to open in background, otherwise opens with focus
module.start = function()
  hs.urlevent.setDefaultHandler('http')

  hs.urlevent.httpCallback = function(_, _, _, fullURL)
    local modifiers          = hs.eventtap.checkKeyboardModifiers()
    local shouldFocusBrowser = not modifiers['cmd']
    local currentApp         = hs.application.frontmostApplication()

    -- browsers running anywhere
    local runningBrowser = hs.fnutils.find(config.apps.browsers, function(browserName)
      return hs.application.get(browserName) ~= nil
    end)

    -- applications on current space
    local spaceApps = hs.fnutils.map(hs.window.allWindows(), function(win)
      return win:application():name()
    end)

    -- browser windows on current space
    local spaceBrowsers = hs.fnutils.filter(config.apps.browsers, function(browserApp)
      return hs.fnutils.contains(spaceApps, browserApp)
    end)

    local hasBrowserWindows = #spaceBrowsers > 0
    local hasRunningBrowser = runningBrowser ~= nil
    local browserName = ""

    if hasBrowserWindows then
      browserName = spaceBrowsers[1]
    elseif hasRunningBrowser then
      browserName = runningBrowser
    else
      browserName = config.apps.browsers[1]
    end

    if browserName == "Google Chrome" then
      -- for whatever reason Google Chrome is not liking applescript anymore, too lazy to debug
      -- luckily Chrome behaves correctly when opening tabs (is not jumping to some other space),
      -- so this can stay for now:
      hs.urlevent.openURLWithBundle(fullURL, "com.google.Chrome")
    else
      local newDocument = ""
      local newTab      = ""

      if hasBrowserWindows then
        -- if we have browser windows, open the url in new tab of the first window we can find
        newTab = [[
          tell window 1
            set newTab to make new tab
            set URL of newTab to "]] .. fullURL .. [["
            set current tab to newTab
          end tell
        ]]
      else
        -- otherwise create a new document - this opens browser on this desktop instead of switching spaces
        newDocument = [[
          make new document with properties { URL: "]] .. fullURL .. [[" }
        ]]
      end

      local script = template([[
        tell application "{BROWSER_NAME}"
          {ACTIVATE}
          {NEW_DOCUMENT}
          {NEW_TAB}
        end tell
      ]], {
        ACTIVATE     = shouldFocusBrowser and 'activate' or '',
        BROWSER_NAME = browserName,
        NEW_DOCUMENT = newDocument,
        NEW_TAB      = newTab,
      })

      hs.applescript.applescript(script)

      -- focus back the current app
      if not shouldFocusBrowser and not currentApp:isFrontmost() then
        currentApp:activate()
      end
    end
  end
end

module.stop = function()
  hs.urlevent.httpCallback = nil
end

return module
