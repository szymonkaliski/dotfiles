local activeScreen    = require('ext.screen').activeScreen
local capitalize      = require('ext.utils').capitalize
local capture         = require('ext.utils').capture
local highlightWindow = require('ext.drawing').highlightWindow
local log             = hs.logger.new('yabai', 'debug')

local cache      = {}
local module     = { cache = cache }

local IMAGE_PATH  = os.getenv('HOME') .. '/.hammerspoon/assets/yabai.png'
local YABAI_PATH  = '/usr/local/bin/yabai'
local JQ_PATH     = '/usr/local/bin/jq'
local STEP        = 60
local VERBOSE     = false

local notify = function(msg)
  hs.notify.new({
    title        = 'Yabai',
    subTitle     = msg,
    contentImage = IMAGE_PATH
  }):send()
end

local onYabaiTerminate = function(exitCode)
  if exitCode ~= 0 then
    notify('Crashed, restarting')
    module.restartYabai()
  end
end

local onYabaiOutput = function(_, out, err)
  log.d(out, err)
  return true
end

module.startYabai = function()
  cache.yabai = hs.task.new(
    YABAI_PATH,
    onYabaiTerminate,
    onYabaiOutput,
    VERBOSE and { '--verbose' } or {}
  ):start()
end

module.stopYabai = function()
  if cache.yabai then
    cache.yabai:terminate()
  end
end

module.restartYabai = function()
  module.stopYabai()
  module.startYabai()
end

local yabai = function(cmd)
  local finalCmd = YABAI_PATH .. ' -m ' .. cmd .. ' 2>/dev/null'

  return os.execute(finalCmd)
end

local yabaiOr = function(cmds)
  local finalCmd= table.concat(hs.fnutils.map(cmds, function(cmd)
    return YABAI_PATH .. ' -m ' .. cmd .. ' 2>/dev/null'
  end), ' || ')

  return os.execute(finalCmd)
end

local getSpaceLayout = function()
  local output, _, _, _ = hs.execute(YABAI_PATH .. ' -m query --spaces --space | ' .. JQ_PATH .. ' .type')

  return output:gsub('\n', ''):gsub('"', '')
end

local getSpaceIndex = function()
  local output, _, _, _ = hs.execute(YABAI_PATH .. ' -m query --spaces --space | ' .. JQ_PATH .. ' .index')

  return output:gsub('\n', ''):gsub('"', '')
end

local getPaddings = function(spaceIndex)
  local topPadding, _, _, _  = hs.execute(YABAI_PATH .. ' -m config --space ' .. spaceIndex .. ' top_padding')
  local leftPadding, _, _, _ = hs.execute(YABAI_PATH .. ' -m config --space ' .. spaceIndex .. ' left_padding')

  topPadding  = topPadding:gsub('\n', ''):gsub('"', '')
  leftPadding = leftPadding:gsub('\n', ''):gsub('"', '')

  return {
    top  = topPadding,
    left = leftPadding,
  }
end

local getManagedWindowsCount = function()
  local output, _, _, _ = hs.execute(
    YABAI_PATH ..
    " -m query --windows --space | " ..
    JQ_PATH ..
    " 'map(select(.\"is-floating\" == false and .\"is-sticky\" == false and .\"is-minimized\" == false and .\"is-visible\" == true)) | length'"
  )

  return output:gsub('\n', ''):gsub('"', '')
end

local isFloating = function(win)
  local win = hs.window.focusedWindow()

  if not win then
    return false
  end

  if win:application():name() == 'Hammerspoon' then
    return true
  end

  if getSpaceLayout() == 'float' then
    return true
  end

  local cmd = YABAI_PATH .. " -m query --windows --window " .. win:id() .. " | " .. JQ_PATH .. " -e '.\"is-floating\" == true'"

  local _, _, _, rc = hs.execute(cmd)
  return rc == 0
end

local move = function(dir)
  if isFloating(hs.window.focusedWindow()) then
    local directions = {
      west  = 'left',
      south = 'down',
      north = 'up',
      east  = 'right'
    }

    hs.grid['pushWindow' .. capitalize(directions[dir])](win)
  else
    yabai('window --swap ' .. dir)
  end

  highlightWindow()
end

local warp = function(dir)
  if not isFloating(hs.window.focusedWindow()) then
    yabai('window --warp ' .. dir)
  end

  highlightWindow()
end

local focusDirection = function(dir)
  yabai('window --focus ' .. dir)

  highlightWindow()
end

local resize = function(dir)
  if isFloating(hs.window.focusedWindow()) then
    hs.grid['resizeWindow' .. capitalize(dir)](win)
  else
    -- TODO: resizing yabai splits still doesn't feel right
    --
    -- https://github.com/koekeishiya/yabai/issues/200#issuecomment-519257233

    if dir == 'thinner' then
      yabai('window --resize  left:-' .. STEP .. ':0')
      yabai('window --resize right:-' .. STEP .. ':0')
    end

    if dir == 'wider' then
      yabai('window --resize  left:' .. STEP .. ':0')
      yabai('window --resize right:' .. STEP .. ':0')
    end

    if dir == 'shorter' then
      yabai('window --resize   top:0:-' .. STEP)
      yabai('window --resize botom:0:-' .. STEP)
    end

    if dir == 'taller' then
      yabai('window --resize   top:0:' .. STEP)
      yabai('window --resize botom:0:' .. STEP)
    end
  end

  highlightWindow()
