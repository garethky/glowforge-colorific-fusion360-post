function drawBox(x, y) {
	return [
		move(x, y),
		cut(x += 10, y),
		cut(x, y -= 10),
		cut(x -= 10, y),
		cut(x, y += 10),
	]
}

function test1() {
	// lower left, upper right, origin vector
	newTest(new Vector(0, 0), new Vector(10, 10), new Vector(0, 0))
		.withSection(JET_MODE_ETCHING, {}, drawBox(0, 10))
		.run('test-1-result');
}

(function runAllTests() {
	test1();
})();