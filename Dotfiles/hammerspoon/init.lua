-- global stuff
require('console').init()
require('overrides').init()

-- ensure IPC is there
hs.ipc.cliInstall()

-- lower logging level for hotkeys
require('hs.hotkey').setLogLevel("warning")

-- tiling config
local hhtwmFilters = {
  { app = 'AppCleaner', tile = false                                },
  { app = 'Archive Utility', tile = false                           },
  { app = 'DiskImages UI Agent', tile = false                       },
  { app = 'FaceTime', tile = false                                  },
  { app = 'Finder', title = 'Copy', tile = false                    },
  { app = 'Finder', title = 'Move', tile = false                    },
  { app = 'Focus', tile = false                                     },
  { app = 'GIF Brewery 3', tile = false                             },
  { app = 'Hammerspoon', title = 'Hammerspoon Console', tile = true },
  { app = 'Helium', tile = false                                    },
  { app = 'Kap', tile = false                                       },
  { app = 'Max', tile = true                                        },
  { app = 'Messages', tile = false                                  },
  { app = 'Photo Booth', tile = false                               },
  { app = 'Pixelmator', subrole = 'AXDialog', tile = false          },
  { app = 'Pixelmator', subrole = 'AXUnknown', tile = false         },
  { app = 'QuickTime Player', tile = false                          },
  { app = 'Reminders', tile = false                                 },
  { app = 'Simulator', tile = false                                 },
  { app = 'System Preferences', tile = false                        },
  { app = 'The Unarchiver', tile = false                            },
  { app = 'Transmission', tile = false                              },
  { app = 'Tweetbot', tile = false                                  },
  { app = 'UnmountAssistantAgent', tile = false                     },
  { app = 'Viscosity', tile = false                                 },
  { app = 'iTerm', subrole = 'AXDialog', tile = false               },
  { app = 'iTerm2', subrole = 'AXDialog', tile = false              },
  { app = 'iTunes', title = 'Mini Player', tile = false             },
  { app = 'iTunes', title = 'Multiple Song Info', tile = false      },
  { app = 'iTunes', title = 'Song Info', tile = false               },
  { title = 'Little Snitch Configuration', tile = true              },
  { title = 'Little Snitch Network Monitor', tile = false           },
  { title = 'Quick Look', tile = false                              },
  { title = 'TeamViewer', tile = true                               },
}

local isMenubarVisible = hs.screen.primaryScreen():frame().y > 0
local leftScreen       = nil
local rightScreen      = nil

for screen, position in pairs(hs.screen.screenPositions()) do
  if position.x == -1 then leftScreen  = screen end
  if position.x == 0  then rightScreen = screen end
end

local displayLayouts = { ['Color LCD'] = 'monocle' }

if leftScreen  then displayLayouts[leftScreen:id()]  = 'equal-right' end
if rightScreen then displayLayouts[rightScreen:id()] = 'equal-left'  end

-- requires
bindings                    = require('bindings')
controlplane                = require('utils.controlplane')
hhtwm                       = require('hhtwm')
watchables                  = require('utils.watchables')
watchers                    = require('utils.watchers')
window                      = require('ext.window')

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

-- tiling
local fullMargin            = 12
local halfMargin            = fullMargin / 2

hhtwm.margin                = fullMargin
hhtwm.screenMargin          = { top = isMenubarVisible and 28 or halfMargin, bottom = halfMargin, left = halfMargin, right = halfMargin }
hhtwm.calcResizeStep        = function(screen) return 1 / hs.grid.getGrid(screen).w end
hhtwm.filters               = hhtwmFilters
hhtwm.defaultLayout         = 'equal-left'
hhtwm.displayLayouts        = displayLayouts
hhtwm.enabledLayouts        = { 'monocle', 'cards', 'equal-left', 'equal-right', 'main-left', 'main-right' }

-- controlplane
controlplane.enabled        = { 'automount' }

-- watchers
watchers.enabled            = { 'urlevent' }
watchers.urlPreference      = { 'Safari', 'Google Chrome' }

-- bindings
bindings.enabled            = { 'ask-before-quit', 'block-hide', 'ctrl-esc', 'f-keys', 'focus', 'global', 'tiling', 'term-ctrl-i', 'viscosity' }
bindings.askBeforeQuitApps  = { 'Safari', 'Google Chrome' }

-- start/stop modules
local modules               = { bindings, controlplane, hhtwm, watchables, watchers }

hs.fnutils.each(modules, function(module)
  if module then module.start() end
end)

-- stop modules on shutdown
hs.shutdownCallback = function()
  hs.fnutils.each(modules, function(module)
    if module then module.stop() end
  end)
end
