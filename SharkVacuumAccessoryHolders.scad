/**
 * SPDX-FileCopyrightText: 2024 Simon Redman <simon@ergotech.com>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only
 */

// The number of accessory holders to produce
numAccessoryHolders = 2; // [1:10]

// The depth of the cavity which contains the accessory. 53mm is just enough to fully contain the nozzle on my accessories.
holderDepth = 53; // [15:60]

// The center-to-center distance between accessory holders, in mm. 135mm is about right for a floor roller.
accessoryHolderSpacing = 100; //[75:200]

// The height of the structure between the accessory holders
wallPlateHeight = 40; // [10:53]

// The size of the screw holes, in mm. Be sure to include necessary clearance. 5mm corresponds to roughly a #10 SAE screw. Set to zero for no screw holes.
screwHoleDiameter = 5; // [0:10]

// Screw head size, in mm. Set this to the size of the screws you plan to use for mounting. Zero for no screw head clearance.
screwHeadDiameter = 11; // [0:50]

/* [Hidden] */

// Measured Constants. May be useful to change these to make accessory holders for slightly-different vacuums.
// I am defining the nozzle as the part of the accessory which goes into the vacuum, and the shell as the part of the accessory which is outside of the vacuum (the clip is on the shell).
// All units in millimeters.

// The longer measurement of the accessory nozzle, perpendicular to the acuation direction of the clip.
nozzleLongDimension = 36.0;

// The shorter measurement of the accessory nozzle, parallel to the actuation direction of the clip.
nozzleShortDimension = 27.5;

// The measurement of the shell in the same axis as the nozzleLongDimension.
shellOutsideLongDimension = 45.0;

// The measurement of the shell in the same axis as the nozzleShortDimension.
shellOutsideShortDimension = 46.5;

// The size of the "clippy" part of the clip, same axis as nozzleLongDimension.
clipInnerWidth = 14.2;

// The height of the "clippy" part of the clip, parallel to the long axis of the accessory.
clipInnerHeight = 5.0;

// The clearance needed for the clip to swing. Same axis as the nozzleShortDimension.
clipThickness = 9.0;

// The height of the clip from the shell. There should be a cutout starting here.
clipHeight = 7.5;

// The distance between the nozzle and the outer shell, measured at the point of the clip. The clip would clip in here.
nozzleShellClipDistance = 3;

// The distance between the nozzle and the outer shell, measured on the opposite size from the clip.
nozzleShellRearDistance = 17.0;

// The shell runs at an angle, with the lowest part at the clip and the highest part opposite the clip. This is the change in height between the shell at the clip, and the shell at opposite side.
shellRearHeightLoss = 12.0;

// The rear shell footprint is roughly an oval with the long diameter of shellOutsideLongDimension and the short radius of this value.
// Controls the round-ness of the rear of the accessory holder.
shellRearShortRadius = 14.0;

// The front shell footprint is roughly an oval with the long diameter of shellOutsideLongDimension and the short radius of this value.
// Controls the round-ness of the front of the accessory holder.
shellFrontShortRadius = 12.0;

// Some accessories, like the floor rollers, have a plug to carry power from the vacuum to the acessory. Make space for that.
powerPlugLength = 23.0;
powerPlugWidth = 10.0;
powerPlugHeight = 18.5;

// Constants

// Epsilon, used as a fudge factor when making floating point comparisons, such as in union and difference functions.
eps = 0.01;

// Whenever we produce a shell which just needs to look pretty, it should be this thick.
cosmeticShellThickness = 2.0;

// Whenever we produce a shell which actually needs to do something, it should be this thick.
structuralShellThickness = 3.0;

// Make a partial circle of the given height. Scale the result to fit your needs.
// @param a: Angle in degrees
// @param r: Cylinder radius
// @param h: Cylinder height
// @return A semi-cylinder of height h and radius r
module cylinderSlice(r, h, a){
  scale([r, r, h])
  scale([1/100, 1/100, 1]) // Make the original radius 100, then scale back to 1, to get a reasonable number of faces since scad represents circles as polygons.
  rotate_extrude(angle=a) square([100,1]);
}

