local cache  = {}
local module = { cache = cache }

module.start = function(_)
  -- we only care about "normal" windows for snapping
  cache.filter = hs.window.filter.new(function(win)
    return win:isStandard() and win:isVisible() and not win:isFullScreen()
  end)

  -- auto snap any new "normal" window
  cache.filter:subscribe({ hs.window.filter.windowCreated }, function(win, _, _)
    hs.grid.snap(win)
  end)

  -- snap all windows on screen change
  cache.watcher = hs.screen.watcher.new(function()
    hs.fnutils.map(hs.window.visibleWindows(), hs.grid.snap)
  end):start()
end

module.stop = function()
  cache.filter:unsubscribe()
  cache.watcher:stop()
end

return module
