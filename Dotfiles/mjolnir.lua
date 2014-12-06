local application = require "mjolnir.application"
local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local fnutils = require "mjolnir.fnutils"
local timer = require "mjolnir._asm.timer"
local notification = require "mjolnir._asm.ui.notification"
local transform = require "mjolnir.sk.transform"

-- extensions
local ext = {
  frame = {},
  win = {},
  app = {},
  utils = {}
}

-- window extension settings
ext.win.margin     = 10
ext.win.positions  = {}
ext.win.animate    = true
ext.win.fixenabled = false

-- returns frame pushed to screen edge
function ext.frame.push(screen, direction)
  local frames = {
    [ "up" ] = function()
      return {
        x = ext.win.margin + screen.x,
        y = ext.win.margin + screen.y,
        w = screen.w - ext.win.margin * 2,
        h = screen.h / 2 - ext.win.margin
      }
    end,

    [ "down" ] = function()
      return {
        x = ext.win.margin + screen.x,
        y = ext.win.margin * 3 / 4 + screen.h / 2 + screen.y,
        w = screen.w - ext.win.margin * 2,
        h = screen.h / 2 - ext.win.margin * (2 - 1 / 4)
      }
    end,

    [ "left" ] = function()
      return {
        x = ext.win.margin + screen.x,
        y = ext.win.margin + screen.y,
        w = screen.w / 2 - ext.win.margin * (2 - 1 / 4),
        h = screen.h - ext.win.margin * (2 - 1 / 4)
      }
    end,

    [ "right" ] = function()
      return {
        x = ext.win.margin / 2 + screen.w / 2 + screen.x,
        y = ext.win.margin + screen.y,
        w = screen.w / 2 - ext.win.margin * (2 - 1 / 4),
        h = screen.h - ext.win.margin * (2 - 1 / 4)
      }
    end
	}

  return frames[direction]()
end

-- returns frame moved by ext.win.margin
function ext.frame.nudge(frame, screen, direction)
  local modifyframe = {
    [ "up" ] = function(frame)
      frame.y = math.max(screen.y + ext.win.margin, frame.y - ext.win.margin)
      return frame
    end,

    [ "down" ] = function(frame)
      frame.y = math.min(screen.y + screen.h - frame.h - ext.win.margin * 3 / 4, frame.y + ext.win.margin)
      return frame
    end,

    [ "left" ] = function(frame)
      frame.x = math.max(screen.x + ext.win.margin, frame.x - ext.win.margin)
      return frame
    end,

    [ "right" ] = function(frame)
      frame.x = math.min(screen.x + screen.w - frame.w - ext.win.margin, frame.x + ext.win.margin)
      return frame
    end
  }

  return modifyframe[direction](frame)
end

-- returns frame sent to screen edge
function ext.frame.send(frame, screen, direction)
  local modifyframe = {
    [ "up" ] = function(frame)
      frame.y = screen.y + ext.win.margin
      return frame
    end,

    [ "down" ] = function(frame)
      frame.y = screen.y + screen.h - frame.h - ext.win.margin * 3 / 4
      return frame
    end,

    [ "left" ] = function(frame)
      frame.x = screen.x + ext.win.margin
      return frame
    end,

    [ "right" ] = function(frame)
      frame.x = screen.x + screen.w - frame.w - ext.win.margin
      return frame
    end
  }

  return modifyframe[direction](frame)
end

-- returns frame fited inside screen
function ext.frame.fit(frame, screen)
  frame.w = math.min(frame.w, screen.w - ext.win.margin * 2)
  frame.h = math.min(frame.h, screen.h - ext.win.margin * (2 - 1 / 4))

  return frame
end

-- returns frame centered inside screen
function ext.frame.center(frame, screen)
  frame.x = screen.w / 2 - frame.w / 2 + screen.x
  frame.y = screen.h / 2 - frame.h / 2 + screen.y

  return frame
end

-- set frame
function ext.win.set(win, frame, time)
  time = time or 0.15

  if ext.win.animate then
    transform:setframe(win, frame, time)
  else
    win:setframe(frame)
  end
