local module      = {}
local window      = require('ext.window')
local application = require('ext.application')

-- simple unpack clone
function unpack(t, i)
  i = i or 1
  if t[i] ~= nil then
    return t[i], unpack(t, i+1)
  end
end

-- apply function to a window with optional params, saving it's position for restore
local doWin = function(fn, options, ...)
  local win  = hs.window.frontmostWindow()
  local args = ...

  local allowFullscreen = options and options.allowFullscreen

  if args == nil and options then
    args = options
  end

  if win and (allowFullscreen or not win:isFullScreen()) then
    -- persist position only if we are not already undo/redo/saving
    if fn ~= window.persistPosition then
      window.persistPosition(win, 'save')
    end

    -- finally call function on window with arguments
    fn(win, args)
  end
end

-- helper for simple hotkey binding
local bindWin = function(fn, options, ...)
  local args = unpack({ ... })
  return function() doWin(fn, options, args) end
end

-- helper for appling function to a window with a timer
local timeWin = function(fn, options, ...)
  local args = unpack({ ... })
  return hs.timer.new(0.05, function() doWin(fn, options, args) end)
end

-- helper for cycling arguments with reset time
local cycleWin = function(fn, ...)
  local args          = { ... }
  local cycles        = args[2]
  local resetInterval = 1
  local lastCycle     = hs.timer.secondsSinceEpoch()
  local cycleIndex    = 1

  return function()
    local now = hs.timer.secondsSinceEpoch()

    if (now - lastCycle) > resetInterval then
      cycleIndex = 1
    else
      cycleIndex = (cycleIndex + 1) > #cycles and 1 or cycleIndex + 1
    end

    lastCycle = now

    doWin(fn, { args[1], cycles[cycleIndex] })
  end
end

-- keyboard modifiers for bindings
local mod = {
  cc  = { 'cmd', 'ctrl'         },
  ca  = { 'cmd', 'alt'          },
  cac = { 'cmd', 'alt', 'ctrl'  },
  cas = { 'cmd', 'alt', 'shift' }
}

module.start = function()
  -- basic bindings
  hs.fnutils.each({
    { key = 'c',     mod = mod.cc,  fn = bindWin(window.center)                                          },
    { key = 'z',     mod = mod.cc,  fn = bindWin(window.fullscreen)                                      },
    { key = 's',     mod = mod.cc,  fn = bindWin(window.persistPosition, 'save')                         },
    { key = 'u',     mod = mod.cc,  fn = bindWin(window.persistPosition, 'undo')                         },
    { key = 'r',     mod = mod.cc,  fn = bindWin(window.persistPosition, 'redo')                         },
    { key = 'tab',   mod = mod.cc,  fn = bindWin(window.cycleWindows, { allowFullscreen = true }, false) },
    { key = 'tab',   mod = mod.ca,  fn = bindWin(window.cycleWindows, { allowFullscreen = true }, true)  },
    { key = '/',     mod = mod.cc,  fn = application.toggleConsole                                       },
    { key = 'space', mod = mod.cac, fn = hs.hints.windowHints                                            }
  }, function(object)
    hs.hotkey.bind(object.mod, object.key, object.fn)
  end)

  -- arrow bindings
  hs.fnutils.each({ 'up', 'down', 'left', 'right' }, function(direction)
    local nudge = timeWin(window.nudge, direction)
    local pushAndSendCycled = cycleWin(window.pushAndSend, direction, { 1 / 2, 1 / 3, 2 / 3 })

    -- hs.hotkey.bind(mod.cc,  direction, bindWin(window.pushAndSend, direction))
    hs.hotkey.bind(mod.cc,  direction, function() pushAndSendCycled() end)
    hs.hotkey.bind(mod.ca,  direction, function() nudge:start() end, function() nudge:stop() end)
    hs.hotkey.bind(mod.cac, direction, bindWin(window.send, direction))
    hs.hotkey.bind(mod.cas, direction, bindWin(window.throwToScreen, direction))
  end)

  -- arrow bindings with 'fn'
  hs.fnutils.each({
    { key = 'pageup',   direction = 'up'    },
    { key = 'pagedown', direction = 'down'  },
    { key = 'home',     direction = 'left'  },
    { key = 'end',      direction = 'right' }
  }, function(object)
    hs.hotkey.bind(mod.cc, object.key, bindWin(window.focus, { allowFullscreen = true }, object.direction))
  end)

  -- move window to left/right space with 'fn'
  hs.fnutils.each({
    { key = 'home', direction = 'left'  },
    { key = 'end',  direction = 'right' }
  }, function(object)
    hs.hotkey.bind(mod.ca, object.key, nil, bindWin(window.moveToSpace, object.direction))
  end)

  -- move window directly to space by number
  -- NOTE: binding this to pressedFn doesn't work!
  -- NOTE: this is broken if we are using spaces/betterswitch
  -- hs.fnutils.each({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, function(space)
  --   hs.hotkey.bind(mod.cac, space, nil, bindWin(window.moveToSpace, space))
  -- end)

  -- set window sizes
  hs.fnutils.each({
    { key = '1', w = 1420, h = 940 },
    { key = '2', w = 980,  h = 920 },
    { key = '3', w = 800,  h = 880 },
    { key = '4', w = 800,  h = 740 },
    { key = '5', w = 700,  h = 740 },
    { key = '6', w = 850,  h = 620 },
    { key = '7', w = 770,  h = 470 }
  }, function(object)
    hs.hotkey.bind(mod.cc, object.key, bindWin(window.setSize, { w = object.w, h = object.h }))
  end)

  -- grow/shrink windows
  hs.fnutils.each({
    { key = '=', mod =  window.margin },
    { key = '-', mod = -window.margin }
  }, function(object)
    local resize = timeWin(window.setSize, { mod = object.mod })

    hs.hotkey.bind(mod.cc, object.key, function() resize:start() end, function() resize:stop() end)
  end)

  -- launch and focus applications
  hs.fnutils.each({
    { key = 'b', apps = { 'Safari', 'Google Chrome' } },
    { key = 'c', apps = { 'Calendar'                } },
    { key = 'f', apps = { 'Finder', 'ForkLift'      } },
    { key = 'm', apps = { 'Messages', 'FaceTime'    } },
    { key = 'n', apps = { 'Notational Velocity'     } },
    { key = 'r', apps = { 'Reminders'               } },
    { key = 's', apps = { 'Slack', 'Skype'          } },
    { key = 't', apps = { 'iTerm2', 'Terminal'      } },
    { key = 'v', apps = { 'MacVim'                  } },
    { key = 'x', apps = { 'Xcode'                   } }
  }, function(object)
    hs.hotkey.bind(mod.cac, object.key, function() application.smartLaunchOrFocus(object.apps) end)
  end)
end

-- TODO: stop all bindings?
module.stop = function()
end

return module
