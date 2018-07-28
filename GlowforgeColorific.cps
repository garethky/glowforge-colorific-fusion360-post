/**
  Copyright (C) 2015 by Autodesk, Inc.
  All rights reserved.
*/

description = "Glowforge";
vendor = "Glowforge";
vendorUrl = "https://www.glowforge.com";
legal = "Copyright (C) 2018 by Autodesk, Inc.";
certificationLevel = 2;

longDescription = "Generic post for Glowforge laser. The post will output the toolpath as SVG graphics which can then be uploaded directly to Glowforge.";

extension = "svg";
mimetype = "image/svg+xml";
setCodePage("utf-8");

capabilities = CAPABILITY_JET;

minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
allowHelicalMoves = true;
allowedCircularPlanes = (1 << PLANE_XY); // only XY arcs

// global prooperties variable
properties = null;
// made available for testing
function resetProperties() {
    properties = {
      lineWidth: 0.1, // how wide lines are in the SVG
      margin: 2, // margin in mm
      checkForRadiusCompensation: false, // if enabled throw an error if compensation in control is used
      doNotFlipYAxis: false,
      useWorkArea: false, // center the toolpath in the machines work area, off by default
      autoStockPoint: true, // automatically translate the output paths for strage stock points, see the whole image no matter what you select
      // Glowforge Cutting area: aprox. 19.5″ (495 mm) wide and 11″ (279 mm) deep
      workAreaWidth: 495, // width in mm used when useWorkArea is enabled
      workAreaHeight: 279, // height in mm used when useWorkArea is enabled
  };
}
resetProperties();

// user-defined property definitions
propertyDefinitions = {
  lineWidth: {title: "SVG Stroke Width(mm)", description: "The width of lines in the SVG in mm.", type: "number"},
  margin: {title: "Margin(mm)", description: "Sets the margin in mm when 'Crop to Workpiece' is used.", type: "number"},
  checkForRadiusCompensation: {title: "Check Sideways Comp.", description: "Check every opperation for Sideways Compensation 'In Computer'. If this is not configured, throw an error.", type: "boolean"},
  doNotFlipYAxis: {title: "Flip Model", description: "If your part is upside down, check this box to flip it over. (Tip: checking 'Flip Z Axis' in the CAM setup also fixes this)", type: "boolean"},
  useWorkArea: {title:"Use Work Area", description:"Center the toolpaths in an image the size of the defined Work Area.", type:"boolean"},
  autoStockPoint: {title:"Auto Stock Point", description:"Make the final image completly visible reguardless of the selected stock point.", type:"boolean"},
  workAreaWidth: {title:"Work Area Width(mm", description:"Work Area Width in mm, used when 'Crop to Workpiece' is disabled. Typically the max cutting width of the Glowforge.", type:"number"},
  workAreaHeight: {title:"Work Area Height(mm)", description:"Height in mm, used when 'Crop to Workpiece' is disabled. Typically the max cutting height of the Glowforge.", type:"number"},
};

var POST_URL = "https://cam.autodesk.com/hsmposts?p=glowforge";

// Recommended colors for color mapping.
var COLOR_GREEN = "1FB714";
var COLOR_YELLOW = "FBF305";
var COLOR_DARK_GREEN = "006412";
var COLOR_ORANGE = "FF6403";
var COLOR_BROWN = "562C05";
var COLOR_RED = "DD0907";
var COLOR_TAN = "90713A";
var COLOR_MAGENTA = "F20884";
var COLOR_LIGHT_GREY = "C0C0C0";
var COLOR_PURPLE = "4700A5";
var COLOR_MEDIUM_GREY = "808080";
var COLOR_BLUE = "0000D3";
var COLOR_DARK_GREY = "404040";
var COLOR_CYAN = "02ABEA";
var COLOR_BLACK = "000000";

