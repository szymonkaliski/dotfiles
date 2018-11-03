local activeScreen = require('ext.screen').activeScreen
local capitalize   = require('ext.utils').capitalize
local cycleWindows = require('ext.window').cycleWindows
local focusScreen  = require('ext.screen').focusScreen
local forceFocus   = require('ext.window').forceFocus

local cache  = {}
local module = { cache = cache }

local APP_WINDOWS_ONLY    = false
local ONLY_FRONTMOST      = true
local SCREEN_WINDOWS_ONLY = true
local STRICT_ANGLE        = true

-- works for windows and screens!
local focusAndHighlight = function(cmd)
  local focusedWindow     = hs.window.focusedWindow()
  local focusedScreen     = activeScreen()

  local winCmd            = 'windowsTo' .. capitalize(cmd)
  local screenCmd         = 'to' .. capitalize(cmd)

  local windowsToFocus    = cache.focusFilter[winCmd](cache.focusFilter, focusedWindow, ONLY_FRONTMOST, STRICT_ANGLE)
  local screenInDirection = focusedScreen[screenCmd](focusedScreen)
  local filterWindows     = cache.focusFilter:getWindows()

  local windowOnSameOrNextScreen = function(testWin, currentScreen, nextScreen)
    return testWin:screen():id() == currentScreen:id() or testWin:screen():id() == nextScreen:id()
  end

  -- focus window if we have any, and it's on nearest or current screen (don't jump over empty screens)
  if #windowsToFocus > 0 and windowOnSameOrNextScreen(windowsToFocus[1], focusedScreen, screenInDirection) then
    forceFocus(windowsToFocus[1])
  -- focus screen in given direction if exists
  elseif screenInDirection then
    focusScreen(screenInDirection)
  -- focus first window if there are any
  elseif #filterWindows > 0 then
    forceFocus(filterWindows[1])
  -- finally focus the screen if nothing else works
  else
    focusScreen(focusedScreen)
  end
end

module.start = function()
  local bind = function(key, fn)
    hs.hotkey.bind({ 'ctrl', 'alt' }, key, fn, nil, fn)
  end

  cache.focusFilter = hs.window.filter.new()
    :setCurrentSpace(true)
    :setDefaultFilter()
    :keepActive()

  hs.fnutils.each({
    { key = 'h', cmd = 'west'  },
    { key = 'j', cmd = 'south' },
    { key = 'k', cmd = 'north' },
    { key = 'l', cmd = 'east'  }
  }, function(object)
    bind(object.key, function()
      focusAndHighlight(object.cmd)
    end)
  end)

  -- cycle between windows on current screen, useful in tiling monocle mode
  bind(']', function() cycleWindows('next', APP_WINDOWS_ONLY, SCREEN_WINDOWS_ONLY) end)
  bind('[', function() cycleWindows('prev', APP_WINDOWS_ONLY, SCREEN_WINDOWS_ONLY) end)
end

module.stop = function()
end

return module;