end

-- ugly fix for problem with window height when it's as big as screen
function ext.win.fix(win)
  if ext.win.fixenabled then
    local screen = win:screen():frame()
    local frame = win:frame()

    if (frame.h > (screen.h - ext.win.margin * (2 - 1 / 4))) then
      frame.h = screen.h - ext.win.margin * 10
      ext.win.set(win, frame)
    end
  end
end

-- pushes window in direction
function ext.win.push(win, direction)
  local screen = win:screen():frame()
  local frame

  frame = ext.frame.push(screen, direction)

  ext.win.fix(win)
  ext.win.set(win, frame)
end

-- nudges window in direction
function ext.win.nudge(win, direction)
  local screen = win:screen():frame()
  local frame = win:frame()

  frame = ext.frame.nudge(frame, screen, direction)
  ext.win.set(win, frame, 0.05)
end

-- push and nudge window in direction
function ext.win.pushandnudge(win, direction)
  ext.win.push(win, direction)
  ext.win.nudge(win, direction)
end

-- sends window in direction
function ext.win.send(win, direction)
  local screen = win:screen():frame()
  local frame = win:frame()

  frame = ext.frame.send(frame, screen, direction)

  ext.win.fix(win)
  ext.win.set(win, frame)
end

-- centers window
function ext.win.center(win)
  local screen = win:screen():frame()
  local frame = win:frame()

  frame = ext.frame.center(frame, screen)
  ext.win.set(win, frame)
end

-- fullscreen window with ext.win.margin
function ext.win.full(win)
  local screen = win:screen():frame()
  local frame = {
    x = ext.win.margin + screen.x,
    y = ext.win.margin + screen.y,
    w = screen.w - ext.win.margin * 2,
    h = screen.h - ext.win.margin * (2 - 1 / 4)
  }

  -- ext.win.fix(win)
  ext.win.set(win, frame)

  -- center after setting frame, fixes terminal
  ext.win.center(win)
end

-- throw to next screen, center and fit
function ext.win.throw(win, direction)
  local screen

  if (direction == "next") then
    screen = win:screen():next():frame()
  else
    screen = win:screen():previous():frame()
  end

  local frame = win:frame()

  frame.x = screen.x
  frame.y = screen.y

  frame = ext.frame.fit(frame, screen)
  frame = ext.frame.center(frame, screen)

  ext.win.fix(win)
  ext.win.set(win, frame)

  win:focus()

  -- center after setting frame, fixes terminal and macvim
  ext.win.center(win)
end

-- set window size and center
function ext.win.size(win, size)
  local screen = win:screen():frame()
  local frame = win:frame()

  frame.w = size.w
  frame.h = size.h

  frame = ext.frame.fit(frame, screen)
  frame = ext.frame.center(frame, screen)

  ext.win.set(win, frame)
end

-- save and restore window positions
function ext.win.pos(win, option)
  local id = win:application():bundleid()
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
    ext.win.set(win, ext.win.positions[id])
  end
end

-- cycle application windows
-- originally stolen: https://github.com/nifoc/dotfiles/blob/master/hydra/cycle.lua
function ext.win.cycle(win)
  local windows = win:application():allwindows()
  windows = fnutils.filter(windows, function(win) return win:isstandard() end)

  if #windows >= 2 then
    table.sort(windows, function(a, b) return a:id() < b:id() end)
    local activewindowindex = fnutils.indexof(windows, win)

    if activewindowindex then
      activewindowindex = activewindowindex + 1
      if activewindowindex > #windows then activewindowindex = 1 end

      windows[activewindowindex]:focus()
    end
  end
end

