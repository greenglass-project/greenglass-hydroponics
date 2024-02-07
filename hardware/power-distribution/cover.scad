include <Round-Anything/polyround.scad>
include <parameters.scad>



slot_width = 54;
slot_height = 8;

slot_offset = 4.5;


cover();

module cover() {
    difference() {
        union() {
            difference() {

                linear_extrude(lid_height)
                    polygon(polyRound(base_polygon, 256));
                union() {
                    translate([0,0,panel_thickness]) {
                        linear_extrude(lid_height-panel_thickness)
                            polygon(polyRound(lip_inner_polygon, 256));
                    }
                    
                    translate([0,0,lid_height-lip_height]) {
                        linear_extrude(lip_height)
                            polygon(polyRound(lip_outer_polygon , 256));
                    }
                    
                    translate([0, slot_offset,0])
                        linear_extrude(panel_thickness)
                            square([slot_width, slot_height], true);

                }
            }
            top_mounts();
        }
        union() {
            translate([0,0, lid_height-lip_height])
                top_mount_cutouts();
            translate([0,0, lid_height-lip_height-hole_depth])
                top_mount_holes();

         }
    }
}

module top_mounts() {
    translate([-length/2 + top_mount_offset, width/2 - top_mount_offset,0])
        linear_extrude(lid_height)
            circle(d=6);
    translate([length/2 - top_mount_offset, width/2 - top_mount_offset, 0])
        linear_extrude(lid_height)
            circle(d=6);
    translate([length/2 - top_mount_offset, -width/2 + top_mount_offset, 0])
        linear_extrude(lid_height)
            circle(d=6);
    translate([-length/2 + top_mount_offset, -width/2 + top_mount_offset, 0])
        linear_extrude(lid_height)
            circle(d=6);
}

module top_mount_cutouts() {
    translate([-length/2 + top_mount_offset, width/2 - top_mount_offset,0])
        linear_extrude(lip_height)
            circle(d=6);
    translate([length/2 - top_mount_offset, width/2 - top_mount_offset, 0])
        linear_extrude(lip_height)
            circle(d=6);
    translate([length/2 - top_mount_offset, -width/2 + top_mount_offset, 0])
        linear_extrude(lip_height)
            circle(d=6);
    translate([-length/2 + top_mount_offset, -width/2 + top_mount_offset, 0])
        linear_extrude(lip_height)
            circle(d=6);
}

module top_mount_holes() {
    translate([-length/2 + top_mount_offset, width/2 - top_mount_offset,0])
        linear_extrude(hole_depth)
            circle(d=3);
    translate([length/2 - top_mount_offset, width/2 - top_mount_offset, 0])
        linear_extrude(hole_depth)
            circle(d=3);
    translate([length/2 - top_mount_offset, -width/2 + top_mount_offset, 0])
        linear_extrude(hole_depth)
            circle(d=3);
    translate([-length/2 + top_mount_offset, -width/2 + top_mount_offset, 0])
        linear_extrude(hole_depth)
            circle(d=3);
}
