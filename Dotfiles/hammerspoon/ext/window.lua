local activeScreen         = require('ext.screen').activeScreen
local application          = require('ext.application')
local bezel                = require('ext.drawing').bezel
local focusScreen          = require('ext.screen').focusScreen
local framed               = require('ext.framed')
local highlightWindow      = require('ext.drawing').highlightWindow
local isSpaceFullscreenApp = require('ext.spaces').isSpaceFullscreenApp
local screenSpaces         = require('ext.spaces').screenSpaces
local spaceInDirection     = require('ext.spaces').spaceInDirection
local spaces               = require('hs._asm.undocumented.spaces')

local cache  = { mousePosition = nil }
local module = { cache = cache }

-- get screen frame
module.screenFrame = function(win)
  local funcName  = window.fullFrame and 'fullFrame' or 'frame'
  local winScreen = win:screen()

  return winScreen[funcName](winScreen)
end

-- set frame
module.setFrame = function(win, frame, time)
  win:setFrame(frame, time or hs.window.animationDuration)
end

-- ugly fix for problem with window height when it's as big as screen
module.fixFrame = function(win)
  if window.fixEnabled then
    local screen = module.screenFrame(win)
    local frame  = win:frame()

    if (frame.h > (screen.h - window.margin * 2)) then
      frame.h = screen.h - window.margin * 10
      window.setFrame(win, frame)
    end
  end
end

-- pushes window in direction
module.push = function(win, direction, value)
  local screen = module.screenFrame(win)
  local frame

  frame = framed.push(screen, direction, value)

  module.fixFrame(win)
  module.setFrame(win, frame)
end

-- nudges window in direction
module.nudge = function(win, direction)
  local screen = module.screenFrame(win)
  local frame  = win:frame()

  frame = framed.nudge(frame, screen, direction)
  module.setFrame(win, frame, 0.05)
end

-- push and nudge window in direction
module.pushAndSend = function(win, options)
  local direction, value

  if type(options) == 'table' then
    direction = options[1]
    value     = options[2] or 1 / 2
  else
    direction = options
    value     = 1 / 2
  end

  module.push(win, direction, value)

  hs.timer.doAfter(hs.window.animationDuration * 3 / 2, function()
    module.send(win, direction)
  end)
end

-- sends window in direction
module.send = function(win, direction)
  local screen = module.screenFrame(win)
  local frame  = win:frame()

  frame = framed.send(frame, screen, direction)

  module.fixFrame(win)
  module.setFrame(win, frame)
end

-- centers window
module.center = function(win)
  local screen = module.screenFrame(win)
  local frame  = win:frame()

  frame = framed.center(frame, screen)
  module.setFrame(win, frame)
end

-- fullscreen window with margin
module.fullscreen = function(win)
  local screen = module.screenFrame(win)
  local frame  = {
    x = window.margin + screen.x,
    y = window.margin + screen.y,
    w = screen.w - window.margin * 2,
    h = screen.h - window.margin * 2
  }

  module.fixFrame(win)
  module.setFrame(win, frame)

  -- center after setting frame, fixes terminal
  hs.timer.doAfter(hs.window.animationDuration * 3 / 2, function()
    module.center(win)
  end)
end

-- set window size and center
module.setSize = function(win, size)
  local screen = module.screenFrame(win)
  local frame  = win:frame()

  if size.w and size.h then
    frame.w = size.w
    frame.h = size.h
  elseif size.mod then
    frame.w = frame.w + size.mod
    frame.h = frame.h + size.mod
  end

  frame = framed.fit(frame, screen)
  frame = framed.center(frame, screen)

  module.setFrame(win, frame)

  -- center after setting frame, fixes terminal
  hs.timer.doAfter(hs.window.animationDuration * 3 / 2, function()
    module.center(win)
  end)
end

-- focus window in direction
module.focus = function(win, direction)
  local functions = {
    up    = 'focusWindowNorth',
    down  = 'focusWindowSouth',
    left  = 'focusWindowWest',
    right = 'focusWindowEast'
  }

  local candidateWindows = nil   -- we want to focus all windows
  local frontmost        = false -- focuses the nearest window that isn't occluded by any other window
  local strict           = true  -- only consider windows at an angle between 45 and -45 degrees

  hs.window[functions[direction]](win, candidateWindows, frontmost, strict)
  highlightWindow()
end

-- throw to screen in direction, center and fit
module.throwToScreen = function(win, direction)
  local winScreen       = win:screen()
  local frameFunc       = module.fullFrame and 'fullFrame' or 'frame'
  local throwScreenFunc = {
    up    = 'toNorth',
    down  = 'toSouth',
    left  = 'toWest',
    right = 'toEast'
  }

  local throwScreen = winScreen[throwScreenFunc[direction]](winScreen)

  if throwScreen == nil then return end

  local frame       = win:frame()
  local screenFrame = throwScreen[frameFunc](throwScreen)

  frame.x = screenFrame.x
  frame.y = screenFrame.y

  frame = framed.fit(frame, screenFrame)
  frame = framed.center(frame, screenFrame)

  module.fixFrame(win)
  module.setFrame(win, frame)

  win:focus()

  -- center after setting frame, fixes terminal
  hs.timer.doAfter(hs.window.animationDuration * 3 / 2, function()
    module.center(win)
  end)
