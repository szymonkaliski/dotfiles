local highlightWindow = require('ext.drawing').highlightWindow

local cache = {
  focusFilter = hs.window.filter.new():setCurrentSpace(true):setDefaultFilter();
}

local module = { cache = cache }

function focusAndHighlight(direction)
  return function()
    cache.focusFilter[direction](cache.focusFilter)
    highlightWindow()
  end
end

module.start = function()
  function bind(mod, key, fn)
    hs.hotkey.bind(mod, key, fn, nil, fn)
  end

  hs.fnutils.each({
    { key = 'h', dir = 'focusWindowWest'  },
    { key = 'j', dir = 'focusWindowSouth' },
    { key = 'k', dir = 'focusWindowNorth' },
    { key = 'l', dir = 'focusWindowEast'  }
  }, function(object)
    bind({ 'ctrl', 'alt' }, object.key, focusAndHighlight(object.dir))
  end)
end

module.stop = function()
end

return module;
