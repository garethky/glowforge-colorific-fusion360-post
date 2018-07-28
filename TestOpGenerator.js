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
		.withSection(JET_MODE_ETCHING, {}, drawBox(lowerLeftX, upperRightY));
}

function useWorkAreaTest(lowerLeftX, lowerLeftY, upperRightX, upperRightY, targetId) {
	// lower left, upper right, origin vector
	return newTest(new Vector(lowerLeftX, lowerLeftY), new Vector(upperRightX, upperRightY), new Vector(0, 0), targetId)
		.withSection(JET_MODE_ETCHING, {}, drawBox(lowerLeftX, upperRightY))
		.withProperties({useWorkArea: true,
	 					workAreaWidth: 20,
		  				workAreaHeight: 20});
}

function violateWorkAreaTest(boxWidth, boxHeight, targetId) {
	// lower left, upper right, origin vector
	return newTest(new Vector(0, 0), new Vector(boxWidth, boxHeight), new Vector(0, 0), targetId)
		.withSection(JET_MODE_ETCHING, {}, drawBoxWithSize(0, boxHeight, boxWidth, boxHeight))
		.withProperties({useWorkArea: true,
	 					workAreaWidth: 20,
		  				workAreaHeight: 20});
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

	for (var i = 0; i < tests.length; i++) {
		var test = tests[i];
		test.run();
	}
})();