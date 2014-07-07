-- autostart hydra
autolaunch.set(true)

-- watch for changes
-- pathwatcher.new(os.getenv("HOME") .. "/.hydra/", hydra.reload):start()

-- notify on start
notify.show("Hydra", "Started!", "", "")

-- extension for frame
ext.frame = {}

-- window margin
local margin = 10

-- returns frame pushed to screen edge
function ext.frame.push(screen, direction)
	local frames = {
		[ "up" ] = function()
			return {
				x = margin + screen.x,
				y = margin + screen.y,
				w = screen.w - margin * 2,
				h = screen.h / 2 - margin
			}
		end,

		[ "down" ] = function()
			return {
				x = margin + screen.x,
				y = margin * 3 / 4 + screen.h / 2 + screen.y,
				w = screen.w - margin * 2,
				h = screen.h / 2 - margin * (2 - 1 / 4)
			}
		end,

		[ "left" ] = function()
			return {
				x = margin + screen.x,
				y = margin + screen.y,
				w = screen.w / 2 - margin * (2 - 1 / 4),
				h = screen.h - margin * (2 - 1 / 4)
			}
		end,

		[ "right" ] = function()
			return {
				x = margin / 2 + screen.w / 2 + screen.x,
				y = margin + screen.y,
				w = screen.w / 2 - margin * (2 - 1 / 4),
				h = screen.h - margin * (2 - 1 / 4)
			}
		end
	}

	return frames[direction]()
end

-- returns frame moved by margin
function ext.frame.nudge(frame, screen, direction)
	local modifyframe = {
		[ "up" ] = function(frame)
			frame.y = math.max(screen.y + margin, frame.y - margin)
			return frame
		end,

		[ "down" ] = function(frame)
			frame.y = math.min(screen.y + screen.h - frame.h - margin * 3 / 4, frame.y + margin)
			return frame
		end,

		[ "left" ] = function(frame)
			frame.x = math.max(screen.x + margin, frame.x - margin)
			return frame
		end,

		[ "right" ] = function(frame)
			frame.x = math.min(screen.x + screen.w - frame.w - margin, frame.x + margin)
			return frame
		end
	}

	return modifyframe[direction](frame)
end

-- window extension
ext.win = {}

-- ugly fix for problem with window height when it's as big as screen
function ext.win.fix(win)
	local frame = win:frame()
	local screen = win:screen():frame_without_dock_or_menu()

	if (frame.h > (screen.h - margin * (2 - 1 / 4))) then
		frame.h = screen.h - margin * 10
		win:setframe(frame)
	end
end

-- pushes window in direction and nudges to edge, fixes terminal positioning
function ext.win.push(win, direction)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = win:frame()

	ext.win.fix(win)

	frame = ext.frame.push(screen, direction)
	frame = ext.frame.nudge(frame, screen, direction)

	win:setframe(frame)
end

-- nudges window in direction
function ext.win.nudge(win, direction)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = win:frame()

	frame = ext.frame.nudge(frame, screen, direction)

	win:setframe(frame)
end

-- returns frame fited inside screen
function ext.frame.fit(screen, frame)
	frame.w = math.min(frame.w, screen.w - margin * 2)
	frame.h = math.min(frame.h, screen.h - margin * (2 - 1 / 4))

	return frame
end

-- returns frame centered inside screen
function ext.frame.center(screen, frame)
	frame.x = screen.w / 2 - frame.w / 2 + screen.x
	frame.y = screen.h / 2 - frame.h / 2 + screen.y

	return frame
end

-- centers window
function ext.win.center(win)
	local screen = win:screen():frame_without_dock_or_menu()
	local frame = win:frame()

	frame = ext.frame.center(screen, frame)

	win:setframe(frame)
end

-- fullscreen window with margin
function ext.win.full(win)
	local screen = win:screen():frame_without_dock_or_menu()

	frame = {
		x = margin + screen.x,
		y = margin + screen.y,
		w = screen.w - margin * 2,
		h = screen.h - margin * (2 - 1 / 4)
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

	ext.win.fix(win)

	frame = ext.frame.fit(screen, frame)
	frame = ext.frame.center(screen, frame)

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
local positions = {}

function ext.win.pos(win, option)
	local id = win:application():bundleid()
	local frame = win:frame()

	if option == "save" then
		notify.show("Hydra", "position for " .. id .. " saved", "", "")
		positions[id] = frame
	end

	if option == "load" and positions[id] then
		notify.show("Hydra", "position for " .. id .. " restored", "", "")
		win:setframe(positions[id])
	end
end

-- cycle application windows
-- simplified and stolen from: https://github.com/nifoc/dotfiles/blob/master/hydra/cycle.lua
function ext.win.cycle(win)
	local windows = win:application():visiblewindows()
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

-- apply function to a window with optional params
function dowin(fn, param)
	return function()
		fn(window.focusedwindow(), param)
	end
end

-- keyboard modifier for bindings
local mod1 = { "cmd", "ctrl" }
local mod2 = { "cmd", "ctrl", "alt" }

-- window modifiers
hotkey.bind(mod1, "c", dowin(ext.win.center))
hotkey.bind(mod1, "z", dowin(ext.win.full))
hotkey.bind(mod1, "tab", dowin(ext.win.throw))

-- save and restore window positions
hotkey.bind(mod1, "s", dowin(ext.win.pos, "save"))
hotkey.bind(mod1, "r", dowin(ext.win.pos, "load"))

-- cycle application windows
hotkey.bind(mod1, "w", dowin(ext.win.cycle))

-- reload hydra settings
hotkey.bind(mod1, "h", function() hydra:reload() end)

-- push to edges and nudge
fnutils.each({ "up", "down", "left", "right" }, function(direction)
	hotkey.bind(mod1, direction, dowin(ext.win.push, direction))
	hotkey.bind(mod2, direction, dowin(ext.win.nudge, direction))
end)

-- set window sizes
fnutils.each({
	{ key = 1, w = 1400, h = 940 },
	{ key = 2, w = 980, h = 920 },
	{ key = 3, w = 800, h = 880 },
	{ key = 4, w = 800, h = 740 },
	{ key = 5, w = 760, h = 620 },
	{ key = 6, w = 770, h = 470 }
}, function(object)
	hotkey.bind(mod1, object.key, dowin(ext.win.size, { w = object.w, h = object.h }))
end)

-- launch and focus applications
fnutils.each({
	{ key = "t", app = "Terminal" },
	{ key = "s", app = "Safari" },
	{ key = "f", app = "Finder" },
	{ key = "n", app = "Notational Velocity" },
	{ key = "p", app = "TaskPaper" },
	{ key = "m", app = "MacVim" }
}, function(object)
	hotkey.bind(mod2, object.key, function() application.launchorfocus(object.app) end)
end)
