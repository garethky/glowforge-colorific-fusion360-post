# glowforge-colorific-fusion360-post

## What is this?
This is a Post (https://cam.autodesk.com/hsmposts) for Fusion 360 and Autodesk HSM that produces SVG files from CAM operations that can be loaded intot he Glowforge App.
This work is based on the original Post provided by Autodesk and as such their copyright remains.

## Goal
The goal of this post is to eliminate the need to perform any post-processing of the SVG in Inkscape or another SVG package. Several alternatives exist but none of them produce a properly formed SVG file and they all require processing in some way, weather to assign colors, join paths or make solids out of empty shells.

## Improvements
* Produce propperly formed SVG paths that remain connected in the Glowforge App.
* Automatically color each CAM op with a unique color so Glowforge App imports each one as a seperate steps.
* Steps are ordered exactly as CAM ops are ordering in Fusion 360. This is acheived by sorting the color values used to work with Glowforge Apps internal ordering.
* Automatic color generation for large numbers of operations (think power & speed test patterns).
* Support engraving with filled shapes. This is configurable in each CAM Op so cuts and engraves can be mixed in the same setup.
* Automatically detect the selected Stock Point of the CAM setup and compensate for this so the SVG content is not off screen.
* Add an option to compensate for inverted Z axis in the setup.
* Support centering the SVG content in a frame the size of the Glowforge bed (size is configurable)
* Add comments to and names and IDs to SVG elements. Each op is numbered with a unique ID. Comments are supported as HTML comments.
* Support centering the design in the machine workspace with the 'Use Work Area' option.
* Show a red error box if your design is larger than the machine workspace size when 'Use Work Area' is on.

## Wishlist
* Scoring support - this is no currently officially suppoorted by Glowforge. Dashed lines seem like the obvious choice but thye produce an error.
* Feeds & Speeds for custom materials - Ideally this could vary by opperation and would be a part of the Tool used in the CAM operation. Needs support Glowforge App.

# License
Copyright (C) 2018 by Autodesk, Inc.
All rights reserved.

This work is based on an original work by Autodesk, Inc. Ths work is provided *Gratis* but *not Libre*, see: https://en.wikipedia.org/wiki/Gratis_versus_libre
This was developed for my own personal use and posted so that others (including Autodesk, Inc.) might benefit from this effort.

# Documentation
TK
