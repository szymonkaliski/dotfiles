local activeScreen = require('ext.screen').activeScreen
local table        = require('ext.table')
local hhtwm        = require('hhtwm')
local log          = hs.logger.new('wm', 'debug')

local cache        = { hhtwm = hhtwm }
local module       = { cache = cache }

-- local IMAGE_PATH   = os.getenv('HOME') .. '/.hammerspoon/assets/modal.png'

local setup = function()
  local filters = {
    { app = 'AppCleaner', tile = false                                },
    { app = 'Application Loader', tile = true                         },
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

  local fullMargin = 12
  local halfMargin = fullMargin / 2

  local screenMargin = {
    top    = (isMenubarVisible and 22 or 0) + halfMargin,
    bottom = halfMargin,
    left   = halfMargin,
    right  = halfMargin
  }

  hhtwm.margin         = fullMargin
  hhtwm.screenMargin   = screenMargin
  hhtwm.filters        = filters
  hhtwm.calcResizeStep = function(screen) return 1 / hs.grid.getGrid(screen).w end

  -- displayLayouts set up from first config.wm.displayLayouts
  local displayLayouts = {}

  for displayName, layouts in pairs(config.wm.displayLayouts) do
    displayLayouts[displayName] = layouts[1]
  end

  hhtwm.displayLayouts = displayLayouts
end

local screenWatcher = function(_, _, _, prevScreens, screens)
  if prevScreens == nil or #prevScreens == 0 then
    return
  end

  if table.equal(prevScreens, screens) then
    return
  end

  log.d('resetting display layouts', hs.inspect({ prev = prevScreens, curr = screens }))

  setup()

  hhtwm.resetLayouts()
  hhtwm.tile()
end

module.setLayout = function(layout)
  hhtwm.setLayout(layout)
  hhtwm.resizeLayout()
end

module.cycleLayout = function()
  local screen = activeScreen()

  local layouts = config.wm.displayLayouts[screen:name()] or config.wm.defaultLayouts

  local currentLayout = hhtwm.getLayout()
  local currentLayoutIndex = hs.fnutils.indexOf(layouts, currentLayout) or 0

  local nextLayoutIndex = (currentLayoutIndex % #layouts) + 1
  local nextLayout = layouts[nextLayoutIndex]

  module.setLayout(nextLayout)
end

module.start = function()
  setup()
  hhtwm.start()
  cache.watcher = hs.watchable.watch('status.connectedScreenNames', screenWatcher)
end

module.stop = function()
  hhtwm.stop()
  cache.watcher:release()
end

return module
