-- extensions
local ext = {
  frame = {},
  win   = {},
  app   = {},
  utils = {},
  cache = {}
}

-- saved window positions
ext.cache.windowPositions = {}
ext.cache.mousePosition   = nil

-- extension settings
ext.win.animationDuration   = 0.15
ext.win.margin              = 8
ext.win.fixEnabled          = false
ext.win.fullFrame           = os.execute("ps xc | grep -q SIMBL") -- enable fullframe if SIMBL is runnig

-- hs settings
hs.window.animationDuration = ext.win.animationDuration
hs.hints.fontName           = "Helvetica-Bold"
hs.hints.fontSize           = 22
hs.hints.showTitleThresh    = 0
hs.hints.hintChars          = { "A", "S", "D", "F", "J", "K", "L", "Q", "W", "E", "R", "Z", "X", "C"  }

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
  local funcName  = ext.win.fullFrame and "fullFrame" or "frame"
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
function ext.win.pushAndNudge(win, options)
  local direction, value

  if type(options) == "table" then
    direction = options[1]
    value     = options[2] or 1 / 2
  else
    direction = options
    value     = 1 / 2
  end

  ext.win.push(win, direction, value)
  ext.win.nudge(win, direction)
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
  ext.win.center(win)
end

-- throw to next screen, center and fit
function ext.win.throw(win, direction)
  local winScreen       = win:screen()
  local frameFunc       = ext.win.fullFrame and "fullFrame" or "frame"
  local throwScreenFunc = {
    up    = "toNorth",
    down  = "toSouth",
    left  = "toWest",
    right = "toEast"
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

  -- center after setting frame, fixes terminal and macvim
  ext.win.center(win)
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
  local clickPoint = win:zoomButtonRect()
  local sleepTime  = 1000

  if clickPoint == nil then return end

  ext.cache.mousePosition = ext.cache.mousePosition or hs.mouse.getAbsolutePosition()

  clickPoint.x = clickPoint.x + clickPoint.w + 5
  clickPoint.y = clickPoint.y + clickPoint.h / 2

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()

  hs.timer.usleep(sleepTime)

  ext.utils.newKeyEvent({ ctrl = true }, space, true):post()
  ext.utils.newKeyEvent({ ctrl = true }, space, false):post()

  hs.timer.usleep(sleepTime)

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()

  hs.mouse.setAbsolutePosition(ext.cache.mousePosition)

  ext.cache.mousePosition = nil
end

-- save and restore window positions
function ext.win.pos(win, option)
  local id    = win:application():bundleID()
  local frame = win:frame()

  -- saves window position if not saved before
  if option == "save" and not ext.cache.windowPositions[id] then
    ext.cache.windowPositions[id] = frame
  end

  -- force update saved window position
  if option == "update" then
    ext.cache.windowPositions[id] = frame
  end

  -- restores window position
  if option == "load" and ext.cache.windowPositions[id] then
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
    up    = "focusWindowNorth",
    down  = "focusWindowSouth",
    left  = "focusWindowWest",
    right = "focusWindowEast"
  }

  hs.window[functions[direction]](win)
end

-- launch or focus or cycle app
function ext.app.launchOrFocus(app)
  local frontmostWindow = hs.window.frontmostWindow()
  local currentApp      = frontmostWindow and frontmostWindow:application():title() or nil

  if currentApp == app then
    if frontmostWindow then
      local appWindows     = frontmostWindow:application():allwindows()
      local visibleWindows = hs.fnutils.filter(appWindows, function(win) return win:isstandard() end)

      if #visibleWindows == 0 then
        -- try sending cmd-n for new window if no windows are visible
        -- this is due to some strange behavior of Finder
        -- actualy doesn't solve them, but sometimes helps
        ext.utils.newKeyEvent({ cmd = true }, "n", true):post()
        ext.utils.newKeyEvent({ cmd = true }, "n", false):post()
      else
        -- cycle windows if there are any
        ext.win.cycle(frontmostWindow)
      end
    end
  else
    application.launchOrFocus(app)
  end
end

-- smart app launch or focus or cycle windows
function ext.app.smartLaunchOrFocus(launchApps)
  local frontmostWindow = hs.window.frontmostWindow()
  local runningApps     = hs.application.runningApplications()
  local runningWindows  = {}

  -- filter running applications by apps array
  local runningApps = hs.fnutils.map(launchApps, function(launchApp)
    return hs.application.find(launchApp)
  end)

  -- create table of sorted windows per application
  hs.fnutils.each(runningApps, function(runningApp)
    local standardWindows = hs.fnutils.filter(runningApp:allWindows(), function(win)
      return win:isStandard()
    end)

    table.sort(standardWindows, function(a, b) return a:id() < b:id() end)

    hs.fnutils.each(standardWindows, function(window)
      table.insert(runningWindows, window)
    end)
  end)

  -- find if one of windows is already focused
  local currentIndex = hs.fnutils.indexOf(runningWindows, frontmostWindow)

  if #runningWindows == 0 then
    -- launch first application if there's no windows for any of them
    hs.application.launchOrFocus(launchApps[1])
  else
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

