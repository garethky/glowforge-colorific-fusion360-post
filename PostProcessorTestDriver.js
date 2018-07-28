// all the constants that you get access to (They arent all used but they were easy to get...)
var NUL = "\u0000",
SOH = "\u0001",
STX = "\u0002",
ETX = "\u0003",
EOT = "\u0004",
ENQ = "\u0005",
ACK = "\u0006",
BEL = "\u0007",
BS = "\b",
TAB = "\t",
LF = "\n",
VT = "\u000b",
FF = "\f",
CR = "\r",
SO = "\u000e",
SI = "\u000f",
DLE = "\u0010",
DC1 = "\u0011",
DC2 = "\u0012",
DC3 = "\u0013",
DC4 = "\u0014",
NAK = "\u0015",
SYN = "\u0016",
ETB = "\u0017",
CAN = "\u0018",
EM = "\u0019",
SUB = "\u001a",
ESC = "\u001b",
FS = "\u001c",
GS = "\u001d",
RS = "\u001e",
US = "\u001f",
EOL = "\r\n",
SP = " ",
PATH_SEPARATOR = "/",
IN = 0,
MM = 1,
ORIGINAL_UNIT = -1,
DEG = 57.29577951308232,
PLANE_XY = 0,
PLANE_ZX = 1,
PLANE_YZ = 2,
X = 0,
Y = 1,
Z = 2,
TYPE_MILLING = 0,
TYPE_TURNING = 1,
TYPE_WIRE = 2,
TYPE_JET = 3,
TYPE_ADDITIVE = 4,
CAPABILITY_MILLING = 1,
CAPABILITY_TURNING = 2,
CAPABILITY_WIRE = 4,
CAPABILITY_SETUP_SHEET = 8,
CAPABILITY_INTERMEDIATE = 16,
CAPABILITY_JET = 32,
CAPABILITY_CASCADING = 64,
CAPABILITY_ADDITIVE = 128,
JET_MODE_THROUGH = 0,
JET_MODE_ETCHING = 1,
JET_MODE_VAPORIZE = 2,
SPINDLE_PRIMARY = 0,
SPINDLE_SECONDARY = 1,
FEED_PER_MINUTE = 0,
FEED_PER_REVOLUTION = 1,
SPINDLE_CONSTANT_SPINDLE_SPEED = 0,
SPINDLE_CONSTANT_SURFACE_SPEED = 1,
TOOL_AXIS_X = 0,
TOOL_AXIS_Y = 1,
TOOL_AXIS_Z = 2,
RADIUS_COMPENSATION_OFF = 0,
RADIUS_COMPENSATION_LEFT = 1,
RADIUS_COMPENSATION_RIGHT = 2,
SINGULARITY_LINEARIZE_OFF = 0,
SINGULARITY_LINEARIZE_LINEAR = 1,
SINGULARITY_LINEARIZE_ROTARY = 2,
COOLANT_OFF = 0,
COOLANT_FLOOD = 1,
COOLANT_MIST = 2,
COOLANT_TOOL = 3,
COOLANT_THROUGH_TOOL = 3,
COOLANT_AIR = 4,
COOLANT_AIR_THROUGH_TOOL = 5,
COOLANT_SUCTION = 6,
COOLANT_FLOOD_MIST = 7,
COOLANT_FLOOD_THROUGH_TOOL = 8,
EULER_XZX_S = 0,
EULER_YXY_S = 1,
EULER_ZYZ_S = 2,
EULER_XZX_R = 3,
EULER_YXY_R = 4,
EULER_ZYZ_R = 5,
EULER_XZY_S = 6,
EULER_YXZ_S = 7,
EULER_ZYX_S = 8,
EULER_YZX_R = 9,
EULER_ZXY_R = 10,
EULER_XYZ_R = 11,
EULER_XYX_S = 12,
EULER_YZY_S = 13,
EULER_ZXZ_S = 14,
EULER_XYX_R = 15,
EULER_YZY_R = 16,
EULER_ZXZ_R = 17,
EULER_XYZ_S = 18,
EULER_YZX_S = 19,
EULER_ZXY_S = 20,
EULER_ZYX_R = 21,
EULER_XZY_R = 22,
EULER_YXZ_R = 23,
MATERIAL_UNSPECIFIED = 0,
MATERIAL_HSS = 1,
MATERIAL_TI_COATED = 2,
MATERIAL_CARBIDE = 3,
MATERIAL_CERAMICS = 4,
TOOL_UNSPECIFIED = 0,
TOOL_DRILL = 1,
TOOL_DRILL_CENTER = 2,
TOOL_DRILL_SPOT = 3,
TOOL_DRILL_BLOCK = 4,
TOOL_MILLING_END_FLAT = 5,
TOOL_MILLING_END_BALL = 6,
TOOL_MILLING_END_BULLNOSE = 7,
TOOL_MILLING_CHAMFER = 8,
TOOL_MILLING_FACE = 9,
TOOL_MILLING_SLOT = 10,
TOOL_MILLING_RADIUS = 11,
TOOL_MILLING_DOVETAIL = 12,
TOOL_MILLING_TAPERED = 13,
TOOL_MILLING_LOLLIPOP = 14,
TOOL_TAP_RIGHT_HAND = 15,
TOOL_TAP_LEFT_HAND = 16,
TOOL_REAMER = 17,
TOOL_BORING_BAR = 18,
TOOL_COUNTER_BORE = 19,
TOOL_COUNTER_SINK = 20,
TOOL_HOLDER_ONLY = 21,
TOOL_TURNING_GENERAL = 22,
TOOL_TURNING_THREADING = 23,
TOOL_TURNING_GROOVING = 24,
TOOL_TURNING_BORING = 25,
TOOL_TURNING_CUSTOM = 26,
TOOL_PROBE = 27,
TOOL_WIRE = 28,
TOOL_WATER_JET = 29,
TOOL_LASER_CUTTER = 30,
TOOL_WELDER = 31,
TOOL_GRINDER = 32,
TOOL_MILLING_FORM = 33,
TOOL_ROTARY_BROACH = 34,
TOOL_SLOT_BROACH = 35,
TOOL_PLASMA_CUTTER = 36,
TOOL_MARKER = 37,
TOOL_MILLING_THREAD = 38,
TOOL_COMPENSATION_INSERT_CENTER = 0,
TOOL_COMPENSATION_TIP = 1,
TOOL_COMPENSATION_TIP_CENTER = 2,
TOOL_COMPENSATION_TIP_TANGENT = 3,
TURNING_INSERT_USER_DEFINED = 0,
TURNING_INSERT_ISO_A = 1,
TURNING_INSERT_ISO_B = 2,
TURNING_INSERT_ISO_C = 3,
TURNING_INSERT_ISO_D = 4,
TURNING_INSERT_ISO_E = 5,
TURNING_INSERT_ISO_H = 6,
TURNING_INSERT_ISO_K = 7,
TURNING_INSERT_ISO_L = 8,
TURNING_INSERT_ISO_M = 9,
TURNING_INSERT_ISO_O = 10,
TURNING_INSERT_ISO_P = 11,
TURNING_INSERT_ISO_R = 12,
TURNING_INSERT_ISO_S = 13,
TURNING_INSERT_ISO_T = 14,
TURNING_INSERT_ISO_V = 15,
TURNING_INSERT_ISO_W = 16,
TURNING_INSERT_GROOVE_ROUND = 17,
TURNING_INSERT_GROOVE_RADIUS = 18,
TURNING_INSERT_GROOVE_SQUARE = 19,
TURNING_INSERT_GROOVE_CHAMFER = 20,
TURNING_INSERT_GROOVE_40DEG = 21,
TURNING_INSERT_THREAD_ISO_DOUBLE_FULL = 22,
TURNING_INSERT_THREAD_ISO_TRIPLE_FULL = 23,
TURNING_INSERT_THREAD_UTS_DOUBLE_FULL = 24,
TURNING_INSERT_THREAD_UTS_TRIPLE_FULL = 25,
TURNING_INSERT_THREAD_ISO_DOUBLE_VPROFILE = 26,
TURNING_INSERT_THREAD_ISO_TRIPLE_VPROFILE = 27,
TURNING_INSERT_THREAD_UTS_DOUBLE_VPROFILE = 28,
TURNING_INSERT_THREAD_UTS_TRIPLE_VPROFILE = 29,
HOLDER_NONE = 0,
HOLDER_ISO_A = 1,
HOLDER_ISO_B = 2,
HOLDER_ISO_C = 3,
HOLDER_ISO_D = 4,
HOLDER_ISO_E = 5,
HOLDER_ISO_F = 6,
HOLDER_ISO_G = 7,
HOLDER_ISO_H = 8,
HOLDER_ISO_J = 9,
HOLDER_ISO_K = 10,
HOLDER_ISO_L = 11,
HOLDER_ISO_M = 12,
HOLDER_ISO_N = 13,
HOLDER_ISO_P = 14,
HOLDER_ISO_Q = 15,
HOLDER_ISO_R = 16,
HOLDER_ISO_S = 17,
HOLDER_ISO_T = 18,
HOLDER_ISO_U = 19,
HOLDER_ISO_V = 20,
HOLDER_ISO_W = 21,
HOLDER_ISO_Y = 22,
HOLDER_OFFSET_PROFILE = 23,
HOLDER_STRAIGHT_PROFILE = 24,
HOLDER_GROOVE_EXTERNAL = 25,
HOLDER_GROOVE_INTERNAL = 26,
HOLDER_GROOVE_FACE = 27,
HOLDER_THREAD_STRAIGHT = 28,
HOLDER_THREAD_OFFSET = 29,
HOLDER_THREAD_FACE = 30,
HOLDER_BORING_BAR_ISO_F = 31,
HOLDER_BORING_BAR_ISO_G = 32,
HOLDER_BORING_BAR_ISO_J = 33,
HOLDER_BORING_BAR_ISO_K = 34,
HOLDER_BORING_BAR_ISO_L = 35,
HOLDER_BORING_BAR_ISO_P = 36,
HOLDER_BORING_BAR_ISO_Q = 37,
HOLDER_BORING_BAR_ISO_S = 38,
HOLDER_BORING_BAR_ISO_U = 39,
HOLDER_BORING_BAR_ISO_W = 40,
HOLDER_BORING_BAR_ISO_Y = 41,
HOLDER_BORING_BAR_ISO_X = 42,
HAS_PARAMETER = 1,
HAS_RAPID = 2,
HAS_LINEAR = 4,
HAS_RAPID_5D = 8,
HAS_LINEAR_5D = 16,
HAS_MULTIAXIS = 24,
HAS_DWELL = 32,
HAS_CIRCULAR_CW = 64,
HAS_CIRCULAR_CCW = 128,
HAS_CIRCULAR = 192,
HAS_CYCLE = 256,
HAS_WELL_KNOWN_COMMAND = 512,
HAS_MACHINE_COMMAND = 1024,
HAS_SPINDLE_SPEED = 2048,
HAS_COOLANT = 4096,
HAS_SPLINE = 8192,
HAS_COMMENT = 16384,
RECORD_INVALID = 0,
RECORD_TOOL_CHANGE = 1,
RECORD_WELL_KNOWN_COMMAND = 2,
RECORD_MACHINE_COMMAND = 3,
RECORD_SPINDLE_SPEED = 4,
RECORD_COOLANT = 5,
RECORD_PARAMETER = 6,
RECORD_LINEAR = 7,
RECORD_LINEAR_5D = 8,
RECORD_LINEAR_ZXN = 9,
RECORD_CIRCULAR = 10,
RECORD_SPLINE = 11,
RECORD_BEZIER = 12,
RECORD_NURBS = 13,
RECORD_DWELL = 14,
RECORD_CYCLE = 15,
RECORD_CYCLE_OFF = 16,
RECORD_COMMENT = 17,
RECORD_WIDE_COMMENT = 18,
RECORD_PASS_THROUGH = 19,
RECORD_WIDE_PASS_THROUGH = 20,
RECORD_SKIP = 21,
RECORD_OPERATION = 22,
RECORD_OPERATION_END = 23,
COMMAND_STOP = 1,
COMMAND_OPTIONAL_STOP = 2,
COMMAND_END = 3,
COMMAND_SPINDLE_CLOCKWISE = 4,
COMMAND_SPINDLE_COUNTERCLOCKWISE = 5,
COMMAND_START_SPINDLE = 6,
COMMAND_STOP_SPINDLE = 7,
COMMAND_ORIENTATE_SPINDLE = 8,
COMMAND_LOAD_TOOL = 9,
COMMAND_COOLANT_ON = 10,
COMMAND_COOLANT_OFF = 11,
COMMAND_ACTIVATE_SPEED_FEED_SYNCHRONIZATION = 12,
COMMAND_DEACTIVATE_SPEED_FEED_SYNCHRONIZATION = 13,
COMMAND_ACTIVATE_SPEED_FEED_SYNCHORNIZATION = 12,
COMMAND_DEACTIVATE_SPEED_FEED_SYNCHORNIZATION = 13,
COMMAND_LOCK_MULTI_AXIS = 14,
COMMAND_UNLOCK_MULTI_AXIS = 15,
COMMAND_EXACT_STOP = 16,
COMMAND_START_CHIP_TRANSPORT = 17,
COMMAND_STOP_CHIP_TRANSPORT = 18,
COMMAND_OPEN_DOOR = 19,
COMMAND_CLOSE_DOOR = 20,
COMMAND_BREAK_CONTROL = 21,
COMMAND_TOOL_MEASURE = 22,
COMMAND_CALIBRATE = 23,
COMMAND_VERIFY = 24,
COMMAND_CLEAN = 25,
COMMAND_ALARM = 26,
COMMAND_ALERT = 27,
COMMAND_CHANGE_PALLET = 28,
COMMAND_POWER_ON = 29,
COMMAND_POWER_OFF = 30,
COMMAND_MAIN_CHUCK_OPEN = 31,
COMMAND_MAIN_CHUCK_CLOSE = 32,
COMMAND_SECONDARY_CHUCK_OPEN = 33,
COMMAND_SECONDARY_CHUCK_CLOSE = 34,
COMMAND_SECONDARY_SPINDLE_SYNCHRONIZATION_ACTIVATE = 35,
COMMAND_SECONDARY_SPINDLE_SYNCHRONIZATION_DEACTIVATE = 36,
COMMAND_SYNC_CHANNELS = 37,
MOVEMENT_RAPID = 0,
MOVEMENT_LEAD_IN = 1,
MOVEMENT_CUTTING = 2,
MOVEMENT_LEAD_OUT = 3,
MOVEMENT_LINK_TRANSITION = 4,
MOVEMENT_BRIDGING = 4,
MOVEMENT_LINK_DIRECT = 5,
MOVEMENT_RAMP_HELIX = 6,
MOVEMENT_PIERCE_CIRCULAR = 6,
MOVEMENT_RAMP_PROFILE = 7,
MOVEMENT_PIERCE_PROFILE = 7,
MOVEMENT_RAMP_ZIG_ZAG = 8,
MOVEMENT_PIERCE_LINEAR = 8,
MOVEMENT_RAMP = 9,
MOVEMENT_PLUNGE = 10,
MOVEMENT_PIERCE = 10,
MOVEMENT_PREDRILL = 11,
MOVEMENT_EXTENDED = 12,
MOVEMENT_REDUCED = 13,
MOVEMENT_FINISH_CUTTING = 14,
MOVEMENT_HIGH_FEED = 15,
PARAMETER_SPATIAL = 0,
PARAMETER_ANGLE = 1,
PARAMETER_ENUM = 2,
HIGH_FEED_NO_MAPPING = 0,
HIGH_FEED_MAP_MULTI = 1,
HIGH_FEED_MAP_XY_Z = 2,
HIGH_FEED_MAP_ANGULAR = 3,
HIGH_FEED_MAP_CLEARANCE = 4,
HIGH_FEED_MAP_ANY = 5,
FLAG_CYCLE_REPEAT_PASS = 1;

