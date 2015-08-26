-- extensions
local ext = {
  frame = {},
  win   = {},
  app   = {},
  utils = {}
}

-- saved window positions
ext.win.positions = {}

-- window extension settings
ext.win.animationDuration   = 0.15
ext.win.margin              = 8
ext.win.fixEnabled          = false
ext.win.fullFrame           = os.execute("ps xc | grep -q SIMBL") -- enable fullframe if SIMBL is runnig

-- hs settings
hs.window.animationDuration = ext.win.animationDuration
hs.hints.showTitleThresh    = 0

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
  local funcName  = ext.win.fullFrame and "fullframe" or "frame"
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
    value    = 1 / 2
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
  local frameFunc   = ext.win.fullFrame and "fullFrame" or "frame"

  local winScreen   = win:screen()
  local throwScreen = direction == "next" and winScreen:toWest() or winScreen:toEast()

  if throwScreen == nil then return end

  local frame       = win:frame()
  local screenFrame = hs.screen[frameFunc](throwScreen)

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

-- save and restore window positions
function ext.win.pos(win, option)
  local id    = win:application():bundleID()
  local frame = win:frame()

  -- saves window position if not saved before
  if option == "save" and not ext.win.positions[id] then
    ext.win.positions[id] = frame
  end

  -- force update saved window position
  if option == "update" then
    ext.win.positions[id] = frame
  end

  -- restores window position
  if option == "load" and ext.win.positions[id] then
    ext.win.setFrame(win, ext.win.positions[id])
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

-- launch or focus or cycle app
function ext.app.launchOrFocus(app)
  local focusedWindow = hs.window.focusedWindow()
  local currentApp    = focusedWindow and focusedWindow:application():title() or nil

  if currentApp == app then
    if focusedWindow then
      local appWindows     = focusedWindow:application():allwindows()
      local visibleWindows = hs.fnutils.filter(appWindows, function(win) return win:isstandard() end)

      if #visibleWindows == 0 then
        -- try sending cmd-n for new window if no windows are visible
        -- this is due to some strange behavior of Finder
        -- actualy doesn't solve them, but sometimes helps
        ext.utils.newKeyEvent({ cmd = true }, "n", true):post()
        ext.utils.newKeyEvent({ cmd = true }, "n", false):post()
      else
        -- cycle windows if there are any
        ext.win.cycle(focusedWindow)
      end
    end
  else
    application.launchOrFocus(app)
  end
end

-- smart app launch or focus or cycle windows
function ext.app.smartLaunchOrFocus(launchApps)
  local focusedWindow  = hs.window.focusedWindow()
  local runningApps    = hs.application.runningApplications()
  local runningWindows = {}

  -- filter running applications by apps array
  local runningApps = hs.fnutils.map(launchApps, function(launchApp)
    return hs.appfinder.appFromName(launchApp)
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
  local currentIndex = hs.fnutils.indexOf(runningWindows, focusedWindow)

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

  keyEvent = eventtap.event.newKeyEvent({}, "", pressed)
  keyEvent:setkeycode(keycodes.map[key])
  keyEvent:setflags(modifiers)

  return keyEvent
end

-- apply function to a window with optional params, saving it's position for restore
function doWin(fn, ...)
  local win = hs.window.focusedWindow()
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

-- keyboard modifier for bindings
local mod1 = { "cmd", "ctrl"         }
local mod2 = { "cmd", "alt"          }
local mod3 = { "cmd", "alt", "ctrl"  }
local mod4 = { "cmd", "alt", "shift" }

-- basic bindings
hs.hotkey.bind(mod1, "c", bindWin(ext.win.center))
hs.hotkey.bind(mod1, "z", bindWin(ext.win.full))
hs.hotkey.bind(mod1, "s", bindWin(ext.win.pos, "update"))
hs.hotkey.bind(mod1, "r", bindWin(ext.win.pos, "load"))

-- cycle throught windows of the same app
hs.hotkey.bind(mod1, "tab", function() ext.win.cycle(hs.window.focusedWindow()) end)

-- move window to different screen
hs.hotkey.bind(mod4, "right", bindWin(ext.win.throw, "prev"))
hs.hotkey.bind(mod4, "left",  bindWin(ext.win.throw, "next"))

-- push to edges and nudge
hs.fnutils.each({ "up", "down", "left", "right" }, function(direction)
  local nudge = timeWin(ext.win.nudge, direction)

  hs.hotkey.bind(mod1, direction, bindWin(ext.win.pushAndNudge, direction))
  hs.hotkey.bind(mod2, direction, bindWin(ext.win.send, direction))
  hs.hotkey.bind(mod3, direction, function() nudge:start() end, function() nudge:stop() end)
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
  hs.hotkey.bind(mod1, object.key, bindWin(ext.win.setSize, { w = object.w, h = object.h }))
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
  { key = "t", apps = { "Terminal"                } },
  { key = "v", apps = { "MacVim"                  } },
  { key = "x", apps = { "Xcode"                   } }
}, function(object)
  hs.hotkey.bind(mod3, object.key, function() ext.app.smartLaunchOrFocus(object.apps) end)
end)

-- show hints
hs.hotkey.bind(mod4, "h", function() hs.hints.windowHints() end)

-- reload hammerspoon
hs.hotkey.bind(mod4, "r", function() hs.reload() end)
