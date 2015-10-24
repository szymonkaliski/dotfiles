spaces = require('hs._asm.undocumented.spaces')

-- extensions, available in hammerspoon console
ext = {
  frame    = {},
  win      = {},
  app      = {},
  utils    = {},
  cache    = {},
  watchers = {}
}

-- saved window positions
ext.cache.windowPositions   = {}
ext.cache.mousePosition     = nil

-- saved battery status
ext.cache.batteryCharged    = hs.battery.isCharged()
ext.cache.batteryPercentage = hs.battery.percentage()
ext.cache.powerSource       = hs.battery.powerSource()

-- saved timers
ext.cache.launchTimer       = nil

-- saved space drawings
ext.cache.spaces            = {}

-- extension settings
ext.win.animationDuration   = 0.15
ext.win.margin              = 6
ext.win.fixEnabled          = false
ext.win.fullFrame           = true

-- hs settings
hs.window.animationDuration = ext.win.animationDuration
hs.hints.fontName           = 'Helvetica-Bold'
hs.hints.fontSize           = 22
hs.hints.showTitleThresh    = 0
hs.hints.hintChars          = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }

-- returns frame pushed to screen edge
function ext.frame.push(screen, direction, value)
  local m = ext.win.margin
  local h = screen.h - m
  local w = screen.w - m
  local x = screen.x + m
  local y = screen.y + m
  local v = value

  local frames = {
    up = function()
      return {
        x = x,
        y = y,
        w = w - m,
        h = h * v - m
      }
    end,

    down = function()
      return {
        x = x,
        y = y + h * (1 - v) - m,
        w = w - m,
        h = h * v - m
      }
    end,

    left = function()
      return {
        x = x,
        y = y,
        w = w * v - m,
        h = h - m
      }
    end,

    right = function()
      return {
        x = x + w * (1 - v) - m,
        y = y,
        w = w * v - m,
        h = h - m
      }
    end
  }

  return frames[direction]()
end

-- returns frame moved by ext.win.margin
function ext.frame.nudge(frame, screen, direction)
  local m = ext.win.margin
  local h = screen.h - m
  local w = screen.w - m
  local x = screen.x + m
  local y = screen.y + m

  local modifyFrame = {
    up = function(frame)
      frame.y = math.max(y, frame.y - m)
      return frame
    end,

    down = function(frame)
      frame.y = math.min(y + h - frame.h - m, frame.y + m)
      return frame
    end,

    left = function(frame)
      frame.x = math.max(x, frame.x - m)
      return frame
    end,

    right = function(frame)
      frame.x = math.min(x + w - frame.w - m, frame.x + m)
      return frame
    end
  }

  return modifyFrame[direction](frame)
end

-- returns frame sent to screen edge
function ext.frame.send(frame, screen, direction)
  local m = ext.win.margin
  local h = screen.h - m
  local w = screen.w - m
  local x = screen.x + m
  local y = screen.y + m

  local modifyFrame = {
    up    = function(frame) frame.y = y end,
    down  = function(frame) frame.y = y + h - frame.h - m end,
    left  = function(frame) frame.x = x end,
    right = function(frame) frame.x = x + w - frame.w - m end
  }

  modifyFrame[direction](frame)
  return frame
end

-- returns frame fited inside screen
function ext.frame.fit(frame, screen)
  frame.w = math.min(frame.w, screen.w - ext.win.margin * 2)
  frame.h = math.min(frame.h, screen.h - ext.win.margin * 2)

  return frame
end

-- returns frame centered inside screen
function ext.frame.center(frame, screen)
  frame.x = screen.w / 2 - frame.w / 2 + screen.x
  frame.y = screen.h / 2 - frame.h / 2 + screen.y

  return frame
end

-- get screen frame
function ext.win.screenFrame(win)
  local funcName  = ext.win.fullFrame and 'fullFrame' or 'frame'
  local winScreen = win:screen()

  return winScreen[funcName](winScreen)
end

-- set frame
function ext.win.setFrame(win, frame, time)
  win:setFrame(frame, time or ext.win.animationDuration)
end

-- ugly fix for problem with window height when it's as big as screen
function ext.win.fix(win)
  if ext.win.fixEnabled then
    local screen = ext.win.screenFrame(win)
    local frame  = win:frame()

    if (frame.h > (screen.h - ext.win.margin * 2)) then
      frame.h = screen.h - ext.win.margin * 10
      ext.win.setFrame(win, frame)
    end
  end
