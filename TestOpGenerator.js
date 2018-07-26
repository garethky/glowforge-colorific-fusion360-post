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
	newTest(0, 0, 10, 10)
		.withSection(JET_MODE_ETCHING, {}, drawBox(0, 10))
		.run('test-1-result');
}

(function runAllTests() {
	test1();
})();