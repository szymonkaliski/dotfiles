bindings                    = require('bindings')
controlplane                = require('utils.controlplane')
notify                      = require('utils.notify')
spaces                      = require('utils.spaces')
watchers                    = require('utils.watchers')
window                      = require('ext.window')

-- extensions
window.fixEnabled           = false
window.fullFrame            = true
window.historyLimit         = 20
window.margin               = 6

-- hs
hs.window.animationDuration = 0.1
hs.hints.fontName           = 'Helvetica-Bold'
hs.hints.fontSize           = 22
hs.hints.showTitleThresh    = 0
hs.hints.hintChars          = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }

-- controlplane
controlplane.enabled        = { 'automount', 'bluetooth', 'displays', 'persistvpn' }
controlplane.afpVolumes     = { 'afp://Stelis._afpovertcp._tcp.local/' }
controlplane.homeNetwork    = 'Skynet 5G'

-- notifications
notify.enabled              = { 'battery', 'online', 'wifi' }

-- spaces
spaces.enabled              = { 'betterswitch' }
spaces.dots = {
  alpha                     = 0.15,
  selectedAlpha             = 0.45,
  distance                  = 16,
  size                      = 8
}

-- watchers
watchers.enabled            = { 'application', 'reload', 'urlevent' }
watchers.urlPreference      = { 'Safari', 'Google Chrome' }

-- start
hs.fnutils.each({
  bindings,
  controlplane,
  notify,
  spaces,
  watchers
}, function(module) module.start() end)

-- ensure IPC
hs.ipc.cliInstall()
