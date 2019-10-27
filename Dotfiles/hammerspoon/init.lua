-- global stuff
require('console').init()
require('overrides').init()

-- ensure IPC is there
hs.ipc.cliInstall()

-- lower logging level for hotkeys
require('hs.hotkey').setLogLevel("warning")

-- global config
config = {
  apps = {
    terms    = { 'kitty'                   },
    browsers = { 'Google Chrome', 'Safari' }
  },

  wm = {
    defaultDisplayLayouts = {
      ['Color LCD']    = 'monocle',
      ['DELL U3818DW'] = 'main-center'
    },

    displayLayouts = {
      ['Color LCD']    = { 'monocle', 'main-right', 'side-by-side'     },
      ['DELL U3818DW'] = { 'main-center', 'main-right', 'side-by-side' }
    }
  },

  window = {
    highlightBorder = false,
    highlightMouse  = true,
    historyLimit    = 0
  },

  network = {
    home = 'Skynet 5G'
  },

  homebridge = {
    studioSpeakers = { aid = 10, iid = 11, name = "Studio Speakers" },
    studioLights   = { aid = 9,  iid = 11, name = "Studio Lights"   },
    tvLights       = { aid = 6,  iid = 11, name = "TV Lights"       }
  }
}

-- requires
bindings                    = require('bindings')
controlplane                = require('utils.controlplane')
watchables                  = require('utils.watchables')
watchers                    = require('utils.watchers')
wm                          = require('utils.wm')

-- no animations
hs.window.animationDuration = 0.0

-- hints
hs.hints.fontName           = 'Helvetica-Bold'
hs.hints.fontSize           = 22
hs.hints.hintChars          = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }
hs.hints.iconAlpha          = 1.0
hs.hints.showTitleThresh    = 0

-- controlplane
controlplane.enabled        = { 'autohome', 'automount' }

-- watchers
watchers.enabled            = { 'urlevent' }
watchers.urlPreference      = config.apps.browsers

-- bindings
bindings.enabled            = { 'ask-before-quit', 'block-hide', 'ctrl-esc', 'f-keys', 'focus', 'global', 'tiling', 'term-ctrl-i', 'viscosity' }
bindings.askBeforeQuitApps  = config.apps.browsers

-- start/stop modules
local modules               = { bindings, controlplane, watchables, watchers, wm }

hs.fnutils.each(modules, function(module)
  if module then module.start() end
end)

-- stop modules on shutdown
hs.shutdownCallback = function()
  hs.fnutils.each(modules, function(module)
    if module then module.stop() end
  end)
end