var COLOR_CYCLE = [COLOR_CYAN,
                    COLOR_MAGENTA,
                    COLOR_YELLOW,
                    COLOR_RED,
                    COLOR_GREEN,
                    COLOR_BLUE,
                    COLOR_ORANGE,
                    COLOR_DARK_GREEN,
                    COLOR_PURPLE,
                    COLOR_BROWN,
                    COLOR_TAN,
                    COLOR_LIGHT_GREY,
                    COLOR_MEDIUM_GREY,
                    COLOR_DARK_GREY,
                    COLOR_BLACK];

// dont pick fewer colors than this
var MIN_COLORS = 6;

/** Global State **/
function reset() {
  return {
    //
    xyzFormat: createFormat({decimals:(unit == MM ? 3 : 4), scale:(unit == MM) ? 1 : 25.4}),
    // selected colors to use for this run
    activeColorCycle: null,
    // the hex string of the current color
    currentHexColor: null,
    // the index of the current color
    currentColorIndex: -1,
    // track if the next path element can be a move command
    allowMoveCommandNext: null,
    // is the work area too small?
    workAreaTooSmall: false
  };
}
var state = null;

// select a subset of colors so our preferred color pallet is used (and not simply the color with the lowest hex value first)
function selectColors() {
  var requiredColors = Math.max(MIN_COLORS, getNumberOfSections()); // makes sure that more than enough colors get made
  var finalColorCycle = [];
  var numColors = COLOR_CYCLE.length;

  // if the number of default colors is too small, we will build lighter shades of those colors to fill in the extra needed colors:
  var alphaSteps = Math.ceil(requiredColors / numColors);
  var alphaStep = 1 / alphaSteps;
  var alphaStepIndex = 0;
  var colorIndex = 0;
  var finalColorCycle = [];

  for (var i = 0; i < requiredColors; i++) {
    finalColorCycle.push(alphaBlendHexColor(COLOR_CYCLE[colorIndex], 1 - (alphaStep * alphaStepIndex)));
    colorIndex += 1;  // next color
    if (colorIndex >= numColors) {
      colorIndex = 0;  // start back at the first color
      alphaStepIndex++;  // next lighter shade
    }
  }

  // reset all color related variables to allow re-runs
  state.activeColorCycle = sortColors(finalColorCycle);
}

// Glowforge doesn't respect the order of operations in the SVG file, it re-sorts them by the hex color value in ascending order
// so here the color cycle is sorted to preserve op order from CAM.
function sortColors(inputColors) {
  var mappedColors = inputColors.map(function buildHexColors(color, i) {
    return {hexColor: '#' + color, hexValue: parseInt(color, 16)};
  });

  mappedColors.sort(function compareHexValues(a, b) {
    if (a.hexValue < b.hexValue) {
      return -1;
    }
    if (a.hexValue > b.hexValue) {
      return 1;
    }
    return 0;
  });

  return mappedColors.map(function reduceToHexColor(color, i) {
    return color.hexColor;
  });
}

// returns a hex color that is alphaPercent lighter than the input color
function alphaBlendHexColor(hexColorString, alphaPercent) {
  // alphaPercent needs to be converted from a float to a fraction of 255
  var alpha = Math.round(alphaPercent * 255);

  // hex color needs to be converted from a hex string to its constituent parts:
  var red = parseInt(hexColorString.substring(0, 2), 16);
  var green = parseInt(hexColorString.substring(2, 4), 16);
  var blue = parseInt(hexColorString.substring(4, 6), 16);

  return [alphaBlend(red, alpha), alphaBlend(green, alpha), alphaBlend(blue, alpha)].join('');
}

// returns properly padded 2 digit hex strings for RGB color channels
function toHexColorChannel(decimal) {
  var hex = decimal.toString(16);
  return (hex.length === 1 ? '0' : '') + hex;
}

// Alpha blend a color channel white 
function alphaBlend(colorChannel, alpha) {
  return toHexColorChannel(Math.round((colorChannel * alpha + 255 * (255 - alpha)) / 255));
}

