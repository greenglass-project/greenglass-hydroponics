include <parameters.scad>


module base_panel() {
    union() {
        difference() {
            linear_extrude(panel_thickness) {
                square([lip_inner_x, lip_inner_y], true);
            }
            union() {
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
        }
        translate([-pi_mount_x/2, pi_mount_y/2, panel_thickness]) {
           union() {
                linear_extrude(top_mount_height)
                    circle(d=6, $fn = 128);
                translate([0,0,top_mount_height]){
                        linear_extrude(4)
                    circle(d=3.0, $fn = 128);
                
                }
            }
        }
        translate([pi_mount_x/2, pi_mount_y/2, panel_thickness]) {
          union() {
                linear_extrude(top_mount_height)
                    circle(d=6, $fn = 128);
                translate([0,0,top_mount_height]){
                        linear_extrude(4)
                    circle(d=3.0, $fn = 128);
                
                }
            }
        }   
        translate([pi_mount_x/2, -pi_mount_y/2, panel_thickness]) {
          union() {
                linear_extrude(top_mount_height)
                    circle(d=6, $fn = 128);
                translate([0,0,top_mount_height]){
                        linear_extrude(4)
                    circle(d=3.0, $fn = 128);
                
                }
            } 
        }   
        translate([-pi_mount_x/2, -pi_mount_y/2, panel_thickness]) {
              union() {
                linear_extrude(top_mount_height)
                    circle(d=6, $fn = 128);
                translate([0,0,top_mount_height]){
                        linear_extrude(4)
                    circle(d=3.0, $fn = 128);
                
                }
            }
        }
    }
}
