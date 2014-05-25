/*global _, api, Window */

var log = function(message) { api.alert(JSON.stringify(message)); };
var clamp = function(value, min, max) { return Math.max(min, Math.min(value, max)); };

var mod1 = [ "ctrl", "cmd" ];
var mod2 = [ "ctrl", "cmd", "alt" ];
var padding = 10;
var windowSizes = {};

api.bind('left',  mod1, function() { Window.focusedWindow().setGrid(0.0, 0.0, 0.5, 1.0); });
api.bind('right', mod1, function() { Window.focusedWindow().setGrid(0.5, 0.0, 0.5, 1.0); });
api.bind('up',    mod1, function() { Window.focusedWindow().setGrid(0.0, 0.0, 1.0, 0.5); });
api.bind('down',  mod1, function() { Window.focusedWindow().setGrid(0.0, 0.5, 1.0, 0.5); });

api.bind('left',  mod2, function() { Window.focusedWindow().nudge(-padding, 0); });
api.bind('right', mod2, function() { Window.focusedWindow().nudge(+padding, 0); });
api.bind('up',    mod2, function() { Window.focusedWindow().nudge(0, -padding); });
api.bind('down',  mod2, function() { Window.focusedWindow().nudge(0, +padding); });

api.bind('z',     mod1, function() { Window.focusedWindow().setGrid(0.0, 0.0, 1.0, 1.0); });
api.bind('c',     mod1, function() { Window.focusedWindow().center(); });
api.bind('s',     mod1, function() { Window.focusedWindow().save(true); });
api.bind('r',     mod1, function() { Window.focusedWindow().restore(); });
api.bind('tab',   mod1, function() { Window.focusedWindow().nextMonitor(); });

api.bind(1,       mod1, function() { Window.focusedWindow().setSize(980, 920); });
api.bind(2,       mod1, function() { Window.focusedWindow().setSize(800, 880); });
api.bind(3,       mod1, function() { Window.focusedWindow().setSize(800, 740); });
api.bind(4,       mod1, function() { Window.focusedWindow().setSize(760, 620); });
api.bind(5,       mod1, function() { Window.focusedWindow().setSize(770, 470); });

Window.prototype.save = function(force) {
	var pid = this.app().pid;

	if (windowSizes[pid] === undefined || force === true) {
		windowSizes[pid] = this.frame();
	}

	return this;
};

Window.prototype.restore = function() {
	var pid = this.app().pid;

	if (windowSizes[pid] !== undefined) {
		this.setFrame(windowSizes[pid]);
		this.focusWindow();
	}

	return this;
};

Window.prototype.setGrid = function(x, y, width, height) {
	this.save();

	var screen = this.screen().frameWithoutDockOrMenu();

	var frame = {
		"x": Math.round(x * screen.width) + padding + screen.x,
		"y": Math.round(y * screen.height) + padding + screen.y,
		"width": Math.round(width * screen.width) - 2 * padding,
		"height": Math.round(height * screen.height) - 2 * padding
	};

	// fix for problems with bottom padding
	if (height === 1) {
		this.setFrame(_({}).extend(frame, { "height": screen.height - 50 }));
	}

	this.setFrame(frame);
	this.focusWindow();

	return this;
};

Window.prototype.setSize = function(width, height) {
	this.save();

	var screen = this.screen().frameWithoutDockOrMenu();
	var frame = {
		"x": screen.width / 2 - width / 2 + screen.x,
		"y": screen.height / 2 - height / 2 + screen.y,
		"width": width,
		"height": height
	};

	this.setFrame(frame);
	this.focusWindow();

	return this;
};

Window.prototype.nudge = function(x, y) {
	this.save();

	var screen = this.screen().frameWithoutDockOrMenu();
	var frame = this.frame();

	this.setFrame(_({}).extend(frame, {
		"x": clamp(frame.x + x, screen.x + padding, screen.x + screen.width - padding - frame.width),
		"y": clamp(frame.y + y, screen.y + padding, screen.y + screen.height - padding - frame.height)
	}));

	return this;
};

Window.prototype.center = function() {
	this.save();

	var screen = this.screen().frameWithoutDockOrMenu();
	var frame = this.frame();

	this.setFrame(_({}).extend(frame, {
		"x": screen.width / 2 - frame.width / 2 + screen.x,
		"y": screen.height / 2 - frame.height / 2 + screen.y
	}));

	this.focusWindow();

	return this;
};

Window.prototype.nextMonitor = function() {
	this.save();

	var nextScreen = this.screen().nextScreen().frameWithoutDockOrMenu();
	var frame = this.frame();
	var doublePadding = padding * 2;

	// set new width and height if window is too big
	var newFrame = {
		"width": (frame.width < nextScreen.width - doublePadding) ? frame.width : nextScreen.width - doublePadding,
		"height": (frame.height < nextScreen.height - doublePadding) ? frame.height : nextScreen.height - doublePadding
	};

	// set proper x and y on new screen
	_(newFrame).extend({
		"x": nextScreen.width / 2 - newFrame.width / 2 + nextScreen.x,
		"y": nextScreen.height / 2 - newFrame.height / 2 + nextScreen.y
	});

	this.setFrame(newFrame);
	this.focusWindow();

	return this;
};
