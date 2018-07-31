// draws a box, clockwise, starting in the upper left corner
function drawArrow(x, y) {
	return [
		move(x, y),

		// arrow
		move(x += 5, y),
		cut(x += 5, y -= 4),
		cut(x, y -= 2),
		cut(x -= 3, y),
		cut(x, y -= 4),
		
		cut(x -= 4, y),

		cut(x, y += 4),
		cut(x -= 3, y),
		cut(x, y += 2),
		cut(x += 5, y += 4),
		move(x, y),
	]
}

// draws a box, clockwise, starting in the upper left corner
function drawBoxWithSize(x, y, width, height) {
	return [
		move(x, y),
		cut(x += width, y),
		cut(x, y -= height),
		cut(x -= width, y),
		cut(x, y += height),
	]
}

function drawBox(x, y) {
	return drawBoxWithSize(x, y, 10, 10);
}

function autoStockPointTest(lowerLeftX, lowerLeftY, upperRightX, upperRightY, targetId) {
	// lower left, upper right, origin vector
	return newTest(new Vector(lowerLeftX, lowerLeftY), new Vector(upperRightX, upperRightY), new Vector(0, 0), targetId)
		.withSection(JET_MODE_ETCHING, {}, drawArrow(lowerLeftX, upperRightY));
}

function useWorkAreaTest(lowerLeftX, lowerLeftY, upperRightX, upperRightY, targetId) {
	// lower left, upper right, origin vector
	return newTest(new Vector(lowerLeftX, lowerLeftY), new Vector(upperRightX, upperRightY), new Vector(0, 0), targetId)
		.withSection(JET_MODE_ETCHING, {}, drawArrow(lowerLeftX, upperRightY))
		.withProperties({useWorkArea: true,
	 					workAreaWidth: 20,
		  				workAreaHeight: 20});
}

function violateWorkAreaTest(boxWidth, boxHeight, targetId) {
	// lower left, upper right, origin vector
	return newTest(new Vector(0, 0), new Vector(boxWidth, boxHeight), new Vector(0, 0), targetId)
		.withSection(JET_MODE_ETCHING, {}, drawBoxWithSize(0, boxHeight, boxWidth, boxHeight))
		.withSection(JET_MODE_ETCHING, {}, drawArrow(0, boxHeight))
		.withProperties({useWorkArea: true,
	 					workAreaWidth: 20,
		  				workAreaHeight: 20});
}

function colorTest(colorCount) {
	var columns = 15;
	var width = Math.ceil(13 * columns) - 3;
	var height = Math.ceil(13 * Math.ceil(colorCount / columns)) - 3;

	// lower left, upper right, origin vector
	var test =  newTest(new Vector(0, 0), new Vector(width, height), new Vector(0, 0), "colors-" + colorCount);

	var x = 0, y = height;
	
	var rows = 0;
	var j = 0;
	for (var i = 0; i < colorCount; i ++) {
		test.withSection(JET_MODE_ETCHING, {}, drawBox(x, y));
		x += 13;
		j++;
		if (j >= columns) {
			j = 0;
			x = 0;
			y -= 13;
			rows++;
			//move(0, 10 - (rows * (13)));

		}
	}

	return test;
}

(function runAllTests() {
	var tests = [];

	// Auto Stock Point 
	tests.push(autoStockPointTest(0,   -10, 10,  0, 'auto-stock-point-upper-left'));
	tests.push(autoStockPointTest(-5,  -10, 5,   0, 'auto-stock-point-upper-middle'));
	tests.push(autoStockPointTest(-10, -10, 0,   0, 'auto-stock-point-upper-right'));
	tests.push(autoStockPointTest(0,    -5, 10,  5, 'auto-stock-point-middle-left'));
	tests.push(autoStockPointTest(-5,   -5, 5,   5, 'auto-stock-point-middle-middle'));
	tests.push(autoStockPointTest(-10,  -5, 0,   5, 'auto-stock-point-middle-right'));
	tests.push(autoStockPointTest(0,     0, 10, 10, 'auto-stock-point-lower-left'));
	tests.push(autoStockPointTest(-5,    0, 5,  10, 'auto-stock-point-lower-middle'));
	tests.push(autoStockPointTest(-10,   0, 0,  10, 'auto-stock-point-lower-right'));

	// use work area with auto stock point detection
	tests.push(useWorkAreaTest(0,   -10, 10,  0, 'use-work-area-upper-left'));
	tests.push(useWorkAreaTest(-5,  -10, 5,   0, 'use-work-area-upper-middle'));
	tests.push(useWorkAreaTest(-10, -10, 0,   0, 'use-work-area-upper-right'));
	tests.push(useWorkAreaTest(0,    -5, 10,  5, 'use-work-area-middle-left'));
	tests.push(useWorkAreaTest(-5,   -5, 5,   5, 'use-work-area-middle-middle'));
	tests.push(useWorkAreaTest(-10,  -5, 0,   5, 'use-work-area-middle-right'));
	tests.push(useWorkAreaTest(0,     0, 10, 10, 'use-work-area-lower-left'));
	tests.push(useWorkAreaTest(-5,    0, 5,  10, 'use-work-area-lower-middle'));
	tests.push(useWorkAreaTest(-10,   0, 0,  10, 'use-work-area-lower-right'));

	// work area too small
	tests.push(violateWorkAreaTest(50, 10, 'violate-work-area-width'));
	tests.push(violateWorkAreaTest(10, 50, 'violate-work-area-height'));

	// color tests
	tests.push(colorTest(6));
	tests.push(colorTest(15));
	tests.push(colorTest(50));
	tests.push(colorTest(120));
	tests.push(colorTest(256));
	tests.push(colorTest(1024));

	for (var i = 0; i < tests.length; i++) {
		var test = tests[i];
		test.run();
	}
})();