-- require modules into global namespace so they are available in the console
betterswitch                 = require('utils.spaces.betterswitch')
bindings                     = require('bindings')
controlplane                 = require('utils.controlplane')
dots                         = require('utils.spaces.dots')
notify                       = require('utils.notify')
specialkeys                  = require('utils.specialkeys')
watchers                     = require('utils.watchers')
window                       = require('ext.window')

-- extensions
window.fixEnabled            = false
window.fullFrame             = true
window.historyLimit          = 20
window.margin                = 6

-- dots
dots.alpha                   = 0.15
dots.selectedAlpha           = 0.45
dots.distance                = 16
dots.size                    = 8

-- hs
hs.window.animationDuration  = 0.1
hs.hints.fontName            = 'Helvetica-Bold'
hs.hints.fontSize            = 22
hs.hints.showTitleThresh     = 0
hs.hints.hintChars           = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }

-- notifications
notify.enabled               = { 'battery', 'online', 'wifi' }

-- watchers
watchers.enabled             = { 'application', 'reload', 'urlevent' }
watchers.urlPreference       = { 'Safari', 'Google Chrome' }

-- controlplane
controlplane.enabled         = { 'audio', 'automount', 'bluetooth', 'displays', 'persistvpn' }
controlplane.audioPreference = { 'EDIROL FA-66 (3624)', 'Built-in Output' }

-- special keyboard keys
specialkeys.enabled          = { 'players' }
specialkeys.playerPreference = { 'Spotify', 'OnlineSpotify', 'iTunes' }

-- start
hs.fnutils.each({
  bindings,
  controlplane,
  dots,
  notify,
  betterswitch,
  specialkeys,
  watchers
}, function(module) module.start() end)
