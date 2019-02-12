-- global stuff
require('console').init()
require('overrides').init()

-- ensure IPC is there
hs.ipc.cliInstall()

-- lower logging level for hotkeys
require('hs.hotkey').setLogLevel("warning")

-- requires
bindings                    = require('bindings')
controlplane                = require('utils.controlplane')
watchables                  = require('utils.watchables')
watchers                    = require('utils.watchers')
window                      = require('ext.window')
wm                          = require('utils.wm')

-- hs
hs.window.animationDuration = 0.0

hs.hints.fontName           = 'Helvetica-Bold'
hs.hints.fontSize           = 22
hs.hints.showTitleThresh    = 0
hs.hints.hintChars          = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }

-- extensions
window.highlightBorder      = false
window.highlightMouse       = true
window.historyLimit         = 0

-- controlplane
controlplane.enabled        = { 'automount' }

-- watchers
watchers.enabled            = { 'urlevent' }
watchers.urlPreference      = { 'Safari', 'Google Chrome' }

-- bindings
bindings.enabled            = { 'ask-before-quit', 'block-hide', 'ctrl-esc', 'f-keys', 'focus', 'global', 'tiling', 'term-ctrl-i', 'viscosity' }
bindings.askBeforeQuitApps  = { 'Safari', 'Google Chrome' }

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
