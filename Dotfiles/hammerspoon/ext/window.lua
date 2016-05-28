local activeScreen         = require('ext.screen').activeScreen
local application          = require('ext.application')
local bezel                = require('ext.drawing').bezel
local focusScreen          = require('ext.screen').focusScreen
local isSpaceFullscreenApp = require('ext.spaces').isSpaceFullscreenApp
local screenSpaces         = require('ext.spaces').screenSpaces
local spaceInDirection     = require('ext.spaces').spaceInDirection
local spaces               = require('hs._asm.undocumented.spaces')

local cache  = { mousePosition = nil }
local module = { cache = cache }

-- fullscreen toggle
module.fullscreen = function(win)
  win:setFullScreen(not win:isFullscreen())
end

-- move window to another space
module.moveToSpace = function(win, direction)
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
