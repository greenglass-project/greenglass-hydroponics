include <Round-Anything/polyround.scad>
include <parameters.scad>

mount_thickness = 2.5;
hat_mount_offset = 2;
hat_mount_size = 6.5;

lower_offset = 4;

//hat_mount(4);
//notches();

module section(section_height) {
    difference() {
        difference() {
            union() {
                linear_extrude(section_height)
                    difference() {
                        polygon(polyRound(base_polygon, 256));
                        polygon(polyRound(lip_inner_polygon, 256));
                    }
                    translate([0,0,section_height])
                        lip();

            }
            lip();
        }
        notches();
    }

 }
 

module mount_plate() {
    cutout_width = 52;
    union() {
        difference() {
            linear_extrude(mount_thickness ) 
                polygon(polyRound(lip_inner_polygon, 256));
            linear_extrude(mount_thickness ) 
                square([cutout_width, lip_inner_y], true);
        }   
     }

 }

 
module hat_mount(height) {
    translate([0,0,lower_offset]) {

    linear_extrude(lip_height)
        difference() {
            union() {
                translate([-pi_mount_x/2 - hat_mount_offset, pi_mount_y/2 + hat_mount_offset, 99])
                    square([hat_mount_size, hat_mount_size], true);
                translate([-pi_mount_x/2, pi_mount_y/2, 0])
                    circle(d=6, $fn=128);
            }
            translate([-pi_mount_x/2, pi_mount_y/2, 0])
                circle(d=2.5, $fn=128);
        }
        
    linear_extrude(lip_height)
        difference() {
           union() {
                translate([pi_mount_x/2 + hat_mount_offset, pi_mount_y/2 + hat_mount_offset, 0])
                    square([hat_mount_size, hat_mount_size], true);
                translate([pi_mount_x/2, pi_mount_y/2, 0])
                    circle(d=6, $fn=128);
            }
            translate([pi_mount_x/2, pi_mount_y/2, 0])
                circle(d=2.5, $fn=128);
        }
        
     linear_extrude(lip_height)
        difference() {
           union() {
                translate([pi_mount_x/2 + hat_mount_offset, -pi_mount_y/2 - hat_mount_offset, 0])
                    square([hat_mount_size, hat_mount_size], true);
                translate([pi_mount_x/2, -pi_mount_y/2, 0])
                    circle(d=6, $fn=128);
            }
            translate([pi_mount_x/2, -pi_mount_y/2, 0])
                circle(d=2.5, $fn=128);
        }   

     linear_extrude(lip_height)
        difference() {
           union() {
                translate([-pi_mount_x/2 - hat_mount_offset, -pi_mount_y/2 - hat_mount_offset, 0])
                    square([hat_mount_size, hat_mount_size], true);
                translate([-pi_mount_x/2, -pi_mount_y/2, 0])
                    circle(d=6, $fn=128);
            }
            translate([-pi_mount_x/2, -pi_mount_y/2, 0])
                circle(d=2.5, $fn=128);
        }   
        }
    }
        


    /*mount(-pi_mount_x/2, pi_mount_y/2, 6, height, 2.5);
    mount(pi_mount_x/2, pi_mount_y/2, 6, height, 2.5);
    mount(pi_mount_x/2, -pi_mount_y/2, 6, height, 2.5);
    mount(-pi_mount_x/2, -pi_mount_y/2, 6, height, 2.5);
    
    
}(/


/*module hat_mount(height) {
    translate([-pi_mount_x/2, pi_mount_y/2, 0])
        corner_mount(height, 6, 2.5);

}*/


    