// called on the start of each section, initalizes the first color from the active color cycle.
function nextColor() {
  state.currentColorIndex = state.currentColorIndex + 1;
  if (state.currentColorIndex >= state.activeColorCycle.length) {
    state.currentColorIndex = 0;
  }

  state.currentHexColor = state.activeColorCycle[state.currentColorIndex];
}

// should the current sction be cut (using a stroke) or etched (using a fill)?
var useFillForSection = false;
/**
 * For Etch/Vaporize/Engrave, returns fill settings, otherwise none
 */
function fill() {
  if (useFillForSection) {
    return "fill=\"" + state.currentHexColor + "\"";
  }
  return "fill=\"none\"";
}

/**
 * For through cuts, returns stroke settings, otherwise none
 */
function stroke() {
  if (useFillForSection) {
    return "stroke=\"none\"";
  }
  return "stroke=\"" + state.currentHexColor + "\" stroke-width=\"" + properties.lineWidth + "\"";
}

// update the allowMoveCommandNext flag
function allowMoveCommand() {
  state.allowMoveCommandNext = true;
}

var activePathElements = [];
function addPathElement() {
  var args = [].slice.call(arguments);

  // alont allow moves after a rapid or similar move
  if (args[0] === "M"){
    if (state.allowMoveCommandNext) {
      // if this is a move, this should disable further moves untill rapid or similar is detected.
      state.allowMoveCommandNext = false;
    }
    else {
      // skip rendering this move command since it was not preceeded by a rapid move
      return;
    }
  }

  activePathElements.push(args.join(" "));
}

function finishPath() {
  if (!activePathElements || activePathElements.length === 0) {
    error('An operation resulted in no detectable paths!');
    return;
  }

  var opComment = hasParameter("operation-comment") ? getParameter("operation-comment") : "[No Title]";

  writeln("<g id=\"opperation-" + (1 + currentSection.getId()) + "\">");
  writeln("    <title>" + opComment + " (" + localize("Op") + ": " + (1 + currentSection.getId()) + "/" + getNumberOfSections() + ")</title>");
  writeln("    <path d=\"" + activePathElements.join("\n             ") + "\" "
    + fill() 
    + " "
    + stroke()
    + "/>")
  writeln("</g>");
  activePathElements = [];
  allowMoveCommand();
}

// return true if the program should halt because of missing radius compensation in the computer.
function isRadiusCompensationInvalid() {
  if (properties.checkForRadiusCompensation === true && (radiusCompensation != RADIUS_COMPENSATION_OFF)) {
    error("Operation: " + (1 + currentSection.getId()) + ". The Sideways Compensation type 'In Control' is not supported. This must be set to 'In Computer' in the passes tab.");
  }
}

/** Returns the given spatial value in MM. */
function toMM(value) {
  return value * ((unit == IN) ? 25.4 : 1);
}

function printVector(v) {
  return v.x + "," + v.y;
}

