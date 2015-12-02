local spaces      = require('hs._asm.undocumented.spaces')
local framed      = require('ext.framed')
local application = require('ext.application')

local cache = {
  mousePosition = nil
}

local module = {}

-- get screen frame
function module.screenFrame(win)
  local funcName  = window.fullFrame and 'fullFrame' or 'frame'
  local winScreen = win:screen()

  return winScreen[funcName](winScreen)
end

-- set frame
function module.setFrame(win, frame, time)
  win:setFrame(frame, time or hs.window.animationDuration)
end

-- ugly fix for problem with window height when it's as big as screen
function module.fixFrame(win)
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
function module.push(win, direction, value)
  local screen = module.screenFrame(win)
  local frame

  frame = framed.push(screen, direction, value)

  module.fixFrame(win)
  module.setFrame(win, frame)
end

-- nudges window in direction
function module.nudge(win, direction)
  local screen = module.screenFrame(win)
  local frame  = win:frame()

  frame = framed.nudge(frame, screen, direction)
  module.setFrame(win, frame, 0.05)
end

-- push and nudge window in direction
function module.pushAndSend(win, options)
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
function module.send(win, direction)
  local screen = module.screenFrame(win)
  local frame  = win:frame()

  frame = framed.send(frame, screen, direction)

  module.fixFrame(win)
  module.setFrame(win, frame)
end

-- centers window
function module.center(win)
  local screen = module.screenFrame(win)
  local frame  = win:frame()

  frame = framed.center(frame, screen)
  module.setFrame(win, frame)
end

-- fullscreen window with margin
function module.fullscreen(win)
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
function module.setSize(win, size)
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
function module.focus(win, direction)
  local functions = {
    up    = 'focusWindowNorth',
    down  = 'focusWindowSouth',
    left  = 'focusWindowWest',
    right = 'focusWindowEast'
  }

  hs.window[functions[direction]](win)
end

-- throw to screen in direction, center and fit
function module.throwToScreen(win, direction)
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
function module.moveToSpace(win, space)
  local clickPoint = win:zoomButtonRect()
  local sleepTime  = 1000

  if clickPoint == nil then return end

  cache.mousePosition = cache.mousePosition or hs.mouse.getAbsolutePosition()

  clickPoint.x = clickPoint.x + clickPoint.w + 5
  clickPoint.y = clickPoint.y + clickPoint.h / 2

  -- fix for Chrome UI
  if win:application():title() == 'Google Chrome' then
    clickPoint.y = clickPoint.y - clickPoint.h
  end

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()
  hs.timer.usleep(sleepTime)

  hs.eventtap.keyStroke({ 'ctrl' }, space)

  -- wait to finish animation
  while (spaces.isAnimating()) do end

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()

  hs.mouse.setAbsolutePosition(cache.mousePosition)
  cache.mousePosition = nil
end

-- cycle application windows
function module.cycleWindows(win, appWindowsOnly)
  local allWindows = appWindowsOnly and win:application():allWindows() or hs.window.allWindows()

  -- we only care about standard windows
  local standardWindows = hs.fnutils.filter(allWindows, function(win)
    return win:isStandard()
  end)

  if #standardWindows == 1 then
    -- if we have only one window - focus it
    standardWindows[1]:focus()
  elseif #standardWindows > 1 then
    -- if there are more than one, sort them first by id
    table.sort(standardWindows, function(a, b) return a:id() < b:id() end)

    -- check if one of them is active
    local activeWindowIndex = hs.fnutils.indexOf(standardWindows, win)

    if activeWindowIndex then
      -- if it is, then focus next one
      activeWindowIndex = activeWindowIndex + 1

      if activeWindowIndex > #standardWindows then activeWindowIndex = 1 end

      standardWindows[activeWindowIndex]:focus()
    else
      -- otherwise focus first one
      standardWindows[1]:focus()
    end
  end
end

-- save and restore window positions
function module.persistPosition(win, option)
  local appId           = win:application():bundleID()
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