end

-- move window to another space
module.moveToSpaceInDirection = function(win, direction)
  local clickPoint  = win:zoomButtonRect()
  local sleepTime   = 1000
  local targetSpace = spaceInDirection(direction)

  -- check if all conditions are ok to move the window
  local shouldMoveWindow = hs.fnutils.every({
    clickPoint ~= nil,
    targetSpace ~= nil,
    not isSpaceFullscreenApp(targetSpace),
    not cache.movingWindowToSpace
  }, function(test) return test end)

  if not shouldMoveWindow then return end

  cache.movingWindowToSpace = true

  cache.mousePosition = cache.mousePosition or hs.mouse.getAbsolutePosition()

  clickPoint.x = clickPoint.x + clickPoint.w + 5
  clickPoint.y = clickPoint.y + clickPoint.h / 2

  -- fix for Chrome UI
  if win:application():title() == 'Google Chrome' then
    clickPoint.y = clickPoint.y - clickPoint.h
  end

  -- focus screen before switching window
  focusScreen(win:screen())

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()
  hs.timer.usleep(sleepTime)

  hs.eventtap.keyStroke({ 'ctrl' }, direction == 'east' and 'right' or 'left')

  hs.timer.waitUntil(
    function()
      return spaces.activeSpace() == targetSpace
    end,
    function()
      hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()

      -- resetting mouse after small timeout is needed for focusing screen to work properly
      hs.mouse.setAbsolutePosition(cache.mousePosition)
      cache.mousePosition = nil

      -- reset cache
      cache.movingWindowToSpace = false

      -- display bezel info
      -- bezel(direction == 'east' and '→' or '←', 70)
    end,
    0.01 -- check every 1/100 of a second
  )
end

-- cycle application windows
module.cycleWindows = function(win, appWindowsOnly)
  local allWindows = appWindowsOnly and win:application():allWindows() or hs.window.allWindows()

  --  we only care about standard windows
  local windows = hs.fnutils.filter(allWindows, function(win) return win:isStandard() end)

  -- get id based of appname and window id
  -- this basically makes sorting windows bit saner
  local getId = function(win)
    return win:application():bundleID() .. '-' .. win:id()
  end

  if #windows == 1 then
    -- if we have only one window - focus it
    windows[1]:focus()
  elseif #windows > 1 then
    -- if there are more than one, sort them first by id
    table.sort(windows, function(a, b) return getId(a) < getId(b) end)

    -- check if one of them is active
    local activeWindowIndex = hs.fnutils.indexOf(windows, win)

    if activeWindowIndex then
      -- if it is, then focus next one
      activeWindowIndex = activeWindowIndex + 1

      if activeWindowIndex > #windows then activeWindowIndex = 1 end

      windows[activeWindowIndex]:focus()
    else
      -- otherwise focus first one
      windows[1]:focus()
    end
  end

  highlightWindow()
end

-- show hints with highlight
module.windowHints = function()
  hs.hints.windowHints(nil, highlightWindow)
end

-- save and restore window positions
module.persistPosition = function(win, option)
  local application     = win:application()
  local appId           = application:bundleID() or application:name()
  local frame           = win:frame()
  local windowPositions = hs.settings.get('windowPositions') or {}
  local index           = windowPositions[appId] and windowPositions[appId].index or nil
  local frames          = windowPositions[appId] and windowPositions[appId].frames or {}

  -- check if given frame differs frome last one in array
  local framesDiffer = function(frame, frames)
    return frames and (#frames == 0 or not frame:equals(frames[#frames]))
  end

  -- remove first element if we hit history limit (adjusting index if needed)
  if #frames > window.historyLimit then
    table.remove(frames, 1)
    index = index > #frames and #frames or math.max(index - 1, 1)
  end

  -- append window position to a table, only if it's a new frame
  if option == 'save' and framesDiffer(frame, frames) then
    table.insert(frames, frame.table)
    index = #frames
  end

  -- undo window position
  if option == 'undo' and index ~= nil then
    -- if we are at the last index
    -- (or more, which shouldn't happen?)
    if index >= #frames then
      if framesDiffer(frame, frames) then
        -- and current frame differs from last one - save it
        table.insert(frames, frame.table)
      else
        -- otherwise frames are the same, so get the previous one
        index = math.max(index - 1, 1)
      end
    end

    module.setFrame(win, frames[index])
    index = math.max(index - 1, 1)
  end

  -- redo window position
  if option == 'redo' and index ~= nil then
    index = math.min(#frames, index + 1)
    module.setFrame(win, frames[index])
  end

  -- update window positions object
  windowPositions[appId] = {
    index  = index,
    frames = frames
  }

  hs.settings.set('windowPositions', windowPositions)
end

return module
