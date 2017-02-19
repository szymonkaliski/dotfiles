local highlightWindow = require('ext.drawing').highlightWindow

local cache = {
  focusFilter = hs.window.filter.new():setCurrentSpace(true):setDefaultFilter();
}

local module = { cache = cache }

local focusAndHighlight = function(cmd)
  return function()
    cache.focusFilter[cmd](cache.focusFilter, nil, false, true)

    highlightWindow()
  end
end

module.start = function()
  function bind(mod, key, fn)
    hs.hotkey.bind(mod, key, fn, nil, fn)
  end

  hs.fnutils.each({
    { key = 'h', cmd = 'focusWindowWest'  },
    { key = 'j', cmd = 'focusWindowSouth' },
    { key = 'k', cmd = 'focusWindowNorth' },
    { key = 'l', cmd = 'focusWindowEast'  }
  }, function(object)
    bind({ 'ctrl', 'alt' }, object.key, focusAndHighlight(object.cmd))
  end)
end

module.stop = function()
end

return module;
