include <parameters.scad>

mount_distance = 49;
motor_hole = 30;
pump_width = 60;
front_panel();

module front_panel() {
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

                 pump_cutout();  
                 translate([-pump_width,0,0])
                    pump_cutout();          
                 translate([pump_width,0,0])
                    pump_cutout();                 
            } 
        }
        main_mounts();
    }
}

module main_mounts() {
    translate([-length/2 + large_mount_offset , width/2 - large_mount_offset ,0])
        large_mount();
    translate([length/2 - large_mount_offset , width/2 - large_mount_offset , 0])
        large_mount();
    
     translate([0 , width/2 - large_mount_offset ,0])
        large_mount();
    translate([0 , -width/2 + large_mount_offset , 0])
        large_mount();   
    
    translate([length/2 - large_mount_offset , -width/2 + large_mount_offset , 0])
        large_mount();
    translate([-length/2 + large_mount_offset , -width/2 + large_mount_offset , 0])
        large_mount();
}

module large_mount() {
    linear_extrude(large_mount_lower_height)
            circle(d=large_mount_lower_dia);
    linear_extrude(large_mount_lower_height + large_mount_upper_height)
            circle(d=large_mount_upper_dia);              
}

module pump_cutout() {
    linear_extrude(panel_thickness) {
                circle(d=motor_hole, $fn=246);
            }
            translate([-mount_distance/2,0,0])
                linear_extrude(panel_thickness) {
                    circle(d=3, $fn=246);
                }
            translate([mount_distance/2,0,0])
                linear_extrude(panel_thickness) {
                    circle(d=3, $fn=246);
                 } 


}

