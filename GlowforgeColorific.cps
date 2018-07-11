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
  * Add options for drawing lines and filling in shapes with color
  * If you use Etch or Vaporize this enables fill for that toolpath
  * Made line width an option
  * Made Sideways Compensation 'In Control' checking an option thats off by default.
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
  drawLines: true, // draw lines for cutter paths
  fillShapes: false, // fill shapes with a fill color
  useWCS: true, // do not center the toolpath
  width: 20 * 25.4, // width in mm used when useWCS is disabled
  height: 12 * 25.4, // height in mm used when useWCS is disabled
  margin: 0.25 * 25.4, // margin in mm
  checkForRadiusCompensation: false // if enabled throw an error if compensation in control is used
};

// user-defined property definitions
propertyDefinitions = {
  lineWidth: {title:"Line Width", description:"The width of lines in the SVG in mm.", type:"number"},
  drawLines: {title:"Draw Lines", description:"Draw tool paths as lines.", type:"boolean"},
  fillShapes: {title:"Fill Shapes", description:"Fill closed polygons with a fill color.", type:"boolean"},
  useWCS: {title:"Use WCX", description:"Do not center the toolpath.", type:"boolean"},
  width: {title:"Height(mm", description:"Height in mm, used when useWCS is disabled.", type:"number"},
  height: {title:"Height(mm)", description:"Height in mm, used when useWCS is disabled.", type:"number"},
  margin: {title:"Margin(mm)", description:"Sets the margin in mm.", type:"number"},
  checkForRadiusCompensation: {title:"Validate Sideways Compensation ", description:"Check each opperation for Sideways Compensation in Control. If this is configured, throw an error.", type:"boolean"},
};

var postUrl = "https://cam.autodesk.com/hsmposts?p=glowforge";
var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4)});

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
var useFillForSection = false;
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

function fill() {
  if (properties.fillShapes || useFillForSection) {
    return "fill=\"" + cuttingColor + "\" fill-opacity=\"0.25\" fill-rule=\"evenodd\"";
  }
  return "fill=\"none\"";
}

function canDrawLines() {
  // if you disable BOTH lines and fill, the default is to draw lines. So you can have these options:
  // * just lines
  // * just fill
  // * both
  return properties.drawLines === true || properties.fillShapes === false;
}

function stroke() {
  if(canDrawLines()) {
    return "stroke=\"" + cuttingColor + "\" stroke-width=\"" + properties.lineWidth + "\"";
  }
  return "stroke=\"none\"";
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

function onOpen() {
  writeln("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>");

  var WIDTH = 20 * 25.4;
  var HEIGHT = 12 * 25.4;

  if (properties.margin < 0) {
    error(localize("Margin must be 0 or positive."));
    return;
  }

  var box = getWorkpiece();
  var dx = toMM(box.upper.x - box.lower.x) + 2 * properties.margin;
  var dy = toMM(box.upper.y - box.lower.y) + 2 * properties.margin;

  log("Width: " + xyzFormat.format(dx));
  log("Height: " + xyzFormat.format(dy));

  var width = WIDTH;
  var height = HEIGHT;

  var useLandscape = false;

  if (properties.useWCS) {
    width = dx;
    height = dy;
  } else {
    if ((dx > width) || (dy > height)) {
      if ((dx <= height) && (dy <= width)) {
        useLandscape = true;
        width = HEIGHT;
        height = WIDTH;
      }
    }

    log("Sheet width: " + xyzFormat.format(width));
    log("Sheet height: " + xyzFormat.format(height));

    if (dx > width) {
      warning(localize("Toolpath exceeds sheet width."));
    }
    if (dy > height) {
      warning(localize("Toolpath exceeds sheet height."));
    }
  }

  writeln("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + xyzFormat.format(width) + "mm\" height=\"" + xyzFormat.format(height) + "mm\" viewBox=\"0 0 " + xyzFormat.format(width) + " " + xyzFormat.format(height) + "\">");
  writeln("<desc>Created with " + description + " for Fusion 360. To download visit: " + postUrl + "</desc>");
  
  // invert y axis
  writeln("<g transform=\"translate(" + xyzFormat.format(0) + ", " + xyzFormat.format(height) + ")\"/>");
  writeln("<g transform=\"scale(1, -1)\"/>");

  if (properties.useWCS) {
    // adjust for margin
    writeln("<g transform=\"translate(" + xyzFormat.format(-toMM(box.lower.x) + properties.margin) + ", " + xyzFormat.format(-toMM(box.lower.y) + properties.margin) + ")\"/>");
  } else {
    // center on sheet
    writeln("<g transform=\"translate(" + xyzFormat.format(-toMM(box.lower.x) + (width - dx)/2) + ", " + xyzFormat.format(-toMM(box.lower.y) + (height - dy)/2) + ")\"/>");
  }

  // we output in mm always so scale from inches
  xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), scale:(unit == MM) ? 1 : 25.4});
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
  writeln("</svg>");
}