var currentSection = null;
var movement = null;
var currentTest = null;
var unit = MM;
var radiusCompensation = RADIUS_COMPENSATION_OFF;

// dummy vector constructor
function Vector(x, y, z) {
	this.x = x;
	this.y = y;
	this.z = z || 0;  // auto set Z to zero
}

function line(isRapid, x, y) {
	return {
		isRapid: isRapid,
		x: x,
		y: y
	}
}

function cut(x, y) {
	return line(false, x, y);
}

function move(x, y) {
	return line(true, x, y);
}

/**
 * Tests are constructed by describing the lower left, upper right and origin vectors of the work
 */
function newTest(lowerLeftVector, upperRightVector, originVector) {
	var sections = [];
	// this is the current position
	var x = originVector.x, y = originVector.y;
	var outputLines = [];

	function processLines(lines) {
		for (var i = 0; i < lines.length; i++) {
			processLine(lines[i]);
		}
	}
	function processLine(line) {
		console.log('line', line);
		if (line.isRapid === true) {
			movement = MOVEMENT_RAPID;
			onRapid(line.x, line.y, 0);
		}
		else {
			movement = MOVEMENT_CUTTING;
			onLinear(line.x, line.y, 0);
		}
		x = line.x;
		y = line.y;
	}

	// returned object becomes the current test as well as the interface for configuring the test
	var test = {
		getNumberOfSections: function getNumberOfSections() {
			return sections.length;
		},
		getWorkpiece: function getWorkpiece() {
			return {
				upper: upperRightVector,
				lower: lowerLeftVector
			}
		},
		withSection: function (jetMode, parameters, lines) {
			var id = sections.length;
			var section = {
				getId: function getId() {
					return id;
				},
				jetMode: jetMode,
				workPlane: {
					forward: new Vector(0, 0, 1)
				},
				hasParameter: function hasParameter(key) {
					return !!parameters[key];
				},
				getParameter: function getParameter(key) {
					return parameters[key];
				},
				lines: lines
			}

			sections.push(section);
			return test;
		},
		getCurrentPosition: function() {
			return {x: x, y: y}
		},
		writeln: function writeln(line) {
			outputLines.push(line);
		},
		run: function run(targetId) {
			// assign global current test
			currentTest = test;
			onOpen();
			for (var i = 0; i < sections.length; i++) {
				currentSection = sections[i];
				onSection();
				processLines(currentSection.lines);
				onSectionEnd();
				currentSection = null;
				movement = null;
			}
			onClose();
			currentTest = null;

			// run all sections...
			var svg = outputLines.join("\n")
			console.log(svg);
			document.getElementById(targetId).innerHTML = svg;
		}
	};

	return test;
}

