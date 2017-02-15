local capture  = require('ext.utils').capture
local cache    = {}
local module   = { cache = cache }

local log      = hs.logger.new('kwm', 'debug');
local KWM_PATH = os.getenv('HOME') .. '/Documents/Code/Utils/kwm/bin/'

function capitalize(str)
  return str:gsub("^%l", string.upper)
end

function startKwm()
  cache.kwm = hs.task.new(KWM_PATH .. 'kwm', function(exitCode)
    if exitCode ~= 0 then
      log.d('KWM exit code: ' .. exitCode)

      hs.notify.new({
        title    = 'KWM crashed, restarting',
        subTitle = 'Exit code: ' .. exitCode
      }):send()

      restartKwm()
    end
  end):start()
end

function stopKwm()
  if cache.kwm then
    cache.kwm:terminate()
  end
end

function restartKwm()
  stopKwm()
  startKwm()
end

function kwmcExec(cmd)
  local args = hs.fnutils.split(cmd, ' ', nil, true)
  hs.task.new(KWM_PATH .. 'kwmc', nil, args):start()
end

function kwmc(cmd)
  return function() kwmcExec(cmd) end
end

function isFloating()
  if hs.window.frontmostWindow():application():name() == 'Hammerspoon' then
    return true
  end

  local queryFloat = capture(KWM_PATH .. 'kwmc query window focused float')
  local queryId    = capture(KWM_PATH .. 'kwmc query window focused id')

  return string.match(queryFloat, 'true') or string.match(queryId, '-1')
end

-- resize like vim does, works with grid and kwm
function smartResize(resize)
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

    kwmcExec('window -c ' .. action .. ' 0.025 ' .. direction)
  end
end

-- smart movement grid/kwm depending if window is floating
function smartMove(direction)
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
function smartThrowToScreen(direction)
  if isFloating() then
    hs.grid['pushWindow' .. capitalize(direction) .. 'Screen'](hs.window.frontmostWindow())
  else
    kwmcExec('display -m ' .. direction)
  end
end

module.start = function()
  restartKwm()

  function bind(mod, key, fn)
    hs.hotkey.bind(mod, key, fn, nil, fn)
  end

  hs.fnutils.each({
    { key = 'h', dir = 'left'  },
    { key = 'j', dir = 'down'  },
    { key = 'k', dir = 'up'    },
    { key = 'l', dir = 'right' }
  }, function(obj)
    bind({ 'ctrl', 'shift' }, obj.key, function() smartMove(obj.dir) end)
  end)

  hs.fnutils.each({
    { key = ']', dir = 'prev' },
    { key = '[', dir = 'next' },
  }, function(obj)
    bind({ 'ctrl', 'shift' }, obj.key, function() smartThrowToScreen(obj.dir) end)
  end)

  hs.fnutils.each({
    { key = 'r', cmd = 'tree rotate 180'             }, -- rotate tree
    { key = 'z', cmd = 'window -z fullscreen'        }, -- temporary fullscreen window
    { key = 'f', cmd = 'window -t focused'           }, -- make window floating
    { key = 't', cmd = 'window -c split-mode toggle' }  -- toggle split horizontal/vertical
  }, function(obj)
    bind({ 'ctrl', 'shift' }, obj.key, kwmc(obj.cmd))
  end)

  hs.fnutils.each({
    { key = ',', dir = 'thinner' },
    { key = '.', dir = 'wider'   },
    { key = '-', dir = 'shorter' },
    { key = '=', dir = 'taller'  }
  }, function(obj)
    bind({ 'ctrl', 'shift' }, obj.key, function() smartResize(obj.dir) end)
  end)

  local modes = hs.fnutils.cycle({ 'monocle', 'float', 'bsp' })

  bind({ 'ctrl', 'shift' }, 'm', function()
    local mode = modes()

    hs.notify.new({
      title    = 'KWM mode changed',
      subTitle = string.upper(mode)
    }):send()

    kwmcExec('space -t ' .. mode)
  end)
end

module.stop = function()
  stopKwm()
end

return module
