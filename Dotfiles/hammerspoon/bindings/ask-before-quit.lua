local allWindowsCount = require('ext.application').allWindowsCount

local cache  = { bindings = {} }
local module = { cache = cache }

-- ask before quitting app when there are multiple windows
local askBeforeQuitting = function(appName, options)
  local enabled = options.enabled or false

  if not enabled and cache.bindings[appName] then
    cache.bindings[appName]:disable()
    return
  end

  if cache.bindings[appName] then
    cache.bindings[appName]:enable()
  else
    cache.bindings[appName] = hs.hotkey.bind({ 'cmd' }, 'q', function()
      local windowsCount = allWindowsCount(appName)

      if windowsCount > 1 then
        -- for some reason this is way more responsive than calling hs.applescript...
        hs.task.new(os.getenv('HOME') .. '/.hammerspoon/assets/ask-before-quit.scpt', nil, { appName }):start()
      else
        hs.application.find(appName):kill()
      end
    end)
  end
end

module.start = function()
  cache.filter = hs.window.filter.new(bindings.askBeforeQuitApps)

  cache.filter:subscribe({
    hs.window.filter.windowFocused,
    hs.window.filter.windowUnfocused
  }, function(_, appName, event)
    askBeforeQuitting(appName, { enabled = (event == "windowFocused") })
  end)
end

module.stop = function()
  cache.filter:unsubscribeAll()
end

return module
