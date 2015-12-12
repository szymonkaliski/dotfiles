local keys               = require('ext.table').keys
local smartLaunchOrFocus = require('ext.application').smartLaunchOrFocus
local spaces             = require('hs._asm.undocumented.spaces')
local switch             = require('utils.spaces.quickswitch').switch;

local module = {}
local cache  = {}

local generateSpacesMenu = function()
  local activeSpace  = spaces.activeSpace()
  local screenSpaces = spaces.layout()[hs.screen.mainScreen():spacesUUID()]
  local spacesMenu   = {}

  for i = 1, #screenSpaces do
    table.insert(spacesMenu, { title = 'Space ' .. i, fn = function() switch(i) end })
  end

  return spacesMenu
end

local generateRunningMenu = function()
  local appMenu = {}

  local runningApps = hs.fnutils.filter(hs.application.runningApplications(), function(app)
    return app:role() == 'AXApplication' and app:kind() == 1 -- "1" means it's in the Dock
  end)

  table.sort(runningApps, function(a, b) return a:name() < b:name() end)

  hs.fnutils.each(runningApps, function(app)
    local appName = app:name()

    table.insert(appMenu, { title = appName, fn = function() smartLaunchOrFocus(appName) end })
  end)

  return appMenu
end

-- simple configurable right-command desktop menu like in openbox and clones
module.start = function()
  local appMenu = hs.menubar.new(false)

  cache.eventtap = hs.eventtap.new({ hs.eventtap.event.types.rightMouseDown }, function(event)
    local modifiers = event:getFlags()
    local screen    = hs.mouse.getCurrentScreen()
    local mousePos  = hs.mouse.getRelativePosition()

    local windowsOnScreen = hs.fnutils.filter(hs.window.orderedWindows(), function(win)
      return win:screen() == screen
    end)

    local shouldShowMenu = hs.fnutils.every({
      #keys(modifiers) == 0,
      hs.fnutils.every(windowsOnScreen, function(win)
        return not (hs.geometry.isPointInRect(mousePos, win:frame()) and win:application():role() ~= 'AXScrollArea')
      end)
    }, function(test) return test end)

    if not shouldShowMenu then return end

    appMenu
      :setMenu({
        { title = 'Spotlight', fn = function() hs.eventtap.keyStroke({ 'cmd' }, 'space')         end },

        { title = '-' },

        { title = 'Home',      fn = function() os.execute('open ~')                              end },
        { title = 'Terminal',  fn = function() smartLaunchOrFocus({ 'Terminal', 'iTerm2' })      end },
        { title = 'Browser',   fn = function() smartLaunchOrFocus({ 'Safari', 'Google Chrome' }) end },

        { title = '-' },

        { title = 'Running',   menu = generateRunningMenu() },
        { title = 'Spaces',    menu = generateSpacesMenu() },
        { title = 'Settings',  fn = function() smartLaunchOrFocus('System Preferences')          end },

        { title = '-' },

        { title = 'Lock',      fn = hs.caffeinate.systemSleep    },
        { title = 'Restart',   fn = hs.caffeinate.restartSystem  },
        { title = 'Shutdown',  fn = hs.caffeinate.shutdownSystem }
      })
      :popupMenu(mousePos)

    return true
  end):start()
end

module.stop = function()
  if cache.eventtap then cache.eventtap:stop() end
end

return module
