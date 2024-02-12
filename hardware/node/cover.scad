
include <Round-Anything/polyround.scad>
include <parameters.scad>


cutout_x = length-2*top_mount_offset-6;
cutout_y = width--5*top_mount_offset-6;

hole_depth = 10;


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
                    
                    linear_extrude(panel_thickness)
                        square([60, 60], true);
                        //square([cutout_x,cutout_y],true);
                    translate([0,0,lid_height-lip_height]) {
                        linear_extrude(lip_height)
                            polygon(polyRound(lip_outer_polygon , 256));
                    }
                    
                }
            }
            top_mounts();
        }
        union() {
            translate([0,0, lid_height-lip_height])
                top_mount_cutouts();
            translate([0,0, lid_height-lip_height-hole_depth])
                top_mount_holes();
            translate([lip_inner_x/2 + lip_thickness/4, -usb_offset, lid_height-usb_cutout_height]) 
                linear_extrude(usb_cutout_height)
                    square([lip_thickness, usb_width + 4], true);
            translate([lip_inner_x/2 + lip_thickness/2,  -usb_offset, lid_height - usb_centre_z-usb_height/2]) 
                linear_extrude(usb_height)
                    square([2*lip_thickness, usb_width], true);
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