-- smart browser launch or focus or cycle
ext.app.browser = function()
  local browsers = { "Safari", "Google Chrome" }

  local runningapps = application.runningapplications()
  local currentapp = window.focusedwindow()

  if currentapp then currentapp = currentapp:application():title() end

  local runningbrowsers = fnutils.map(browsers, function(browser)
    return fnutils.find(runningapps, function(app)
      return app:title() == browser
    end)
  end)

  local currentindex = fnutils.indexof(fnutils.map(runningbrowsers, function(app)
    return app:title()
  end), currentapp)

  if #runningbrowsers == 0 then
    -- no browsers, start first one
    application.launchorfocus(browsers[1])
  elseif #runningbrowsers > 0 and not currentindex then
    -- no browser is selected, activate one
    runningbrowsers[1]:activate()
  elseif #runningbrowsers > 0 and currentindex then
    -- more than one browser and one of them selected, cycle them
    local browserindex = (currentindex % #runningbrowsers) + 1
    runningbrowsers[browserindex]:activate()
  end
end

-- launch or focus or cycle app
ext.app.launchorfocus = function(app)
  local focusedwindow = window.focusedwindow()
  local currentapp = nil

  if window then currentapp = focusedwindow:application():title() end

  if currentapp == app then
    ext.win.cycle(focusedwindow)
  else
    application.launchorfocus(app)
  end
end

-- apply function to a window with optional params, saving it's position for restore
function dowin(fn, param)
  local win = window.focusedwindow()

  if win and not win:isfullscreen() then
    ext.win.pos(win, "save")
    fn(win, param)
  end
end

-- for simple hotkey binding
function bindwin(fn, param)
  return function()
    dowin(fn, param)
  end
end

-- apply function to a window with a timer
function timewin(fn, param)
  return timer.new(0.05, function()
    dowin(fn, param)
  end)
end

-- keyboard modifier for bindings
local mod1 = { "cmd", "ctrl" }
local mod2 = { "cmd", "alt" }
local mod3 = { "cmd", "alt", "ctrl" }
local mod4 = { "cmd", "alt", "shift" }

-- basic bindings
hotkey.bind(mod1, "c",   bindwin(ext.win.center))
hotkey.bind(mod1, "z",   bindwin(ext.win.full))
hotkey.bind(mod1, "s",   bindwin(ext.win.pos, "update"))
hotkey.bind(mod1, "r",   bindwin(ext.win.pos, "load"))

-- cycle throught windows of the same app
hotkey.bind(mod1, "tab",   function() ext.win.cycle(window.focusedwindow()) end)

-- move window to different screen
hotkey.bind(mod4, "right", bindwin(ext.win.throw, "prev"))
hotkey.bind(mod4, "left",  bindwin(ext.win.throw, "next"))

-- push to edges and nudge
fnutils.each({ "up", "down", "left", "right" }, function(direction)
  local nudge = timewin(ext.win.nudge, direction)

  hotkey.bind(mod1, direction, bindwin(ext.win.pushandnudge, direction))
  hotkey.bind(mod2, direction, function() nudge:start() end, function() nudge:stop() end)
  hotkey.bind(mod3, direction, bindwin(ext.win.send, direction))
end)

-- set window sizes
fnutils.each({
  { key = "1", w = 1400, h = 940 },
  { key = "2", w = 980,  h = 920 },
  { key = "3", w = 800,  h = 880 },
  { key = "4", w = 800,  h = 740 },
  { key = "5", w = 700,  h = 740 },
  { key = "6", w = 850,  h = 620 },
  { key = "7", w = 770,  h = 470 }
}, function(object)
  hotkey.bind(mod1, object.key, bindwin(ext.win.size, { w = object.w, h = object.h }))
end)

-- launch and focus applications
fnutils.each({
  { key = "c", app = "Calendar" },
  { key = "f", app = "Finder" },
  { key = "n", app = "Notational Velocity" },
  { key = "p", app = "TaskPaper" },
  { key = "r", app = "Reminders" },
  { key = "t", app = "Terminal" }
}, function(object)
  hotkey.bind(mod3, object.key, function() ext.app.launchorfocus(object.app) end)
end)

-- launch or focus browser in a smart way
hotkey.bind(mod3, "b", function() ext.app.browser() end)

-- reload mjolnir
hotkey.bind(mod3, "m", function() mjolnir.reload() end)