end

-- pushes window in direction
function ext.win.push(win, direction, value)
  local screen = ext.win.screenFrame(win)
  local frame

  frame = ext.frame.push(screen, direction, value)

  ext.win.fix(win)
  ext.win.setFrame(win, frame)
end

-- nudges window in direction
function ext.win.nudge(win, direction)
  local screen = ext.win.screenFrame(win)
  local frame  = win:frame()

  frame = ext.frame.nudge(frame, screen, direction)
  ext.win.setFrame(win, frame, 0.05)
end

-- push and nudge window in direction
function ext.win.pushAndSend(win, options)
  local direction, value

  if type(options) == 'table' then
    direction = options[1]
    value     = options[2] or 1 / 2
  else
    direction = options
    value     = 1 / 2
  end

  ext.win.push(win, direction, value)

  hs.timer.doAfter(hs.window.animationDuration * 3 / 2, function()
    ext.win.send(win, direction)
  end)
end

-- sends window in direction
function ext.win.send(win, direction)
  local screen = ext.win.screenFrame(win)
  local frame  = win:frame()

  frame = ext.frame.send(frame, screen, direction)

  ext.win.fix(win)
  ext.win.setFrame(win, frame)
end

-- centers window
function ext.win.center(win)
  local screen = ext.win.screenFrame(win)
  local frame  = win:frame()

  frame = ext.frame.center(frame, screen)
  ext.win.setFrame(win, frame)
end

-- fullscreen window with margin
function ext.win.full(win)
  local screen = ext.win.screenFrame(win)
  local frame  = {
    x = ext.win.margin + screen.x,
    y = ext.win.margin + screen.y,
    w = screen.w - ext.win.margin * 2,
    h = screen.h - ext.win.margin * 2
  }

  ext.win.fix(win)
  ext.win.setFrame(win, frame)

  -- center after setting frame, fixes terminal
  hs.timer.doAfter(hs.window.animationDuration * 3 / 2, function()
    ext.win.center(win)
  end)
end

-- throw to next screen, center and fit
function ext.win.throw(win, direction)
  local winScreen       = win:screen()
  local frameFunc       = ext.win.fullFrame and 'fullFrame' or 'frame'
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

  frame = ext.frame.fit(frame, screenFrame)
  frame = ext.frame.center(frame, screenFrame)

  ext.win.fix(win)
  ext.win.setFrame(win, frame)

  win:focus()

  -- center after setting frame, fixes terminal
  hs.timer.doAfter(hs.window.animationDuration * 3 / 2, function()
    ext.win.center(win)
  end)
end

-- set window size and center
function ext.win.setSize(win, size)
  local screen = ext.win.screenFrame(win)
  local frame  = win:frame()

  frame.w = size.w
  frame.h = size.h

  frame = ext.frame.fit(frame, screen)
  frame = ext.frame.center(frame, screen)

  ext.win.setFrame(win, frame)
end

-- move window to another space
function ext.win.moveToSpace(win, space)
  local clickPoint    = win:zoomButtonRect()
  local sleepTime     = 1000
  local longSleepTime = 300000

  if clickPoint == nil then return end

  ext.cache.mousePosition = ext.cache.mousePosition or hs.mouse.getAbsolutePosition()

  clickPoint.x = clickPoint.x + clickPoint.w + 5
  clickPoint.y = clickPoint.y + clickPoint.h / 2

  -- fix for Chrome UI
  if win:application():title() == 'Google Chrome' then
    clickPoint.y = clickPoint.y - clickPoint.h
  end

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()

  hs.timer.usleep(sleepTime)

  hs.eventtap.keyStroke({ 'ctrl' }, space)

  hs.timer.usleep(longSleepTime)

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()

  hs.mouse.setAbsolutePosition(ext.cache.mousePosition)

  ext.cache.mousePosition = nil
end

-- save and restore window positions
function ext.win.pos(win, option)
  local id    = win:application():bundleID()
  local frame = win:frame()

  -- saves window position if not saved before
  if option == 'save' and not ext.cache.windowPositions[id] then
    ext.cache.windowPositions[id] = frame
  end

  -- force update saved window position
  if option == 'update' then
    ext.cache.windowPositions[id] = frame
  end

  -- restores window position
  if option == 'load' and ext.cache.windowPositions[id] then
    ext.win.setFrame(win, ext.cache.windowPositions[id])
  end
