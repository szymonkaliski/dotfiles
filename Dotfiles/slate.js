/*global slate */

// window margin
var margin = 10;

// global config
slate.configAll({
	"secondsBetweenRepeat": 0,
	"defaultToCurrentScreen": true,
	"checkDefaultsOnLoad": true,
	"focusCheckWidthMax": 3000,
	"orderScreensLeftToRight": true
});

// 1/2 left
var pushLeft = slate.operation("move", {
	"x": "screenOriginX +" + margin,
	"y": "screenOriginY +" + margin,
	"width": "screenSizeX / 2 -" + margin * 1.75,
	"height": "screenSizeY -" + margin * 1.75
});

// 1/2 right
var pushRight = slate.operation("move", {
	"x": "screenOriginX + screenSizeX / 2 +" + margin / 2,
	"y": "screenOriginY +" + margin,
	"width": "screenSizeX / 2 -" + margin * 1.75,
	"height": "screenSizeY -" + margin * 1.75
});

// 1/2 top
var pushTop = slate.operation("move", {
	"x": "screenOriginX +" + margin,
	"y": "screenOriginY +" + margin,
	"width": "screenSizeX -" + margin * 2,
	"height": "screenSizeY / 2 -" + margin
});

// 1/2 bottom
var pushBottom = slate.operation("move", {
	"x": "screenOriginX +" + margin,
	"y": "screenOriginY + screenSizeY / 2 + " + margin,
	"width": "screenSizeX -" + margin * 2,
	"height": "screenSizeY / 2 -" + margin * 1.75
});

// full respecting margin
var fullscreen = slate.operation("move", {
  "x": "screenOriginX +" + margin,
  "y": "screenOriginY +" + margin,
  "width": "screenSizeX -" + margin * 2,
  "height": "screenSizeY -" + margin * 1.75
});

// center
var center = function(window) {
	if (!window) { return false; }

	var rect = window.rect();

	window.doOperation(
		slate.operation("move", {
			"x": "screenOriginX + screenSizeX / 2 -" + rect.width / 2,
			"y": "screenOriginY + screenSizeY / 2 -" + rect.height / 2,
			"width": rect.width,
			"height": rect.height
		})
	);
};

// throw to next display
var nextDisplay = function(window) {
	if (!window) { return false; }

	var rect = window.rect();

	window.doOperation(
		slate.operation("throw", {
			"x": "screenOriginX + screenSizeX / 2 -" + rect.width / 2,
			"y": "screenOriginY + screenSizeY / 2 -" + rect.height / 2,
			"width": rect.width,
			"height": rect.height,
			"screen": "next"
		})
	);
};

// resize window if bigger than screen
var fitToScreen = function(window) {
	if (!window) { return false; }

	var rect = window.rect();
	var screen = window.screen().visibleRect();

	var width = rect.width;
	var height = rect.height;

	var shouldFit = false;

	if (width + margin * 2 > screen.width) {
		width = screen.width - margin * 2;
		shouldFit = true;
	}

	if (height + margin * 1.75 > screen.height) {
		height = screen.height - margin * 1.75;
		shouldFit = true;
	}

	if (shouldFit) {
		window.doOperation(
			slate.operation("move", {
				"x": "screenOriginX + screenSizeX / 2 -" + width / 2,
				"y": "screenOriginY + screenSizeY / 2 -" + height / 2,
				"width": width,
				"height": height
			})
		);
	}
	else {
		return false;
	}
};

// throw to next display and resize if needed
var nextDisplayAndFit = slate.operation("sequence", {
	"operations": [
		[ nextDisplay, fitToScreen ]
	]
});

// resize window and center
var centerWindowWithSize = function(width, height) {
	return slate.operation("move", {
		"x": "screenOriginX + screenSizeX / 2 -" + width / 2,
		"y": "screenOriginY + screenSizeY / 2 -" + height / 2,
		"width": width,
		"height": height
	});
};

// move window in direction respecting screen edges and margins
var nudgeWindow = function(direction) {
	return function(window) {
		if (!window) { return false; }

		var rect = window.rect();
		var screen = window.screen().visibleRect();

		var x = rect.x;
		var y = rect.y;

		if (direction === "left") {
			x -= margin;
			x = Math.max(screen.x + margin, x);
		}

		if (direction === "right") {
			x += margin;
			x = Math.min(screen.x + screen.width - margin - rect.width, x);
		}

		if (direction === "up") {
			y -= margin;
			y = Math.max(screen.y + margin, y);
		}

		if (direction === "down") {
			y += margin;
			y = Math.min(screen.y + screen.height - margin * 0.5 - rect.height, y);
		}

		window.doOperation("move", {
			"x": x,
			"y": y,
			"width": rect.width,
			"height": rect.height
		});
	};
};

slate.bindAll({
	// push to edges
	"left:cmd;ctrl": pushLeft,
	"right:cmd;ctrl": pushRight,
	"up:cmd;ctrl": pushTop,
	"down:cmd;ctrl": pushBottom,
	// nudge and repeat
	"left:cmd;ctrl;alt": [nudgeWindow("left"), true],
	"right:cmd;ctrl;alt": [nudgeWindow("right"), true],
	"up:cmd;ctrl;alt": [nudgeWindow("up"), true],
	"down:cmd;ctrl;alt": [nudgeWindow("down"), true],
	// misc
	"z:cmd;ctrl": fullscreen,
	"c:cmd;ctrl": center,
	"r:cmd;ctrl": slate.operation("undo"),
	"tab:cmd;ctrl": nextDisplayAndFit,
	// window sizes
	"1:cmd;ctrl": centerWindowWithSize(980, 920),
	"2:cmd;ctrl": centerWindowWithSize(800, 880),
	"3:cmd;ctrl": centerWindowWithSize(800, 740),
	"4:cmd;ctrl": centerWindowWithSize(760, 620),
	"5:cmd;ctrl": centerWindowWithSize(770, 470)
});
