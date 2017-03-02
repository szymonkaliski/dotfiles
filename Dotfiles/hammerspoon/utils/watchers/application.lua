local application = require('ext.application')

local cache  = {}
local module = { cache = cache }

module.start = function()
  cache.filter = hs.window.filter.new({ 'Safari', 'Google Chrome' })

  cache.filter:subscribe({
    hs.window.filter.windowFocused,
    hs.window.filter.windowUnfocused
  }, function(_, appName, event)
    application.askBeforeQuitting(appName, { enabled = (event == "windowFocused") })
  end)
end

module.stop = function()
  cache.filter:unsubscribe()
end

return module
