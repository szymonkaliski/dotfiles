-- require modules into global namespace so they are available in the console
betterswitch                 = require('utils.spaces.betterswitch')
bindings                     = require('bindings')
controlplane                 = require('utils.controlplane')
dots                         = require('utils.spaces.dots')
notify                       = require('utils.notify')
specialkeys                  = require('utils.specialkeys')
watchers                     = require('utils.watchers')
window                       = require('ext.window')

-- extension settings
window.fixEnabled            = false
window.fullFrame             = true
window.historyLimit          = 20
window.margin                = 6

-- spaces dots settings
dots.alpha                   = 0.15
dots.selectedAlpha           = 0.45
dots.distance                = 16
dots.size                    = 8

-- hs settings
hs.window.animationDuration  = 0.1
hs.hints.fontName            = 'Helvetica-Bold'
hs.hints.fontSize            = 22
hs.hints.showTitleThresh     = 0
hs.hints.hintChars           = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }

-- enable notifications
notify.enabled               = { 'battery', 'online', 'wifi' }

-- enable watchers
watchers.enabled             = { 'application', 'reload', 'urlevent' }
watchers.urlPreference       = { 'Safari', 'Google Chrome' }

-- enable and configure controlplane extensions
controlplane.enabled         = { 'audio', 'automount', 'bluetooth', 'displays', 'persistvpn' }
controlplane.audioPreference = { 'EDIROL FA-66 (3624)', 'Built-in Output' }

-- enable special keys functions
specialkeys.enabled          = { 'onlinespotify' }

-- start everything
hs.fnutils.each({
  bindings,
  controlplane,
  dots,
  notify,
  betterswitch,
  specialkeys,
  watchers
}, function(module) module.start() end)
