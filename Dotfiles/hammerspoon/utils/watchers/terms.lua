local noAnim = require('ext.utils').noAnim

local cache  = {}
local module = { cache = cache }

module.start = function(_)
  cache.filter = hs.window.filter.new({ 'Hyper', 'Terminal', 'iTerm2' })

  cache.filter:subscribe({ hs.window.filter.windowCreated }, function(win)
    noAnim(function() hs.grid.set(win, { x = 4, y = 2, w = 8, h = 8 }) end)
  end)
end

module.stop = function()
  cache.filter:unsubscribe()
end

return module
