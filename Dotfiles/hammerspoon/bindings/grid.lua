local module = {}
local window = require('ext.window')

-- simple unpack clone
local unpack = function(t, i)
  i = i or 1
  if t[i] ~= nil then
    return t[i], unpack(t, i + 1)
  end
end

-- apply function to a window with optional params, saving it's position for restore
local doWin = function(fn, options)
  return function()
    local win = hs.window.frontmostWindow()

    local allowFullscreen = options and options.allowFullscreen

    if win and (allowFullscreen or not win:isFullScreen()) then
      -- persist position only if we are not already undo/redo/saving
      if fn ~= window.persistPosition then
        window.persistPosition(win, 'save')
      end

      -- finally call function on window with arguments
      fn(win, options)
    end
  end
end

module.start = function()
  local bind = function(mod, key, fn)
    hs.hotkey.bind(mod, key, fn, nil, fn)
  end

  hs.fnutils.each({
    { key = 'h', fn = hs.grid.pushWindowLeft       },
    { key = 'j', fn = hs.grid.pushWindowDown       },
    { key = 'k', fn = hs.grid.pushWindowUp         },
    { key = 'l', fn = hs.grid.pushWindowRight      },

    { key = '[', fn = hs.grid.pushWindowNextScreen },
    { key = ']', fn = hs.grid.pushWindowPrevScreen },

    { key = ',', fn = hs.grid.resizeWindowThinner  },
    { key = '.', fn = hs.grid.resizeWindowWider    },

    { key = '=', fn = hs.grid.resizeWindowTaller   },
    { key = '-', fn = hs.grid.resizeWindowShorter  },

    { key = 'z', fn = hs.grid.maximizeWindow       },
  }, function(object)
    bind({ 'ctrl', 'shift' }, object.key, doWin(object.fn))
  end)

  -- hs.fnutils.each({
  --   { key = 'u', fn = window.persistPosition, args = 'undo' },
  --   { key = 'r', fn = window.persistPosition, args = 'redo' }
  -- }, function(object)
  --   bind(object.key, doWin(object.fn, object.args))
  -- end)

  hs.fnutils.each({
    { key = '1', geom = { x = 0, y = 0, w = 16, h = 12 } },
    { key = '2', geom = { x = 1, y = 0, w = 14, h = 12 } },
    { key = '3', geom = { x = 2, y = 0, w = 12, h = 12 } },
    { key = '4', geom = { x = 3, y = 1, w = 10, h = 10 } },
    { key = '5', geom = { x = 4, y = 2, w = 8,  h = 8  } },

    { key = '6', geom = { x = 0, y = 0, w = 8, h = 12 } },
    { key = '7', geom = { x = 8, y = 0, w = 8, h = 12 } },

    { key = '8', geom = { x = 0, y = 2, w = 8, h = 8 } },
    { key = '9', geom = { x = 8, y = 2, w = 8, h = 8 } }
  }, function(object)
    bind({ 'ctrl', 'shift' }, object.key, doWin(hs.grid.set, object.geom))
  end)
end

module.stop = function()
end

return module
