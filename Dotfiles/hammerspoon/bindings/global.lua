local module = {}

local grid               = require('ext.grid')
local smartLaunchOrFocus = require('ext.application').smartLaunchOrFocus
local system             = require('ext.system')
local window             = require('ext.window')

module.start = function()
  -- ultra bindings
  local ultra = { 'ctrl', 'alt', 'cmd' }

  -- ctrl + tab as alternative to cmd + tab
  hs.hotkey.bind({ 'ctrl' }, 'tab', window.windowHints)

  -- ctrl + enter = escape
  -- on macbook I have capslock mapped to control with OSX preferences so I can easily escape with homerow
  -- helps to think ctrl + enter = done insterting with vim
  hs.hotkey.bind({ 'ctrl' }, 'return', function()
    hs.eventtap.event.newKeyEvent({}, 'escape', true):post()
    hs.eventtap.event.newKeyEvent({}, 'escape', false):post()
  end)

  -- force paste (sometimes cmd + v is blocked)
  hs.hotkey.bind({ 'cmd', 'shift' }, 'v', function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
  end)

  -- other things
  hs.fnutils.each({
    { key = '/',      fn = system.toggleConsole },
    { key = 'd',      fn = system.toggleDND     },
    { key = 'escape', fn = system.displaySleep  },
    { key = 'g',      fn = grid.toggleGrid      },
    { key = 'r',      fn = system.reloadHS      },
    { key = 'tab',    fn = window.windowHints   }
  }, function(object)
    hs.hotkey.bind(ultra, object.key, object.fn)
  end)

  -- smart apps
  hs.fnutils.each({
    { key = 'return', apps = { 'iTerm2'                  } },
    { key = 'space',  apps = { 'Safari', 'Google Chrome' } },
  }, function(object)
    hs.hotkey.bind(ultra, object.key, function() smartLaunchOrFocus(object.apps) end)
  end)
end

module.stop = function()
end

return module
