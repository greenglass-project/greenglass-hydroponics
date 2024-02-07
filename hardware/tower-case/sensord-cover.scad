include <cover.scad>

cutout_x = 50;
cutout_y = 15;

cutout_offset = 26;

cutout_z = lid_height - cutout_offset - cutout_y/2;


difference() {
    
    cover();
    rotate([0,0,90]) {
        union() {
            translate([width/2-top_thickness/2, 0, cutout_z]) {
                linear_extrude(cutout_y) 
                    square([top_thickness, cutout_x ], true);
            }
            translate([width/2-top_thickness/2 - lip_thickness/2, 0,  cutout_z + cutout_y]) {
                linear_extrude(lid_height-cutout_z - cutout_y) 
                    square([top_thickness, cutout_x ], true);
            }
        }
     }
 }
