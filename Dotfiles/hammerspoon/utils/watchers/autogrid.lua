local cache  = {}
local module = { cache = cache }

local snapWindow = function(win)
  local smallWin = { w = 300, h = 300 }
  local frame    = win:frame()

  if
    win:isStandard()
    and win:isVisible()
    and not win:isFullScreen()
    and frame.w > smallWin.w
    and frame.h > smallWin.h
  then
    hs.grid.snap(win)
  end
end

module.start = function(_)

  cache.filter = hs.window.filter.new(nil)

  cache.filter:subscribe({
    hs.window.filter.windowCreated,
    hs.window.filter.windowVisible,
    hs.window.filter.windowOnScreen,
    hs.window.filter.windowMoved
  }, snapWindow)

  cache.watcher = hs.screen.watcher.new(function()
    hs.fnutils.map(hs.window.visibleWindows(), snapWindow)
  end):start()
end

module.stop = function()
  cache.filter:unsubscribe()
  cache.watcher:stop()
end

return module
