local hhtwm = require('hhtwm')

local cache  = { hhtwm = hhtwm }
local module = { cache = cache }

local screenWatcher = function(_, _, _, prevScreenCount, screenCount)
  if prevScreenCount ~= nil and prevScreenCount ~= screenCount then
    hhtwm.displayLayouts = calculateDisplayLayouts()
    hhtwm.tile()
  end
end

local calculateDisplayLayouts = function()
  local leftScreen       = nil
  local rightScreen      = nil

  for screen, position in pairs(hs.screen.screenPositions()) do
    if position.x == -1 then leftScreen  = screen end
    if position.x == 0  then rightScreen = screen end
  end

  local displayLayouts = { ['Color LCD'] = 'cards' }

  if leftScreen  then displayLayouts[leftScreen:id()]  = 'equal-right' end
  if rightScreen then displayLayouts[rightScreen:id()] = 'equal-left'  end

  return displayLayouts
end

local calcResizeStep = function(screen)
  return 1 / hs.grid.getGrid(screen).w
end

module.start = function()
  cache.watcher = hs.watchable.watch('status.connectedScreens', screenWatcher)

  local filters = {
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
  hhtwm.calcResizeStep = calcResizeStep
  hhtwm.displayLayouts = calculateDisplayLayouts()
  hhtwm.defaultLayout  = 'equal-left'
  hhtwm.enabledLayouts = { 'monocle', 'cards', 'equal-left', 'equal-right', 'main-left', 'main-right' }

  hhtwm.start()
end

module.stop = function()
  cache.watcher:release()
  hhtwm.stop()
end

return module

