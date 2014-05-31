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

// push window to 1/2 left/right/top/down
var push = function(direction, size) {
	size = size || 0.5;

	var directionObject = {
		"left": slate.operation("move", {
			"x": "screenOriginX +" + margin,
			"y": "screenOriginY +" + margin,
			"width": "screenSizeX * " + size + " - " + margin * 1.75,
			"height": "screenSizeY -" + margin * 1.75
		}),

		"right": slate.operation("move", {
			"x": "screenOriginX + screenSizeX * " + (1 - size) + " + " + margin / 2,
			"y": "screenOriginY + " + margin,
			"width": "screenSizeX * " + size + " - " + margin * 1.75,
			"height": "screenSizeY - " + margin * 1.75
		}),

		"top": slate.operation("move", {
			"x": "screenOriginX + " + margin,
			"y": "screenOriginY + " + margin,
			"width": "screenSizeX - " + margin * 2,
			"height": "screenSizeY * " + size + " - " + margin
		}),

		"down": slate.operation("move", {
			"x": "screenOriginX + " + margin,
			"y": "screenOriginY + screenSizeY * " + (1 - size) + " + " + margin,
			"width": "screenSizeX - " + margin * 2,
			"height": "screenSizeY * " + size + " - " + margin * 1.75
		})
	};

	return directionObject[direction];
};

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

		// fix forbug when window isn't respecting height
		window.doOperation(
			slate.operation("move", {
				"x": "screenOriginX + screenSizeX / 2 -" + width / 2,
				"y": "screenOriginY + screenSizeY / 2 -" + height / 2,
				"width": width,
				"height": height - 100
			})
		);
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

// resize window and center
var centerWithSize = function(width, height) {
	return slate.operation("move", {
		"x": "screenOriginX + screenSizeX / 2 -" + width / 2,
		"y": "screenOriginY + screenSizeY / 2 -" + height / 2,
		"width": width,
		"height": height
	});
};

// move window in direction respecting screen edges and margins
var nudge = function(direction) {
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

// fullscreen and fit
var fullscreenAndFit = slate.operation("sequence", {
	"operations": [
		[ fullscreen, fitToScreen ]
	]
});

// throw to next display and resize if needed
var nextDisplayAndFit = slate.operation("sequence", {
	"operations": [
		[ nextDisplay, fitToScreen ]
	]
});

// push and nudge window
var pushAndNudgeSequence = function(direction, size) {
	return slate.operation("sequence", {
		"operations": [
			[ push(direction, size), nudge(direction) ]
		]
	});
};

var pushAndNudge = function(direction) {
	return slate.operation("chain", {
		"operations": [
			pushAndNudgeSequence(direction, 2/3),
			pushAndNudgeSequence(direction, 1/2),
			pushAndNudgeSequence(direction, 1/3)
		]
	});
};

slate.bindAll({
	// push to edges
	"left:cmd;ctrl":  pushAndNudge("left"),
	"right:cmd;ctrl": pushAndNudge("right"),
	"up:cmd;ctrl":    pushAndNudge("top"),
	"down:cmd;ctrl":   pushAndNudge("down"),

	// nudge and repeat
	"left:cmd;ctrl;alt":  [ nudge("left"),  true ],
	"right:cmd;ctrl;alt": [ nudge("right"), true ],
	"up:cmd;ctrl;alt":    [ nudge("up"),    true ],
	"down:cmd;ctrl;alt":  [ nudge("down"),  true ],

	// misc
	"z:cmd;ctrl":   fullscreenAndFit,
	"c:cmd;ctrl":   center,
	"r:cmd;ctrl":   slate.operation("undo"),
	"tab:cmd;ctrl": nextDisplayAndFit,

	// window sizes
	"1:cmd;ctrl": centerWithSize(1400, 940),
	"2:cmd;ctrl": centerWithSize(980, 920),
	"3:cmd;ctrl": centerWithSize(800, 880),
	"4:cmd;ctrl": centerWithSize(800, 740),
	"5:cmd;ctrl": centerWithSize(760, 620),
	"6:cmd;ctrl": centerWithSize(770, 470)
});