end

local focusDisplay = function(dir, wrap)
  yabaiOr({
    'display --focus ' .. dir,
    'display --focus ' .. wrap
  })
end

local throwToDisplay = function(dir, wrap)
  local win = hs.window.frontmostWindow()

  if isFloating(win) then
    hs.grid['pushWindow' .. capitalize(dir) .. 'Screen'](win)
    highlightWindow()
  else
    yabaiOr({
      'window --display ' .. dir,
      'window --display ' .. wrap
    })

    hs.timer.doAfter(0.3, function()
      win:focus()
      highlightWindow(win)
    end)
  end
end

local throwToSpace = function(win, id)
  yabai('window ' .. win:id() .. ' --space ' .. id)

  highlightWindow()
end

local cycleLayout = function()
  local currentYabaiLayout = getSpaceLayout()
  local currentYabaiSpace = getSpaceIndex()
  local currentYabaiPaddings = getPaddings(currentYabaiSpace)

  local isUltrawide = activeScreen():frame().w == 3840

  local currentLayout = currentYabaiLayout
  if currentYabaiLayout == 'stack' and currentYabaiPaddings.left ~= '12' then
    currentLayout = 'centered'
  end

  local layouts = isUltrawide and { 'bsp', 'float', 'centered' } or { 'bsp', 'float', 'stack' }

  local currentLayoutIndex = hs.fnutils.indexOf(layouts, currentLayout) or 0
  local nextLayoutIndex = (currentLayoutIndex % #layouts) + 1
  local nextLayout = layouts[nextLayoutIndex]

  if nextLayout == 'centered' then
    yabai('space --layout stack')

    yabai('config --space mouse left_padding ' .. 969)
    yabai('config --space mouse right_padding ' .. 969)
  else
    yabai('space --layout ' .. nextLayout)

    yabai('config --space mouse left_padding ' .. 12)
    yabai('config --space mouse right_padding ' .. 12)
  end

  notify('Layout: ' .. nextLayout)
end

module.start = function()
  module.startYabai()

  local ultra = { 'ctrl', 'alt', 'cmd' }

  local bind = function(key, fn)
    hs.hotkey.bind({ 'ctrl', 'shift' }, key, fn, nil, fn)
  end

  hs.fnutils.each({
    { key = 'h', dir = 'west'  },
    { key = 'j', dir = 'south' },
    { key = 'k', dir = 'north' },
    { key = 'l', dir = 'east'  },
  }, function(obj)
    bind(obj.key, function() move(obj.dir)  end)
  end)

  hs.fnutils.each({
    { key = '[', dir = 'prev', wrap = 'last'  },
    { key = ']', dir = 'next', wrap = 'first' },
  }, function(obj)
    bind(obj.key, function() throwToDisplay(obj.dir, obj.wrap) end)
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

  -- [c]enter
  bind('c', function()
    local win = hs.window.focusedWindow()

    if isFloating(win) then
      hs.grid.center(win)
      highlightWindow()
    end
  end)

  -- [z]oom
  bind('z', function()
    local win = hs.window.focusedWindow()

    if isFloating(win) then
      hs.grid.maximizeWindow(win)
      highlightWindow()
    end
  end)

  -- toggle [f]loat
  bind('f', function()
    -- TODO: store/restore position of floated window
    yabai('window --toggle float')
    highlightWindow()
  end)

  -- toggle [s]plit type
  bind('s', function()
    yabai('window --toggle split')
    highlightWindow()
  end)

  -- [e]qualize window sizes
  bind('e', function()
    yabai('space --balance')
    highlightWindow()
  end)

  -- [r]otate tree
  bind('r', function()
    yabai('space --rotate 180')
    highlightWindow()
  end)

  -- [p]ercentage
  local getPercentage = hs.fnutils.cycle({ '0.3333', '0.5', '0.6666' })
  bind('p', function()
    yabai('window --ratio abs:' .. getPercentage())
    highlightWindow()
  end)

  -- change [l]ayout
  hs.hotkey.bind(ultra, 'l', cycleLayout)

  -- throw window to space (and move)
  for n = 0, 9 do
    local idx = tostring(n)

    -- important: use this with onKeyReleased, not onKeyPressed
    hs.hotkey.bind({ 'ctrl', 'shift' }, idx, nil, function()
      local win = hs.window.focusedWindow()

      if win then
        throwToSpace(win, n == 0 and 10 or n) -- 0 is 10th space
      end

      hs.eventtap.keyStroke({ 'ctrl' }, idx)
    end)
  end
end

module.stop = function()
  module.stopYabai()
end

return module