// Make a single accessory holder
module makeAccessoryHolder() {
    // Create the main body of the accessory holder
    difference() {
         // Outer shell
        union() {
          // Rear rounding
          translate([
            shellOutsideLongDimension / 2,
            shellOutsideShortDimension - shellRearShortRadius,
            0
          ])
          scale([shellOutsideLongDimension / 2, shellRearShortRadius, holderDepth])
          cylinderSlice(r=1, h=1, a=180);
          // Squared middle
          translate([0, shellFrontShortRadius, 0])
          cube([shellOutsideLongDimension, shellOutsideShortDimension - shellRearShortRadius - shellFrontShortRadius, holderDepth]);
          // Front rounding
          translate([shellOutsideLongDimension / 2, shellFrontShortRadius, 0])
          rotate(180, [0, 0, 1])
          scale([shellOutsideLongDimension / 2, shellFrontShortRadius, holderDepth])
          cylinderSlice(r=1, h=1, a=180);
        }

        // Cutout for the accessory nozzle
        translate([
          (shellOutsideLongDimension - nozzleLongDimension)/2, nozzleShellClipDistance, -eps
        ])
        union() {
          translate([0, shellFrontShortRadius - eps, 0])
          cube([nozzleLongDimension, nozzleShortDimension- shellFrontShortRadius + eps, holderDepth + 2*eps]);
          translate([
            nozzleLongDimension / 2,
            shellFrontShortRadius,
            -eps
          ])
          rotate(180, [0, 0, 1])
          scale([nozzleLongDimension / 2, shellFrontShortRadius, holderDepth + 2*eps])
          cylinderSlice(r=1, h=1, a=180);
        }

        // Cut off the top at an angle
        // Use an absurdly tall cube, rotated to the appropriate angle, to make this cut.
        cutAngle = atan(shellRearHeightLoss/shellOutsideShortDimension);
        translate([
          -eps,
          0,
          holderDepth + eps
        ])
        rotate(-1 * cutAngle, [1, 0, 0])
        cube([
          shellOutsideLongDimension * 2,
          shellOutsideShortDimension * 2,
          holderDepth * 2
        ]);

        // Cutout the back area, so as not to waste materials when printing
        translate([
          (shellOutsideLongDimension - nozzleLongDimension)/2,
          nozzleShellClipDistance + nozzleShortDimension + structuralShellThickness,
          -eps
        ])
        difference() {
          // Trim the part which will be used to make the cutout, to make sure the structural shell part is not removed
          union() {
            // Join a semi-cylinder with a cube to make the cutout
            wasteSize = shellOutsideShortDimension - nozzleShellClipDistance - nozzleShortDimension - cosmeticShellThickness - structuralShellThickness;
            translate([
              nozzleLongDimension / 2,
              wasteSize - shellRearShortRadius,
              0
            ])
            scale([nozzleLongDimension / 2, shellRearShortRadius, 1])
            cylinderSlice(r=1, h=holderDepth + 2*eps, a=180);

            cube([
              nozzleLongDimension,
              wasteSize - shellRearShortRadius + eps,
              holderDepth + 2*eps
            ]);
          }

          translate([0, -structuralShellThickness, 0])
          cube([nozzleLongDimension, structuralShellThickness, holderDepth]);
        }

        // Cutout for the power plug
        translate([
          shellOutsideLongDimension/2 - powerPlugLength / 2,
          shellOutsideShortDimension - powerPlugWidth + eps,
          holderDepth - shellRearHeightLoss - powerPlugHeight + structuralShellThickness * 2 * tan(cutAngle)
        ])
        cube([powerPlugLength, powerPlugWidth, powerPlugHeight]);

        // Cutout for the clip
        translate([
          (shellOutsideLongDimension)/2,
          nozzleShellClipDistance + shellFrontShortRadius + 2*eps,
          holderDepth - clipHeight
        ])
        rotate([90, 180, 0])
        difference() {
          cylinderSlice(r=clipInnerWidth/2, h=nozzleShellClipDistance + shellFrontShortRadius + 2*eps, a=180);
        }
    }
}

module makeWallPlate() {
  difference() {
    union() {
      wallPlateSize = accessoryHolderSpacing/2;
      // The main, back part of the wall plate
      cube([wallPlateSize + eps, structuralShellThickness, wallPlateHeight]);

      // Pick the angle such that the brace will meet the center of the accessory holder and leave enough space for a screw.
      wallDistanceToBrace = wallPlateSize - (shellOutsideLongDimension / 2) - screwHeadDiameter;
      heightFromWallToBrace = (shellOutsideShortDimension - structuralShellThickness) / 2;
      wallBraceAngle = atan(heightFromWallToBrace / wallDistanceToBrace);

      wallBraceLength = heightFromWallToBrace / sin(wallBraceAngle) + structuralShellThickness / cos(wallBraceAngle);

      // The structural angle brace of the wall plate
      translate([screwHeadDiameter, 0, 0])
      rotate(wallBraceAngle, [0, 0, 1])
      cube([wallBraceLength + eps, structuralShellThickness, wallPlateHeight]);
    }

    // Screw hole
    translate([screwHeadDiameter / 2, -eps, screwHeadDiameter/2])
    rotate(-90, [1, 0, 0])
    union() {
      // The screw shaft. Only as thick as the structure, since that's what it's supposed to be going through.
      cylinderSlice(r = screwHoleDiameter/2, h = structuralShellThickness + 2*eps, a=360);
    translate([0, 0, structuralShellThickness + 2*eps])
      // The screw head - Make it really tall so it will cut through the braces if the distance between accessories is really small.
      cylinderSlice(r = screwHeadDiameter/2, h = shellOutsideShortDimension, a=360);
    }
  }
}

module makePart() {
  for (i = [0:numAccessoryHolders - 1]) {
    // Place the wall plate
    for (wallPlateIdx = [0:1]) {
      translate([i*accessoryHolderSpacing, shellOutsideShortDimension+structuralShellThickness, 0]) // Move the accessory plate to the appropriate wall mount
      translate([(1 * wallPlateIdx - 1)*accessoryHolderSpacing / 4, 0, 0]) // Move the accessory plate to the correct location
      translate([(1 * wallPlateIdx - 1) * accessoryHolderSpacing / 4 + shellOutsideLongDimension / 2, 0, 0]) // Center the wall plate on the accessory mount
      // Correct the second half for having been rotated over the X axis
      translate([(1*wallPlateIdx)*accessoryHolderSpacing/2, 0, (1*wallPlateIdx) * wallPlateHeight])
      mirror([(1*wallPlateIdx), 0, 0]) // Mirror the second mount half
      mirror([0, 0, (1*wallPlateIdx)])
      mirror([0, 1, 0])
      makeWallPlate();
    }

    // Place an accessory holder
    translate([i*(accessoryHolderSpacing), 0, 0])
    makeAccessoryHolder();
  }
}

makePart();