function onOpen() {
  if (properties.margin < 0) {
    error(localize("Margin must be 0 or positive."));
    return;
  }

  // reset all per-run state
  state = reset();
  
  // select colors now that the number of ops is available
  selectColors();

  var box = getWorkpiece();
  var dx = toMM(box.upper.x - box.lower.x);
  var dy = toMM(box.upper.y - box.lower.y);

  // add margins to overall SVG size
  var width = dx + (2 * properties.margin);
  var height = dy + (2 * properties.margin);
  
  if (properties.useWorkArea === true) {
    // no margins in useWorkArea mode, you get the work area as your margins!
    width = Math.max(properties.workAreaWidth, dx);
    height = Math.max(properties.workAreaHeight, dy);
    state.workAreaTooSmall = dx > properties.workAreaWidth || dy > properties.workAreaHeight;
  }
  log("Work Area Width: " + state.xyzFormat.format(width));
  log("Work Area Height: " + state.xyzFormat.format(height));

  /*
   * Compensate for Stock Point, SVG Origin, Z axis orientation and margins
   *
   * The *correct* stock point to select is the lower left corner and the right Z axis orientation is pointing up from the stock towards the laser.
   * But to make the learning curve a little gentler we will compensate if you didnt do that.
   *
   * Auto Stock Point Compensation: 
   * First, any stock point will produce the same image, here we correct for the stock point with a translation of the entire SVG contents
   * in x and y. We want to use the extents of the X and Y axes. Normally X comes from the lower right corner of the stock and Y from the 
   * upper left (assuming a CAM origin in the lower left corner).
   *
   * Y Axis in SVG vs CAM: 
   * If we do nothing the image would be upside down because in SVG the Y origin is at the TOP of the image (see https://www.w3.org/TR/SVG/coords.html#InitialCoordinateSystem).
   * So normally the Y axis must be flipped to compensate for this by scaling it to -1.
   * 
   * Incorrect Z Axis Orientation:
   * If the user has the Z axis pointing into the stock the SVG image will be upside down (flipped in Y, twice!). This is annoying and is not obvious to fix
   * because X and Y look right in the UI. So the "Flip Model" parameter is provided and does *magic* by turning off the default Y flipping. Now the Y axis is only flipped once
   * like we need for the SVG origin. But the *lower* box point has to be used to get the Y extent in this case because the *CAM* is upside down (CAM origin is top left corner).
   * Unfortunatly the stock point selection changes the ratio between Y values in the upper and lower stock points, so its impossible to detect this without assuming a stock point.
   * So this is as good as we can do.
   *
   * Margins:
   * Add 1 magin width to these numbers so the image is centred.
   */
  var yAxisScale = properties.doNotFlipYAxis ? 1 : -1;
  var translateX = 0;
  var translateY = 0;

  if (properties.useWorkArea === true) {
    // FIXME: this is probably wrong if the design turns out to be bigger than the work area, e.g. (width - dx) will be negative!
    translateX = state.xyzFormat.format(-toMM(box.lower.x) + ((width - dx) / 2));
    translateY = state.xyzFormat.format(toMM(box.upper.y) + ((height - dy) / 2));
  }
  else if (properties.autoStockPoint === true) {
    translateX = state.xyzFormat.format(toMM(-1 * box.lower.x) + properties.margin);
    translateY = state.xyzFormat.format(toMM(-1 * yAxisScale * (properties.doNotFlipYAxis ? box.lower.y : box.upper.y)) + properties.margin);
  }
  // else dont translate anythng.

  writeln("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>");
  writeln("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + state.xyzFormat.format(width) + "mm\" height=\"" + state.xyzFormat.format(height) + "mm\" viewBox=\"0 0 " + state.xyzFormat.format(width) + " " + state.xyzFormat.format(height) + "\">");
  writeln("<desc>Created with " + description + " for Fusion 360. To download visit: " + POST_URL + "</desc>");

  // write a comment explaining what info we got from the CAM system about the stock and coordinate system
  writeln("<!-- CAM Setup Info:"
    + "\nStock height: " + height 
    + "\nStock width: " + width 
    + "\nStock box Upper Right: " + printVector(box.upper) 
    + "\nStock box Lower Left: " + printVector(box.lower)
    + "\nOrigin: " + printVector(getCurrentPosition())
    + "\nSelected Colors: " + state.activeColorCycle.join(", ")
    + "\n-->");

  // translate + scale operation to flip the Y axis so the output is in the same x/y orientation it was in Fusion 360
  writeln("<g id=\"global-translation-frame\" transform=\"translate(" + translateX + ", " + translateY + ") scale(1, " + yAxisScale + ")\">");
}

function onClose() {
  writeln("</g>");
  // draw an untranslated box to represent the work are boundary on top of everything
  if (state.workAreaTooSmall === true) {
    writeln("<rect x=\"" + state.xyzFormat.format(0) + "\" y=\"" + state.xyzFormat.format(0) + "\" width=\"" + state.xyzFormat.format(properties.workAreaWidth) + "\" height=\"" + state.xyzFormat.format(properties.workAreaHeight) + "\" style=\"fill:none;stroke:red;stroke-width:1;\"/>");
  }
  writeln("</svg>");
}

