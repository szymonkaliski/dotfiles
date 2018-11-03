local module = {}

local grid               = require('ext.grid')
local smartLaunchOrFocus = require('ext.application').smartLaunchOrFocus
local system             = require('ext.system')
local window             = require('ext.window')

-- local toggleCaffeine = require('utils.controlplane.caffeine').toggleCaffeine
-- local toggleVPN      = require('utils.controlplane.persistvpn').toggleVPN

module.start = function()
  -- ultra bindings
  local ultra = { 'ctrl', 'alt', 'cmd' }

  -- ctrl + tab as alternative to cmd + tab
  hs.hotkey.bind({ 'ctrl' }, 'tab', window.windowHints)

  -- force paste (sometimes cmd + v is blocked)
  hs.hotkey.bind({ 'cmd', 'alt', 'shift' }, 'v', function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
  end)

  -- toggles
  hs.fnutils.each({
    -- { key = 'c', fn = toggleCaffeine      },
    -- { key = 'v', fn = toggleVPN           },
    { key = '/', fn = system.toggleConsole   },
    { key = 'b', fn = system.toggleBluetooth },
    { key = 'd', fn = system.toggleDND       },
    { key = 'g', fn = grid.toggleGrid        },
    { key = 'q', fn = system.displaySleep    },
    { key = 'r', fn = system.reloadHS        },
    { key = 'w', fn = system.toggleWiFi      },
  }, function(object)
    hs.hotkey.bind(ultra, object.key, object.fn)
  end)

  -- apps
  hs.fnutils.each({
    { key = 'return', apps = { 'iTerm2'                  } },
    { key = 'space',  apps = { 'Safari', 'Google Chrome' } },
    { key = ',',      apps = { 'System Preferences'      } }
  }, function(object)
    hs.hotkey.bind(ultra, object.key, function() smartLaunchOrFocus(object.apps) end)
  end)

  -- mindmapping my[s]elf
  hs.hotkey.bind(ultra, 's', function()
    hs.execute('open /Users/szymon/Library/Mobile\\ Documents/W6L39UYL6Z~com~mindnode~MindNode/Documents/Self.mindnode')
  end)
end

module.stop = function()
end

return module