end

-- cycle application windows
-- https://github.com/nifoc/dotfiles/blob/master/mjolnir/cycle.lua
function ext.win.cycle(win)
  local standardWindows = hs.fnutils.filter(win:application():allWindows(), function(win)
    return win:isStandard()
  end)

  if #standardWindows >= 2 then
    table.sort(standardWindows, function(a, b) return a:id() < b:id() end)

    local activeWindowIndex = hs.fnutils.indexOf(standardWindows, win)

    if activeWindowIndex then
      activeWindowIndex = activeWindowIndex + 1

      if activeWindowIndex > #standardWindows then activeWindowIndex = 1 end

      standardWindows[activeWindowIndex]:focus()
    end
  end
end

-- focus window in direction
function ext.win.focus(win, direction)
  local functions = {
    up    = 'focusWindowNorth',
    down  = 'focusWindowSouth',
    left  = 'focusWindowWest',
    right = 'focusWindowEast'
  }

  hs.window[functions[direction]](win)
end

-- smart app launch or focus or cycle windows
function ext.app.smartLaunchOrFocus(launchApps)
  local frontmostWindow = hs.window.frontmostWindow()
  local runningApps     = hs.application.runningApplications()
  local runningWindows  = {}

  -- filter running applications by apps array
  local runningApps = hs.fnutils.map(launchApps, function(launchApp)
    return hs.application.get(launchApp)
  end)

  -- create table of sorted windows per application
  hs.fnutils.each(runningApps, function(runningApp)
    local standardWindows = hs.fnutils.filter(runningApp:allWindows(), function(win)
      return win:isStandard()
    end)

    table.sort(standardWindows, function(a, b) return a:id() < b:id() end)

    runningWindows = standardWindows
  end)

  if #runningWindows == 0 then
    -- launch first application if there's no windows for any of them
    hs.application.launchOrFocus(launchApps[1])

    -- clear timer if exists
    if ext.cache.launchTimer then ext.cache.launchTimer:stop() end

    -- wait 500ms for window to appear and try sending showing the window (cmd-n / cmd-0 or other)
    ext.cache.launchTimer = hs.timer.doAfter(0.5, function()
      local frontmostApp     = hs.application.frontmostApplication()
      local frontmostWindows = hs.fnutils.filter(frontmostApp:allWindows(), function(win) return win:isStandard() end)

      -- break if this app is not frontmost (when/why?)
      if frontmostApp:title() ~= launchApps[1] then return end

      if #frontmostWindows == 0 then
        -- check if there's app name in window menu (Calendar, Messages, etc...)
        if frontmostApp:findMenuItem({ 'Window', launchApps[1] }) then
          -- select it, usually moves to space with this window
          frontmostApp:selectMenuItem({ 'Window', launchApps[1] })
        else
          -- otherwise send cmd-n to create new window
          hs.eventtap.keyStroke({ 'cmd' }, 'n')
        end
      end
    end)
  else
    -- check if one of windows is already focused
    local currentIndex = hs.fnutils.indexOf(runningWindows, frontmostWindow)

    if not currentIndex then
      -- if none of them is selected focus the first one
      runningWindows[1]:focus()
    else
      -- otherwise cycle through all the windows
      local newIndex = currentIndex + 1
      if newIndex > #runningWindows then newIndex = 1 end

      runningWindows[newIndex]:focus()
    end
  end
end

-- toggle hammerspoon console refocusing window
function ext.utils.toggleConsole()
  hs.toggleConsole()

  local frontmostWindow = hs.window.frontmostWindow()
  if frontmostWindow then frontmostWindow:focus() end
end

-- reload hammerspoon config
function ext.utils.reloadConfig()
  -- stop watchers to avoid leaks
  hs.fnutils.each(ext.watchers, function(watcher) watcher:stop() end)

  hs.reload()

  hs.notify.new({
    title    = 'Hammerspoon',
    subTitle = 'Reloaded!'
  }):send()
end

-- apply function to a window with optional params, saving it's position for restore
function doWin(fn, ...)
  local win = hs.window.frontmostWindow()
  local arg = ...

  if #arg == 1 then arg = arg[1] end

  if win and not win:isFullScreen() then
    ext.win.pos(win, 'save')
    fn(win, arg)
  end