function onComment(text) {
  writeln('<!--' + text + '-->');
}

function onSection() {
  switch (tool.type) {
  case TOOL_WATER_JET: // allow any way for Epilog
    warning(localize("Using waterjet cutter but allowing it anyway."));
    break;
  case TOOL_LASER_CUTTER:
    break;
  case TOOL_PLASMA_CUTTER: // allow any way for Epilog
    warning(localize("Using plasma cutter but allowing it anyway."));
    break;
  case TOOL_MARKER: // allow any way for Epilog
    warning(localize("Using marker but allowing it anyway."));
    break;
  default:
    error(localize("The CNC does not support the required tool."));
    return;
  }

  // use Jet Mode to decide if the shape should be filled or have no fill
  switch (currentSection.jetMode) {
  case JET_MODE_THROUGH:
    useFillForSection = false;
    break;
  case JET_MODE_ETCHING:
  case JET_MODE_VAPORIZE:
    useFillForSection = true
    break
  default:
    error(localize("Unsupported cutting mode."));
    return;
  }

  var remaining = currentSection.workPlane;
  if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
    error(localize("Tool orientation is not supported."));
    return;
  }
  setRotation(remaining);
  nextColor();
}

function onParameter(name, value) {
}

function onDwell(seconds) {
}

function onCycle() {
}

function onCyclePoint(x, y, z) {
}

function onCycleEnd() {
}

function writeLine(x, y) {
  isRadiusCompensationInvalid();
  
  switch (movement) {
  case MOVEMENT_CUTTING:
  case MOVEMENT_REDUCED:
  case MOVEMENT_FINISH_CUTTING:
    break;
  case MOVEMENT_RAPID:
  case MOVEMENT_HIGH_FEED:
  case MOVEMENT_LEAD_IN:
  case MOVEMENT_LEAD_OUT:
  case MOVEMENT_LINK_TRANSITION:
  case MOVEMENT_LINK_DIRECT:
  default:
    allowMoveCommand();
    return; // skip
  }

  var start = getCurrentPosition();
  if ((state.xyzFormat.format(start.x) == state.xyzFormat.format(x)) &&
      (state.xyzFormat.format(start.y) == state.xyzFormat.format(y))) {
    log('vertical move ignored');
    return; // ignore vertical
  }

  addPathElement("M", state.xyzFormat.format(start.x), state.xyzFormat.format(start.y));
  addPathElement("L", state.xyzFormat.format(x), state.xyzFormat.format(y));
}

function onRapid(x, y, z) {
  writeLine(x, y);
}

function onLinear(x, y, z, feed) {
  writeLine(x, y);
}

function onRapid5D(x, y, z, dx, dy, dz) {
  onRapid(x, y, z);
}

function onLinear5D(x, y, z, dx, dy, dz, feed) {
  onLinear(x, y, z);
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  isRadiusCompensationInvalid();
  
  switch (movement) {
  case MOVEMENT_CUTTING:
  case MOVEMENT_REDUCED:
  case MOVEMENT_FINISH_CUTTING:
    break;
  case MOVEMENT_RAPID:
  case MOVEMENT_HIGH_FEED:
  case MOVEMENT_LEAD_IN:
  case MOVEMENT_LEAD_OUT:
  case MOVEMENT_LINK_TRANSITION:
  case MOVEMENT_LINK_DIRECT:
  default:
    allowMoveCommand();
    return;
  }

  var start = getCurrentPosition();

  var largeArc = (getCircularSweep() > Math.PI) ? 1 : 0;
  var sweepFlag = isClockwise() ? 0 : 1;
  addPathElement("M", state.xyzFormat.format(start.x), state.xyzFormat.format(start.y));
  addPathElement("A", state.xyzFormat.format(getCircularRadius()), state.xyzFormat.format(getCircularRadius()), 0, largeArc, sweepFlag, state.xyzFormat.format(x), state.xyzFormat.format(y));
}

function onCommand() {
}

function onSectionEnd() {
  finishPath();
  nextColor();
}
