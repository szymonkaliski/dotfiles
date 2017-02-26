local capture    = require('ext.utils').capture
local cache      = {}
local module     = { cache = cache }

local log        = hs.logger.new('kwm', 'debug');

local KWM_PATH   = os.getenv('HOME') .. '/Documents/Code/Utils/kwm/bin/'
local IMAGE_PATH = os.getenv('HOME') .. '/.hammerspoon/assets/modal.png'

local notify = function(text)
  hs.notify.new({
    title        = 'KWM',
    subTitle     = text,
    contentImage = IMAGE_PATH
  }):send()
end

local capitalize = function(str)
  return str:gsub("^%l", string.upper)
end

local restartKwm

local startKwm = function()
  cache.kwm = hs.task.new(KWM_PATH .. 'kwm', function(exitCode)
    if exitCode ~= 0 then
      log.d('KWM crashed [' .. exitCode .. ']')
      notify('Crashed, restarting [' .. exitCode .. ']')

      restartKwm()
    end
  end):start()
end

local stopKwm = function()
  if cache.kwm then
    cache.kwm:terminate()
  end
end

restartKwm = function()
  stopKwm()
  startKwm()
end

local kwmcExec = function(cmd)
  local args = hs.fnutils.split(cmd, ' ', nil, true)
  hs.task.new(KWM_PATH .. 'kwmc', nil, args):start()
end

local kwmc = function(cmd)
  return function() kwmcExec(cmd) end
end

local isFloating = function()
  if hs.window.frontmostWindow():application():name() == 'Hammerspoon' then
    return true
  end

  local queryFloat = capture(KWM_PATH .. 'kwmc query window focused float')
  local queryId    = capture(KWM_PATH .. 'kwmc query window focused id')

  return string.match(queryFloat, 'true') or string.match(queryId, '-1')
end

-- resize like vim does, works with grid and kwm
local smartResize = function(resize)
  if isFloating() then
    hs.grid['resizeWindow' .. capitalize(resize)](hs.window.frontmostWindow())
  else
    local window = hs.window.frontmostWindow()
    local others = window:otherWindowsSameScreen()

    local action, adjacent, direction

    if resize == 'thinner' or resize == 'wider' then
      adjacent = window:windowsToEast(others, false, true)
      direction = #adjacent > 0 and 'east' or 'west'
    elseif resize == 'taller' or resize == 'shorter' then
      adjacent = window:windowsToNorth(others, false, true)
      direction = #adjacent > 0 and 'north' or 'south'
    end

    if resize == 'thinner' then
      action = (#adjacent) > 0 and 'reduce' or 'expand'
    elseif resize == 'wider' then
      action = (#adjacent) > 0 and 'expand' or 'reduce'
    elseif resize == 'taller' then
      action = 'expand'
    elseif resize == 'shorter' then
      action = 'reduce'
    end

    local gridSize = hs.grid.getGrid(window:screen())
    local stepSize = {
      thinner = 1 / gridSize.w,
      wider   = 1 / gridSize.w,
      taller  = 1 / gridSize.h,
      shorter = 1 / gridSize.h
    }

    kwmcExec('window -c ' .. action .. ' ' .. stepSize[resize] .. ' ' .. direction)
  end
end

-- smart movement grid/kwm depending if window is floating
local smartMove = function(direction)
  local directionMap = {
    left  = 'west',
    down  = 'south',
    up    = 'north',
    right = 'east'
  }

  if isFloating() then
    hs.grid['pushWindow' .. capitalize(direction)](hs.window.frontmostWindow())
  else
    kwmcExec('window -s ' .. directionMap[direction])
  end
end

-- smart throw to screen, works with kwm/grid
local smartThrowToScreen = function(direction)
  if isFloating() then
    hs.grid['pushWindow' .. capitalize(direction) .. 'Screen'](hs.window.frontmostWindow())
  else
    kwmcExec('window -m display ' .. direction)
  end
end

module.start = function()
  restartKwm()

  function bind(mod, key, fn)
    hs.hotkey.bind(mod, key, fn, nil, fn)
  end

  -- move windows
  hs.fnutils.each({
    { key = 'h', dir = 'left'  },
    { key = 'j', dir = 'down'  },
    { key = 'k', dir = 'up'    },
    { key = 'l', dir = 'right' }
  }, function(obj)
    bind({ 'ctrl', 'shift' }, obj.key, function() smartMove(obj.dir) end)
  end)

  -- throw between screens
  hs.fnutils.each({
    { key = ']', dir = 'prev' },
    { key = '[', dir = 'next' },
  }, function(obj)
    bind({ 'ctrl', 'shift' }, obj.key, function() smartThrowToScreen(obj.dir) end)
  end)

  -- resize windows
  hs.fnutils.each({
    { key = ',', dir = 'thinner' },
    { key = '.', dir = 'wider'   },
    { key = '-', dir = 'shorter' },
    { key = '=', dir = 'taller'  }
  }, function(obj)
    bind({ 'ctrl', 'shift' }, obj.key, function() smartResize(obj.dir) end)
  end)

  hs.fnutils.each({
    { key = 'r', cmd = 'tree rotate 180'             }, -- rotate tree
    { key = 'f', cmd = 'window -t focused'           }, -- toggle window floating
    { key = 't', cmd = 'window -c split-mode toggle' }  -- toggle split horizontal/vertical
  }, function(obj)
    bind({ 'ctrl', 'shift' }, obj.key, kwmc(obj.cmd))
  end)

  local modes = hs.fnutils.cycle({ 'monocle', 'bsp' })  -- there's also "float" but I only use it on per-window basis (ctrl-shift-f)

  -- toggle modes
  bind({ 'ctrl', 'shift' }, 'm', function()
    local mode = modes()

    notify('Mode changed: ' .. string.upper(mode))
    kwmcExec('space -t ' .. mode)
  end)

  -- send to back
  bind({ 'ctrl', 'shift' }, 'b', function()
    hs.window.frontmostWindow():sendToBack()
  end)

  -- center window
  bind({ 'ctrl', 'shift' }, 'c', function()
    if isFloating() then
      hs.window.frontmostWindow():centerOnScreen()
      hs.grid.snap(hs.window.frontmostWindow())
    end
  end)

  -- zoom window
  bind({ 'ctrl', 'shift' }, 'z', function()
    if isFloating() then
      hs.grid.maximizeWindow()
    else
      kwmcExec('window -z fullscreen')
    end
  end)
end

module.stop = function()
  stopKwm()
end

return module