end

-- for simple hotkey binding
function bindWin(fn, ...)
  local arg = { ... }
  return function() doWin(fn, arg) end
end

-- apply function to a window with a timer
function timeWin(fn, ...)
  local arg = { ... }
  return hs.timer.new(0.05, function() doWin(fn, arg) end)
end

-- keyboard modifiers for bindings
local mod = {
  cc  = { 'cmd', 'ctrl'         },
  ca  = { 'cmd', 'alt'          },
  cac = { 'cmd', 'alt', 'ctrl'  },
  cas = { 'cmd', 'alt', 'shift' }
}

-- basic bindings
hs.fnutils.each({
  { key = 'c',     mod = mod.cc,  fn = bindWin(ext.win.center)        },
  { key = 'z',     mod = mod.cc,  fn = bindWin(ext.win.full)          },
  { key = 's',     mod = mod.cc,  fn = bindWin(ext.win.pos, 'update') },
  { key = 'r',     mod = mod.cc,  fn = bindWin(ext.win.pos, 'load')   },
  { key = 'tab',   mod = mod.cc,  fn = bindWin(ext.win.cycle)         },
  { key = 'space', mod = mod.cac, fn = hs.hints.windowHints           },
  { key = '/',     mod = mod.cac, fn = ext.utils.toggleConsole        }
}, function(object)
  hs.hotkey.bind(object.mod, object.key, object.fn)
end)

-- arrow bindings
hs.fnutils.each({ 'up', 'down', 'left', 'right' }, function(direction)
  local nudge = timeWin(ext.win.nudge, direction)

  hs.hotkey.bind(mod.cc,  direction, bindWin(ext.win.pushAndSend, direction))
  hs.hotkey.bind(mod.ca,  direction, bindWin(ext.win.send, direction))
  hs.hotkey.bind(mod.cac, direction, function() nudge:start() end, function() nudge:stop() end)
  hs.hotkey.bind(mod.cas, direction, bindWin(ext.win.throw, direction))
end)

-- arrow bindings with 'fn'
hs.fnutils.each({
  { key = 'pageup',   direction = 'up'    },
  { key = 'pagedown', direction = 'down'  },
  { key = 'home',     direction = 'left'  },
  { key = 'end',      direction = 'right' }
}, function(object)
  hs.hotkey.bind(mod.cc, object.key, bindWin(ext.win.focus, object.direction))
  hs.hotkey.bind(mod.ca, object.key, bindWin(ext.win.moveToSpace, object.direction))
end)

