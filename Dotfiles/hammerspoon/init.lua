-- require modules into global namespace so they are available in the console
window                      = require('ext.window')
application                 = require('ext.application')
notify                      = require('utils.notify')
watchers                    = require('utils.watchers')
dots                        = require('utils.spaces.dots')

-- extension settings
window.margin               = 6
window.fullFrame            = true
window.fixEnabled           = false

-- spaces dots settings
dots.size                   = 8
dots.distance               = 16
dots.selectedAlpha          = 0.45
dots.alpha                  = 0.15
dots.start()

-- hs settings
hs.window.animationDuration = 0.15
hs.hints.fontName           = 'Helvetica-Bold'
hs.hints.fontSize           = 22
hs.hints.showTitleThresh    = 0
hs.hints.hintChars          = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }

-- start notifications
notify.enabled = { 'battery', 'online' }
notify.startAll()

-- start watchers
watchers.enabled = { 'application', 'automount', 'reload' }
watchers.startAll()

-- toggle hammerspoon console refocusing last window
function toggleConsole()
  hs.toggleConsole()
  application.activateFrontmost()
end

-- apply function to a window with optional params, saving it's position for restore
function doWin(fn, ...)
  local win = hs.window.frontmostWindow()
  local arg = ...

  if #arg == 1 then arg = arg[1] end

  if win and not win:isFullScreen() then
    window.persistPosition(win, 'save')
    fn(win, arg)
  end
end

-- helper for simple hotkey binding
function bindWin(fn, ...)
  local arg = { ... }
  return function() doWin(fn, arg) end
end

-- helper for appling function to a window with a timer
function timeWin(fn, ...)
  local arg = { ... }
  return hs.timer.new(0.05, function() doWin(fn, arg) end)
end

-- keyboard modifiers for bindings
local mod = {
  cc  = { 'cmd', 'ctrl'         },
  ca  = { 'cmd', 'alt'          },
  cac = { 'cmd', 'alt', 'ctrl'  },
  cas = { 'cmd', 'alt', 'shift' }
}

-- basic bindings
hs.fnutils.each({
  { key = 'c',     mod = mod.cc,  fn = bindWin(window.center)                    },
  { key = 'z',     mod = mod.cc,  fn = bindWin(window.fullscreen)                },
  { key = 's',     mod = mod.cc,  fn = bindWin(window.persistPosition, 'update') },
  { key = 'r',     mod = mod.cc,  fn = bindWin(window.persistPosition, 'load')   },
  { key = 'tab',   mod = mod.cc,  fn = bindWin(window.cycleWindows, false)       },
  { key = 'tab',   mod = mod.ca,  fn = bindWin(window.cycleWindows, true)        },
  { key = 'space', mod = mod.cac, fn = hs.hints.windowHints                          },
  { key = '/',     mod = mod.cac, fn = toggleConsole                                 }
}, function(object)
  hs.hotkey.bind(object.mod, object.key, object.fn)
end)

-- arrow bindings
hs.fnutils.each({ 'up', 'down', 'left', 'right' }, function(direction)
  local nudge = timeWin(window.nudge, direction)

  hs.hotkey.bind(mod.cc,  direction, bindWin(window.pushAndSend, direction))
  hs.hotkey.bind(mod.ca,  direction, bindWin(window.send, direction))
  hs.hotkey.bind(mod.cac, direction, function() nudge:start() end, function() nudge:stop() end)
  hs.hotkey.bind(mod.cas, direction, bindWin(window.throwToScreen, direction))
end)

-- arrow bindings with 'fn'
hs.fnutils.each({
  { key = 'pageup',   direction = 'up'    },
  { key = 'pagedown', direction = 'down'  },
  { key = 'home',     direction = 'left'  },
  { key = 'end',      direction = 'right' }
}, function(object)
  hs.hotkey.bind(mod.cc, object.key, bindWin(window.focus, object.direction))
end)

-- move window to left/right space with 'fn'
hs.fnutils.each({
  { key = 'home', direction = 'left'  },
  { key = 'end',  direction = 'right' }
}, function(object)
  hs.hotkey.bind(mod.ca, object.key, bindWin(window.moveToSpace, object.direction))
end)

-- move window directly to space by number
-- NOTE: binding this to pressedFn doesn't work!
hs.fnutils.each({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, function(space)
  hs.hotkey.bind(mod.cac, space, nil, bindWin(window.moveToSpace, space))
end)

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