-- properly working newKeyEvent
-- https://github.com/nathyong/mjolnir.ny.tiling/blob/master/spaces.lua
function ext.utils.newKeyEvent(modifiers, key, pressed)
  local keyEvent

  keyEvent = hs.eventtap.event.newKeyEvent({}, "", pressed)
  keyEvent:setKeyCode(hs.keycodes.map[key])
  keyEvent:setFlags(modifiers)

  return keyEvent
end

-- reload hammerspoon config
function ext.utils.reloadConfig()
  hs.reload()

  hs.notify.new({
    title    = "Hammerspoon",
    subTitle = "Reloaded!"
  }):send()
end

-- apply function to a window with optional params, saving it's position for restore
function doWin(fn, ...)
  local win = hs.window.frontmostWindow()
  local arg = ...

  if #arg == 1 then arg = arg[1] end

  if win and not win:isFullScreen() then
    ext.win.pos(win, "save")
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

-- cycle between different window settings
function cycleWin(fn, options, settings)
  local setting = hs.fnutils.cycle(settings)
  return function() doWin(fn, { options, setting() }) end
end

-- keyboard modifiers for bindings
local mod = {
  cc  = { "cmd", "ctrl"         },
  ca  = { "cmd", "alt"          },
  cac = { "cmd", "alt", "ctrl"  },
  cas = { "cmd", "alt", "shift" }
}

-- basic bindings
hs.fnutils.each({
  { key = "c",     mod = mod.cc,  fn = bindWin(ext.win.center)        },
  { key = "z",     mod = mod.cc,  fn = bindWin(ext.win.full)          },
  { key = "s",     mod = mod.cc,  fn = bindWin(ext.win.pos, "update") },
  { key = "r",     mod = mod.cc,  fn = bindWin(ext.win.pos, "load")   },
  { key = "tab",   mod = mod.cc,  fn = bindWin(ext.win.cycle)         },
  { key = "space", mod = mod.cac, fn = hs.hints.windowHints           },
  { key = "/",     mod = mod.cac, fn = hs.openConsole                 }
}, function(object)
  hs.hotkey.bind(object.mod, object.key, object.fn)
end)

-- arrow bindings
hs.fnutils.each({ "up", "down", "left", "right" }, function(direction)
  local nudge = timeWin(ext.win.nudge, direction)

  hs.hotkey.bind(mod.cc,  direction, bindWin(ext.win.pushAndNudge, direction))
  hs.hotkey.bind(mod.ca,  direction, bindWin(ext.win.send, direction))
  hs.hotkey.bind(mod.cac, direction, function() nudge:start() end, function() nudge:stop() end)
  hs.hotkey.bind(mod.cas, direction, bindWin(ext.win.throw, direction))
end)

-- arrow bindings with "fn"
hs.fnutils.each({
  { key = "pageup",   direction = "up"    },
  { key = "pagedown", direction = "down"  },
  { key = "home",     direction = "left"  },
  { key = "end",      direction = "right" }
}, function(object)
  hs.hotkey.bind(mod.cc, object.key, bindWin(ext.win.focus, object.direction))
  hs.hotkey.bind(mod.ca, object.key, bindWin(ext.win.moveToSpace, object.direction))
end)

-- move window directly to space by number
hs.fnutils.each({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, function(space)
  hs.hotkey.bind(mod.cac, space, bindWin(ext.win.moveToSpace, space))
end)

-- set window sizes
hs.fnutils.each({
  { key = "1", w = 1400, h = 940 },
  { key = "2", w = 980,  h = 920 },
  { key = "3", w = 800,  h = 880 },
  { key = "4", w = 800,  h = 740 },
  { key = "5", w = 700,  h = 740 },
  { key = "6", w = 850,  h = 620 },
  { key = "7", w = 770,  h = 470 }
}, function(object)
  hs.hotkey.bind(mod.cc, object.key, bindWin(ext.win.setSize, { w = object.w, h = object.h }))
end)

-- launch and focus applications
hs.fnutils.each({
  { key = "b", apps = { "Safari", "Google Chrome" } },
  { key = "c", apps = { "Calendar"                } },
  { key = "f", apps = { "Finder"                  } },
  { key = "m", apps = { "Messages", "FaceTime"    } },
  { key = "n", apps = { "Notational Velocity"     } },
  { key = "p", apps = { "TaskPaper"               } },
  { key = "r", apps = { "Reminders"               } },
  { key = "s", apps = { "Slack", "Skype"          } },
  { key = "t", apps = { "iTerm", "Terminal"       } },
  { key = "v", apps = { "MacVim"                  } },
  { key = "x", apps = { "Xcode"                   } }
}, function(object)
  hs.hotkey.bind(mod.cac, object.key, function() ext.app.smartLaunchOrFocus(object.apps) end)
end)

-- autoreload hammerspoon
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", ext.utils.reloadConfig):start()
