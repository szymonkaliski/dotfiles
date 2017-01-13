-- override stuff
require('overrides').init()

-- requires
bindings                     = require('bindings')
controlplane                 = require('utils.controlplane')
notify                       = require('utils.notify')
specialkeys                  = require('utils.specialkeys')
watchers                     = require('utils.watchers')
window                       = require('ext.window')

-- extensions
window.fixEnabled            = false
window.fullFrame             = true
window.highlightEnabled      = false
window.historyLimit          = 50
window.margin                = 6

-- hs
hs.window.animationDuration  = 0.1

hs.hints.fontName            = 'Helvetica-Bold'
hs.hints.fontSize            = 22
hs.hints.showTitleThresh     = 0
hs.hints.hintChars           = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }

-- controlplane
controlplane.enabled         = { 'automount', 'bluetooth', 'displays' }
controlplane.trustedNetworks = { 'Skynet', 'Skynet 5G' }

-- notifications
notify.enabled               = { 'battery', 'online', 'wifi' }

-- special keys
specialkeys.enabled          = { 'brightness' }

-- watchers
watchers.enabled             = { 'autogrid', 'application', 'reload', 'terms', 'urlevent' }
watchers.urlPreference       = { 'Safari', 'Google Chrome' }

-- start modules
hs.fnutils.each({
  bindings,
  controlplane,
  notify,
  specialkeys,
  watchers
}, function(module) module.start() end)

-- stop modules on shutdown
hs.shutdownCallback = function()
  -- save window positions in hs.settings
  window.persistPosition('store')

  -- stop modules
  hs.fnutils.each({
    bindings,
    controlplane,
    notify,
    specialkeys,
    watchers
  }, function(module) module.stop() end)
end

-- ensure IPC is there
hs.ipc.cliInstall()
