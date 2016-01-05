-- require modules into global namespace so they are available in the console
bindings                    = require('bindings')
window                      = require('ext.window')
notify                      = require('utils.notify')
watchers                    = require('utils.watchers')
dots                        = require('utils.spaces.dots')
betterswitch                = require('utils.spaces.betterswitch')
urlevent                    = require('utils.watchers.urlevent')
controlplane                = require('utils.controlplane')
specialkeys                 = require('utils.specialkeys')
menus                       = require('utils.menus')

-- extension settings
window.fixEnabled           = false
window.fullFrame            = true
window.historyLimit         = 20
window.margin               = 6

-- spaces dots settings
dots.alpha                  = 0.15
dots.selectedAlpha          = 0.45
dots.distance               = 16
dots.size                   = 8

-- hs settings
hs.window.animationDuration = 0.15
hs.hints.fontName           = 'Helvetica-Bold'
hs.hints.fontSize           = 22
hs.hints.showTitleThresh    = 0
hs.hints.hintChars          = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }

-- urlevent browser preference
urlevent.browserPreference  = { 'Safari', 'Google Chrome' }

-- enable notifications
notify.enabled              = { 'battery', 'online', 'wifi' }

-- enable watchers
watchers.enabled            = { 'application', 'reload', 'urlevent' }

-- enable controlplane extensions
controlplane.enabled        = { 'automount', 'bluetooth', 'displays', 'persistvpn' }

-- enable special keys functions
specialkeys.enabled         = { 'onlinespotify' }

-- start everything
hs.fnutils.each({
  bindings,
  controlplane,
  dots,
  -- menus,
  notify,
  betterswitch,
  specialkeys,
  watchers
}, function(module) module.start() end)
