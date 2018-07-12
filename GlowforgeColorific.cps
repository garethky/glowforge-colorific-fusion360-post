/**
  Copyright (C) 2015 by Autodesk, Inc.
  All rights reserved.

  $Revision: 41602 8a235290846bfe71ead6a010711f4fc730f48827 $
  $Date: 2017-09-14 12:16:32 $
  
  FORKID {2E27B627-115A-4A16-A853-5B9B9D9AF480}
*/

/**
  Changes by Gareth:
  * changed name to "GlowforgeColorific" to make testing alongside Glowforge post easier
  * remove useColorMapping setting
  * Add color cycling on section end, 15 colors.
  * Join cuts from each opperation into a single path.
  * Supress extra move commands that broke shapes into line segments
  * Join all cuts from an op into a sigle path for propper inside/outside detection for engraving.
  * Wrap each operation in a group and give it a helpful title
  * If you use Etch or Vaporize this enables fill for that toolpath
  * Made line width an option
  * Made Sideways Compensation 'In Control' checking an option thats off by default.
  * Always use WCS, removed option to not do that and related options for work area
  * Added option to "Flip Model" to solve non-obvious Z inversion in CAM
*/

//description = "Glowforge";
description = "GlowforgeColorific";
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

properties = {
  lineWidth: 0.1, // how wide lines are in the SVG
  margin: 2, // margin in mm
  checkForRadiusCompensation: false, // if enabled throw an error if compensation in control is used
  doNotFlipYAxis: false
};

// user-defined property definitions
propertyDefinitions = {
  lineWidth: {title: "SVG Stroke Width(mm)", description: "The width of lines in the SVG in mm.", type: "number"},
  margin: {title: "Margin(mm)", description: "Sets the margin in mm.", type: "number"},
  checkForRadiusCompensation: {title: "Check Sideways Comp.", description: "Check every opperation for Sideways Compensation 'In Computer'. If this is not configured, throw an error.", type: "boolean"},
  doNotFlipYAxis: {title: "Flip Model", description: "If your part is upside down, check this box to flip it over. (Tip: checking 'Flip Z Axis' in the CAM setup also fixes this)", type: "boolean"}
};

var postUrl = "https://cam.autodesk.com/hsmposts?p=glowforge";
var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), scale:(unit == MM) ? 1 : 25.4});

// Recommended colors for color mapping.
var COLOR_GREEN = "#1FB714";
var COLOR_YELLOW = "#FBF305";
var COLOR_DARK_GREEN = "#006412";
var COLOR_ORANGE = "#FF6403";
var COLOR_BROWN = "#562C05";
var COLOR_RED = "#DD0907";
var COLOR_TAN = "#90713A";
var COLOR_MAGENTA = "#F20884";
var COLOR_LIGHT_GREY = "#C0C0C0";
var COLOR_PURPLE = "#4700A5";
var COLOR_MEDIUM_GREY = "#808080";
var COLOR_BLUE = "#0000D3";
var COLOR_DARK_GREY = "#404040";
var COLOR_CYAN = "#02ABEA";
var COLOR_BLACK = "#000000";

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
var cuttingColor = null;
var currentColorIndex = -1;

// called on the start of each section, initalizes the first color as CYAN.
function nextColor() {
  currentColorIndex = currentColorIndex + 1;
  if (currentColorIndex >= COLOR_CYCLE.length) {
    currentColorIndex = 0;
  }

  cuttingColor = COLOR_CYCLE[currentColorIndex];
}
nextColor();

// should the current sction be cut (using a stroke) or etched (using a fill)?
var useFillForSection = false;
/**
 * For Etch/Vaporize/Engrave, returns fill settings, otherwise none
 */
function fill() {
  if (useFillForSection) {
    return "fill=\"" + cuttingColor + "\" fill-opacity=\"0.5\" fill-rule=\"evenodd\"";
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
  return "stroke=\"" + cuttingColor + "\" stroke-width=\"" + properties.lineWidth + "\"";
}

// track if the next path element can be a move command
var allowMoveCommandNext = true;

// update the allowMoveCommandNext flag
function allowMoveCommand() {
  allowMoveCommandNext = true;
}

var activePathElements = [];
function addPathElement() {
  var args = [].slice.call(arguments);

  // alont allow moves after a rapid or similar move
  if (args[0] === "M"){
    if (allowMoveCommandNext) {
      // if this is a move, this should disable further moves untill rapid or similar is detected.
      allowMoveCommandNext = false;
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

  var box = getWorkpiece();

  // add margins to overall SVG size
  var width = toMM(box.upper.x - box.lower.x) + (2 * properties.margin);
  var height = toMM(box.upper.y - box.lower.y) + (2 * properties.margin);
  log("Width: " + xyzFormat.format(width));
  log("Height: " + xyzFormat.format(height));

  /*
   * Compensate for Stock Point, SVG Origin, Z axis orientation and margins
   *
   * The *correct* stock point to select is the lower left corner and the right Z axis orientation is pointing up from the stock towards the laser.
   * But to make the learning curve a little gentler we will compensate if you didnt do that.
   *
   * Stock Point Compensation: 
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
  var translateX = xyzFormat.format(toMM(-1 * box.lower.x) + properties.margin);
  var translateY = xyzFormat.format(toMM(-1 * yAxisScale * (properties.doNotFlipYAxis ? box.lower.y : box.upper.y)) + properties.margin);
  
  writeln("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>");
  writeln("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + xyzFormat.format(width) + "mm\" height=\"" + xyzFormat.format(height) + "mm\" viewBox=\"0 0 " + xyzFormat.format(width) + " " + xyzFormat.format(height) + "\">");
  writeln("<desc>Created with " + description + " for Fusion 360. To download visit: " + postUrl + "</desc>");

  // write a comment explaining what info we got from the CAM system about the stock and coordinate system
  writeln("<!-- CAM Setup Info:"
    + "\nStock height: " + height 
    + "\nStock width:" + width 
    + "\nStock box top left: " + printVector(box.upper) 
    + "\nStock box bottom right: " + printVector(box.lower) 
    + "\n-->");
  
  // translate + scale operation to flip the Y axis so the output is in the same x/y orientation it was in Fusion 360
  writeln("<g id=\"global-translation-frame\" transform=\"translate(" + translateX + ", " + translateY + ") scale(1, " + yAxisScale + ")\">");
}

function onComment(text) {
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
  /*
  case TOOL_MARKER: // allow any way for Epilog
    warning(localize("Using marker but allowing it anyway."));
    break;
  */
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
    useFillForSection = true;
    break;
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
  if ((xyzFormat.format(start.x) == xyzFormat.format(x)) &&
      (xyzFormat.format(start.y) == xyzFormat.format(y))) {
    return; // ignore vertical
  }

  addPathElement("M", xyzFormat.format(start.x), xyzFormat.format(start.y));
  addPathElement("L", xyzFormat.format(x), xyzFormat.format(y));
}

function onRapid(x, y, z) {
  //writeln("<!-- onRapid -->");
  writeLine(x, y);
}

function onLinear(x, y, z, feed) {
  //writeln("<!-- onLinear -->");
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
  addPathElement("M", xyzFormat.format(start.x), xyzFormat.format(start.y));
  addPathElement("A", xyzFormat.format(getCircularRadius()), xyzFormat.format(getCircularRadius()), 0, largeArc, sweepFlag, xyzFormat.format(x), xyzFormat.format(y));
}

function onCommand() {
}

function onSectionEnd() {
  finishPath();
  nextColor();
}

function onClose() {
  writeln("</g>");
  writeln("</svg>");
}
