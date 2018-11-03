local drawBorder = require('ext.drawing').drawBorder

local cache  = {}
local module = { cache = cache }

module.start = function()
  cache.filter = hs.window.filter.new()
    :setCurrentSpace(true)
    :setDefaultFilter()
    :setOverrideFilter({
      fullscreen = false,
      allowRoles = { 'AXStandardWindow' }
    })

  cache.filter:subscribe({
    -- hs.window.filter.windowCreated,
    -- hs.window.filter.windowDestroyed,
    hs.window.filter.windowMoved,
    hs.window.filter.windowFocused,
    hs.window.filter.windowUnfocused,
  }, drawBorder)

  drawBorder()
end

module.stop = function()
  cache.filter:unsubscribeAll()
end

return module