// we dont need to test anything but the laser
var tool = {
	type: TOOL_LASER_CUTTER
}

// real working degrees to radians function
function toRad (angle) {
  return angle * (Math.PI / 180);
}

// The return type is pretty extensive but only 1 function is used in out post: format(number)
// https://cam.autodesk.com/posts/reference/classFormatNumber.html#a47d304db32feae2b6dbfb5281c153460
// Returns the string for the specified value
function createFormat(options) {
	return {
		format: function format(number) {
			return (number * options.scale).toFixed(options.decimals);
		}
	};
}

// get section count, TODO: make this drivable from the test data input
function getNumberOfSections() {
	return currentTest.getNumberOfSections();
}

function hasParameter(key) {
	return currentSection.hasParameter(key);
}
function getParameter(key) {
	return currentSection.getParameter(key);
}

// sure, why not...
function isSameDirection() {
	return true;
}

// noop
function setRotation() {}

function error(str) {
	console.error(str);
}

function log(str) {
	console.log(str);
}

function writeln(str) {
	currentTest.writeln(str);
}

// i18n FTW!
function localize(str) {
	return str;
}

function getWorkpiece() {
	return currentTest.getWorkpiece();
}

function getCurrentPosition() {
	return currentTest.getCurrentPosition();
}

function setCodePage(codePage) {
}
