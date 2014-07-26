-- watch for changes
pathwatcher.new(os.getenv("HOME") .. "/.hydra/", hydra.reload):start()

-- notify on start
notify.show("Hydra", "Started!", "", "")

-- extensions
ext.frame = {}
ext.win   = {}
ext.app   = {}

-- window margins and positions
ext.win.margin    = 10
ext.win.positions = {}

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

-- returns frame fited inside screen
function ext.frame.fit(screen, frame)
	frame.w = math.min(frame.w, screen.w - ext.win.margin * 2)
	frame.h = math.min(frame.h, screen.h - ext.win.margin * (2 - 1 / 4))

	return frame
end

-- returns frame centered inside screen
function ext.frame.center(screen, frame)
	frame.x = screen.w / 2 - frame.w / 2 + screen.x
	frame.y = screen.h / 2 - frame.h / 2 + screen.y

	return frame
end

-- ugly fix for problem with window height when it's as big as screen
function ext.win.fix(win)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = win:frame()

	if (frame.h > (screen.h - ext.win.margin * (2 - 1 / 4))) then
		frame.h = screen.h - ext.win.margin * 10
		win:setframe(frame)
	end
end

-- pushes window in direction
function ext.win.push(win, direction)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame

	frame = ext.frame.push(screen, direction)

	ext.win.fix(win)
	win:setframe(frame)
end

-- nudges window in direction
function ext.win.nudge(win, direction)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = win:frame()

	frame = ext.frame.nudge(frame, screen, direction)

	win:setframe(frame)
end

-- push and nudge window in direction
function ext.win.pushandnudge(win, direction)
	ext.win.push(win, direction)
	ext.win.nudge(win, direction)
end

-- centers window
function ext.win.center(win)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = win:frame()

	frame = ext.frame.center(screen, frame)

	win:setframe(frame)
end

-- fullscreen window with ext.win.margin
function ext.win.full(win)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = {
		x = ext.win.margin + screen.x,
		y = ext.win.margin + screen.y,
		w = screen.w - ext.win.margin * 2,
		h = screen.h - ext.win.margin * (2 - 1 / 4)
	}

	ext.win.fix(win)
	win:setframe(frame)
end

-- throw to next screen, center and fit
function ext.win.throw(win)
	local screen = win:screen():next():frame_without_dock_or_menu()
	local frame = win:frame()

	frame.x = screen.x
	frame.y = screen.y

	frame = ext.frame.fit(screen, frame)
	frame = ext.frame.center(screen, frame)

	ext.win.fix(win)
	win:setframe(frame)
	win:focus()
end

-- set window size and center
function ext.win.size(win, size)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = win:frame()

	frame.w = size.w
	frame.h = size.h

	frame = ext.frame.fit(screen, frame)
	frame = ext.frame.center(screen, frame)

	win:setframe(frame)
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
		win:setframe(ext.win.positions[id])
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

-- smart browser launch or focus
ext.app.browser = function()
	local browsers = { "Safari", "Google Chrome" }
	local runningapps = application.runningapplications()

	local runningbrowsers = fnutils.map(browsers, function(browser)
		return fnutils.find(runningapps, function(app)
			return app:title() == browser
		end)
	end)

	if #runningbrowsers > 0 then
		runningbrowsers[1]:activate()
	else
		application.launchorfocus(browsers[1])
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
	return timer.new(0.1, function()
		dowin(fn, param)
	end)
end

-- keyboard modifier for bindings
local mod1 = { "cmd", "ctrl" }
local mod2 = { "cmd", "ctrl", "alt" }

-- basic bindings
hotkey.bind(mod1, "c",   bindwin(ext.win.center))
hotkey.bind(mod1, "z",   bindwin(ext.win.full))
hotkey.bind(mod1, "s",   bindwin(ext.win.pos, "update"))
hotkey.bind(mod1, "r",   bindwin(ext.win.pos, "load"))
hotkey.bind(mod1, "w",   bindwin(ext.win.cycle))
hotkey.bind(mod1, "tab", bindwin(ext.win.throw))

-- push to edges and nudge
fnutils.each({ "up", "down", "left", "right" }, function(direction)
	local nudge = timewin(ext.win.nudge, direction)

	hotkey.bind(mod1, direction, bindwin(ext.win.pushandnudge, direction))
	hotkey.bind(mod2, direction, function() nudge:start() end, function() nudge:stop() end)
end)

-- set window sizes
fnutils.each({
	{ key = 1, w = 1400, h = 940 },
	{ key = 2, w = 980,  h = 920 },
	{ key = 3, w = 800,  h = 880 },
	{ key = 4, w = 800,  h = 740 },
	{ key = 5, w = 760,  h = 620 },
	{ key = 6, w = 770,  h = 470 }
}, function(object)
	hotkey.bind(mod1, object.key, bindwin(ext.win.size, { w = object.w, h = object.h }))
end)

-- launch and focus applications
fnutils.each({
	{ key = "t", app = "Terminal" },
	{ key = "f", app = "Finder" },
	{ key = "n", app = "Notational Velocity" },
	{ key = "p", app = "TaskPaper" },
	{ key = "m", app = "MacVim" }
}, function(object)
	hotkey.bind(mod2, object.key, function() application.launchorfocus(object.app) end)
end)

-- launch or focus browser in a smart way
hotkey.bind(mod2, "b", function() ext.app.browser() end)
