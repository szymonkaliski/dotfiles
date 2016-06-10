bindings                     = require('bindings')
controlplane                 = require('utils.controlplane')
notify                       = require('utils.notify')
spaces                       = require('utils.spaces')
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
controlplane.enabled         = { 'automount', 'bluetooth', 'persistvpn' }
controlplane.trustedNetworks = { 'Skynet', 'Skynet 5G' }
controlplane.vpns            = { 'VPN PIA', 'VPN STL' }

-- notifications
notify.enabled               = { 'battery', 'online', 'wifi' }

-- spaces
spaces.enabled               = { 'betterswitch' }

-- watchers
watchers.enabled             = { 'autogrid', 'application', 'reload', 'urlevent' }
watchers.urlPreference       = { 'Safari', 'Google Chrome' }

-- start modules
hs.fnutils.each({
  bindings,
  controlplane,
  notify,
  spaces,
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
    spaces,
    watchers
  }, function(module) module.stop() end)
end

-- ensure IPC is there
hs.ipc.cliInstall()
