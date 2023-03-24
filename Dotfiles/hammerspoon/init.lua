-- utils
local flatten = require('ext.table').flatten

-- global stuff
require('console').init()
require('overrides').init()

-- ensure IPC is there
hs.ipc.cliInstall()

-- https://developer.apple.com/documentation/applicationservices/1459345-axuielementsetmessagingtimeout
hs.window.timeout(0.5)

-- lower logging level for hotkeys
require('hs.hotkey').setLogLevel('warning')

-- global config
config = {
  apps = {
    terms    = { 'kitty', 'Terminal'       },
    browsers = { 'Safari', 'Google Chrome' }
  },

  wm = {
    -- tilingMethod = 'hhtwm',
    tilingMethod = 'yabai',
    -- tilingMethod = 'grid',
    -- tilingMethod = 'autogrid',

    defaultLayouts = { 'monocle', 'main-left' },
    displayLayouts = {
      ['Color LCD']    = { 'monocle', 'main-left' },
      ['DELL U3818DW'] = { 'main-left', 'main-right', 'main-center', 'monocle' }
    }
  },

  window = {
    highlightBorder = false,
    highlightMouse  = true,
    historyLimit    = 100
  },

  network = {
    home = 'Skynet 5G'
  },

  logger = {
    path = os.getenv('HOME') .. '/.logger/data.db'
  },
}

-- requires
bindings   = require('bindings')
logger     = require('utils.logger')
ui         = require('utils.ui')
watchables = require('utils.watchables')
watchers   = require('utils.watchers')

-- no animations
hs.window.animationDuration = 0.0

-- hints
hs.hints.fontName           = 'Helvetica-Bold'
hs.hints.fontSize           = 22
hs.hints.hintChars          = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }
hs.hints.iconAlpha          = 1.0
hs.hints.showTitleThresh    = 0

-- watchers
watchers.enabled            = { 'theme', 'urlevent' }

-- ui
ui.enabled                  = { 'battery-menubar' }

-- bindings & modules
local modules               = { bindings, logger, watchers, ui, watchables } -- watchables have to come last to refresh all the things that depend on them
local basicBindings         = { 'annotate', 'ask-before-quit', 'block-hide', 'ctrl-esc', 'f-keys', 'focus', 'global', 'mediakeys', 'screenshot-with-meta', 'term-ctrl-i' }
bindings.askBeforeQuitApps  = flatten({ config.apps.browsers, config.apps.terms, { 'Preview' } })

if config.wm.tilingMethod == 'yabai' then
  bindings.enabled = flatten({ basicBindings, { 'yabai' } })
end

if config.wm.tilingMethod == 'hhtwm' then
  bindings.enabled = flatten({ basicBindings, { 'hhtwm' } })
end

if config.wm.tilingMethod == 'grid' then
  bindings.enabled = flatten({ basicBindings, { 'grid' } })
end

if config.wm.tilingMethod == 'autogrid' then
  bindings.enabled = flatten({ basicBindings, { 'grid' } })
  table.insert(watchers.enabled, 'autogrid')
end

-- start/stop modules
hs.fnutils.each(modules, function(module)
  if module then module.start() end
end)

-- stop modules on shutdown
hs.shutdownCallback = function()
  hs.fnutils.each(modules, function(module)
    if module then module.stop() end
  end)
end

-- notify when ready
hs.notify.new({
  title    = 'Hammerspoon',
  subTitle = 'Ready'
}):send()

