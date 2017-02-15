local cache    = {}
local module   = { cache = cache }

local log      = hs.logger.new('kwm', 'debug');
local KWM_PATH = os.getenv('HOME') .. '/Documents/Code/Utils/kwm/bin/'

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

-- resize like vim does
function kwmSmartResize(resize)
  local window = hs.window.frontmostWindow()
  local others = window:otherWindowsSameScreen()

  local action, adjacent, direction

  if resize == 'thinner' or resize == 'wider' then
    adjacent = window:windowsToEast(others, false, true)
    direction = (#adjacent) > 0 and 'east' or 'west'
  elseif resize == 'taller' or resize == 'shorter' then
    adjacent = window:windowsToNorth(others, false, true)
    direction = (#adjacent) > 0 and 'north' or 'south'
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

module.start = function()
  restartKwm()

  function bind(mod, key, fn)
    hs.hotkey.bind(mod, key, fn, nil, fn)
  end

  hs.fnutils.each({
    { key = 'h', cmd = 'window -f west'  },
    { key = 'j', cmd = 'window -f south' },
    { key = 'k', cmd = 'window -f north' },
    { key = 'l', cmd = 'window -f east'  },

    { key = ']', cmd = 'display -f prev' },
    { key = '[', cmd = 'display -f next' }
  }, function(obj)
    bind({ 'ctrl', 'alt' }, obj.key, kwmc(obj.cmd))
  end)

  hs.fnutils.each({
    { key = 'h', cmd = 'window -s west'              },
    { key = 'j', cmd = 'window -s south'             },
    { key = 'k', cmd = 'window -s north'             },
    { key = 'l', cmd = 'window -s east'              },

    { key = ']', cmd = 'window -m display prev'      },
    { key = '[', cmd = 'window -m display next'      },

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
    bind({ 'ctrl', 'shift' }, obj.key, function() kwmSmartResize(obj.dir) end)
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