-- move window directly to space by number
hs.fnutils.each({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, function(space)
  -- NOTE: somehow binding this to pressedFn doesn't work!
  hs.hotkey.bind(mod.cac, space, nil, bindWin(ext.win.moveToSpace, space))
end)

-- set window sizes
hs.fnutils.each({
  { key = '1', w = 1400, h = 920 },
  { key = '2', w = 980,  h = 920 },
  { key = '3', w = 800,  h = 880 },
  { key = '4', w = 800,  h = 740 },
  { key = '5', w = 700,  h = 740 },
  { key = '6', w = 850,  h = 620 },
  { key = '7', w = 770,  h = 470 }
}, function(object)
  hs.hotkey.bind(mod.cc, object.key, bindWin(ext.win.setSize, { w = object.w, h = object.h }))
end)

-- launch and focus applications
hs.fnutils.each({
  { key = 'b', apps = { 'Safari', 'Google Chrome' } },
  { key = 'c', apps = { 'Calendar'                } },
  { key = 'f', apps = { 'Finder'                  } },
  { key = 'm', apps = { 'Messages', 'FaceTime'    } },
  { key = 'n', apps = { 'Notational Velocity'     } },
  { key = 'p', apps = { 'TaskPaper'               } },
  { key = 'r', apps = { 'Reminders'               } },
  { key = 's', apps = { 'Slack', 'Skype'          } },
  { key = 't', apps = { 'iTerm2', 'Terminal'      } },
  { key = 'v', apps = { 'MacVim'                  } },
  { key = 'x', apps = { 'Xcode'                   } }
}, function(object)
  hs.hotkey.bind(mod.cac, object.key, function() ext.app.smartLaunchOrFocus(object.apps) end)
end)

-- notify on power events
ext.watchers.battery = hs.battery.watcher.new(function()
  local imagePath         = os.getenv('HOME') .. '/.hammerspoon/battery.png'
  local batteryPercentage = hs.battery.percentage()
  local isCharged         = hs.battery.isCharged()
  local powerSource       = hs.battery.powerSource()

  if batteryPercentage < 100 then
    ext.cache.batteryCharged = false
  end

  if isCharged ~= ext.cache.batteryCharged and batteryPercentage == 100 then
    hs.notify.new({
      title        = 'Battery Status',
      subTitle     = 'Charged completely!',
      contentImage = hs.image.imageFromPath(imagePath)
    }):send()

    ext.cache.batteryCharged = true
  end

  if powerSource ~= ext.cache.powerSource then
    hs.notify.new({
      title        = 'Power Source Status',
      subTitle     = 'Current source: ' .. powerSource,
      contentImage = hs.image.imageFromPath(imagePath)
    }):send()

    ext.cache.powerSource = powerSource
  end
end):start()

-- notify on wifi connection status
ext.watchers.wifi = hs.wifi.watcher.new(function()
  local imagePath      = os.getenv('HOME') .. '/.hammerspoon/airport.png'
  local currentNetwork = hs.wifi.currentNetwork()
  local subTitle       = currentNetwork and 'Network: ' .. currentNetwork or 'Disconnected'

  hs.notify.new({
    title        = 'Wi-Fi Status',
    subTitle     = subTitle,
    contentImage = hs.image.imageFromPath(imagePath)
  }):send()
end):start()

-- application watcher
ext.watchers.apps = hs.application.watcher.new(function(name, event, app)
  if (event == hs.application.watcher.activated) then
    local appActions = {
      -- persistent mini player in iTunes
      iTunes = function(app)
        local state = app:findMenuItem({ 'Window', 'MiniPlayer' })

        if state and not state['ticked'] then
          app:selectMenuItem({ 'Window', 'MiniPlayer' })
        end
      end,

      -- always show all iTerm and Finder windows
      iTerm  = function(app) app:selectMenuItem({ 'Window', 'Bring All to Front' }) end,
      Finder = function(app) app:selectMenuItem({ 'Window', 'Bring All to Front' }) end
    }

    if appActions[name] then appActions[name](app) end
  end
end):start()

-- imitate ios dots for spaces
ext.utils.spacesDots = function()
  local spacesCount  = spaces.count()
  local currentSpace = spaces.currentSpace();
  local screenFrame  = hs.screen.allScreens()[1]:fullFrame()

  -- TODO: move to config on top
  local circleSize          = 8
  local circleDistance      = 16
  local circleSelectedAlpha = 0.45
  local circleAlpha         = 0.15

  -- init circles in cache
  if #ext.cache.spaces == 0 then
    for i = 1, 9 do
      local circle = hs.drawing.circle({ x = -10, y = -10, w = circleSize, h = circleSize })

      circle
        :setStroke(false)
        :setLevel(hs.drawing.windowLevels.desktopIcon) -- lay as high as icons (lower values disable clicking)
        :setBehaviorByLabels({ 'canJoinAllSpaces', 'stationary' }) -- stick to all spaces
        :setClickCallback(function() hs.eventtap.keyStroke({ 'ctrl' }, i) end) -- switch to space on click

      ext.cache.spaces[i] = circle
    end
  end

  -- update circles
  for i = 1, 9 do
    local circle = ext.cache.spaces[i]
    local x      = screenFrame.w / 2 - (spacesCount / 2) * circleDistance + i * circleDistance - circleSize
    local y      = screenFrame.h - circleDistance
    local alpha  = i == currentSpace and circleSelectedAlpha or circleAlpha

    circle
      :setTopLeft({ x = x, y = y })
      :setFillColor({ red = 1.0, green = 1.0, blue = 1.0, alpha = alpha })

    if i <= spacesCount then
      circle:show()
    else
      circle:hide()
    end
  end
end

-- setup dots on startup
ext.utils.spacesDots()

-- spaces watcher
ext.watchers.spaces = hs.spaces.watcher.new(ext.utils.spacesDots):start()

-- autoreload hammerspoon
ext.watchers.patchwatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', ext.utils.reloadConfig):start()
