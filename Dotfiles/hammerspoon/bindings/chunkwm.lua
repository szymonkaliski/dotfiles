local capitalize      = require('ext.utils').capitalize
local capture         = require('ext.utils').capture
local highlightWindow = require('ext.drawing').highlightWindow

local cache           = {}
local module          = { cache = cache }

local IMAGE_PATH      = os.getenv('HOME') .. '/.hammerspoon/assets/modal.png'
local CHUNKWM_PATH    = os.getenv('HOME') .. '/Documents/Code/Utils/chunkwm/bin/chunkwm'
local CHUNKC_PATH     = os.getenv('HOME') .. '/Documents/Code/Utils/chunkwm/src/chunkc/bin/chunkc'

local notify = function(text)
  hs.notify.new({
    title        = 'Tiling',
    subTitle     = text,
    contentImage = IMAGE_PATH
  }):send()
end

module.startChunkwm = function()
  cache.chunkwm = hs.task.new(CHUNKWM_PATH, function(exitCode)
    if exitCode ~= 15 and exitCode ~= 0 then
      notify('ChunkWM crashed, restarting [' .. exitCode .. ']')
      module.restartChunkwm()
    end
  end):start()
end

module.stopChunkwm = function()
  if cache.chunkwm then
    cache.chunkwm:terminate()
  end
end

module.restartChunkwm = function()
  module.stopChunkwm()
  module.startChunkwm()
end

local chunkcExec = function(cmd, callback)
  local args = hs.fnutils.split(cmd, ' ', nil, true)

  hs.task.new(
    CHUNKC_PATH,
    function() if callback then callback() end end,
    args
  ):start()
end

local chunkc = function(cmd)
  return function() chunkcExec(cmd) end
end

local isFloating = function()
  local query = capture(CHUNKC_PATH .. ' tiling::query --window float')
  return string.match(query, '1') ~= nil or #query == 0
end

local move = function(dir)
  local win = hs.window.frontmostWindow()

  if isFloating(win) then
    local directions = {
      west  = 'left',
      south = 'down',
      north = 'up',
      east  = 'right'
    }

    hs.grid['pushWindow' .. capitalize(directions[dir])](win)
    highlightWindow()
  else
    chunkcExec('tiling::window --swap ' .. dir, highlightWindow)
  end
end

local throw = function(dir)
  local win = hs.window.frontmostWindow()

  if isFloating(win) then
    hs.grid['pushWindow' .. capitalize(dir) .. 'Screen'](win)
    highlightWindow()
  else
    -- send window, then focus with chunkwm, then higlight window...
    -- contrived, but works for now
    chunkcExec('tiling::window --send-to-monitor ' .. dir)
    chunkcExec('tiling::monitor -f ' .. dir)
    hs.timer.doAfter(0.5, function() highlightWindow(win) end)
  end
end

local resize = function(resize)
  local win = hs.window.frontmostWindow()

  if isFloating(win) then
    hs.grid['resizeWindow' .. capitalize(resize)](win)
    highlightWindow()
  else
    local window = hs.window.frontmostWindow()
    local others = window:otherWindowsSameScreen()

    local temporaryRatio, adjacent, edge
    local stepSize = 0.05

    if resize == 'thinner' or resize == 'wider' then
      adjacent = window:windowsToEast(others, false, true)
      edge = #adjacent > 0 and 'east' or 'west'
    elseif resize == 'taller' or resize == 'shorter' then
      adjacent = window:windowsToNorth(others, false, true)
      edge = #adjacent > 0 and 'north' or 'south'
    end

    if resize == 'thinner' then
      temporaryRatio = #adjacent > 0 and -stepSize or stepSize
    elseif resize == 'wider' then
      temporaryRatio = #adjacent > 0 and stepSize or -stepSize
    elseif resize == 'taller' then
      temporaryRatio = stepSize
    elseif resize == 'shorter' then
      temporaryRatio = -stepSize
    end

    chunkcExec(
      'tiling::window --use-temporary-ratio ' .. temporaryRatio .. ' --adjust-window-edge ' .. edge,
      highlightWindow
    )
  end
end

-- restart chunkwm when changing screen count,
-- it doesn't recognise new screen setup by iteslf yet
local screenWatcher = function(_, _, _, prevScreenCount, screenCount)
  if prevScreenCount ~= nil and prevScreenCount ~= screenCount then
    module.restartChunkwm()
  end
end

module.start = function()
  module.startChunkwm()

  cache.watcher = hs.watchable.watch('status.connectedScreens', screenWatcher)

  local bind = function(key, fn)
    hs.hotkey.bind({ 'ctrl', 'shift' }, key, fn, nil, fn)
  end

  -- move window
  hs.fnutils.each({
    { key = 'h', dir = "west"  },
    { key = 'j', dir = "south" },
    { key = 'k', dir = "north" },
    { key = 'l', dir = "east"  },
  }, function(obj)
    bind(obj.key, function() move(obj.dir) end)
  end)

  -- throw between screens
  hs.fnutils.each({
    { key = ']', dir = 'prev' },
    { key = '[', dir = 'next' },
  }, function(obj)
    bind(obj.key, function() throw(obj.dir) end)
  end)

  -- resize
  hs.fnutils.each({
    { key = ',', dir = 'thinner' },
    { key = '.', dir = 'wider'   },
    { key = '-', dir = 'shorter' },
    { key = '=', dir = 'taller'  }
  }, function(obj)
    bind(obj.key, function() resize(obj.dir) end)
  end)

  -- toggle [f]loat
  bind('f', chunkc('tiling::window --toggle float'))

  -- toggle [s]plit
  bind('s', chunkc('tiling::window --toggle split'))

  -- [r]otate window tree
  bind('r', chunkc('tiling::desktop --rotate 90'))

  -- [e]qualize window sizes
  bind('e', chunkc('tiling::desktop --equalize'))

  -- cycle [m]odes
  bind('m', function()
    local mode = capture(CHUNKC_PATH .. ' tiling::query --desktop mode')
    local nextMode = mode == 'bsp' and 'monocle' or 'bsp'

    notify('Mode changed: ' .. nextMode)
    chunkcExec('tiling::desktop --layout ' .. nextMode, highlightWindow)
  end)

  -- [c]enter window
  bind('c', function()
    local win = hs.window.frontmostWindow()

    local centerAndSnap = function()
      win:centerOnScreen()
      hs.grid.snap(win)
      highlightWindow()
    end

    if isFloating(win) then
      centerAndSnap()
    else
      chunkcExec('tiling::window --toggle float', centerAndSnap)
    end
  end)

  -- toggle [z]oom window
  bind('z', function()
    local win = hs.window.frontmostWindow()

    local maximize = function()
      hs.grid.maximizeWindow(win)
      highlightWindow()
    end

    if isFloating(win) then
      maximize()
    else
      chunkcExec('tiling::window --toggle float', maximize)
    end
  end)

  -- [q]uit and reboot chunk
  bind('q', module.restartChunkwm)
end

module.stop = function()
  cache.watcher:release()
  module.stopChunkwm()
end

return module
