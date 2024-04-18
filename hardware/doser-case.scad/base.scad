include <Round-Anything/polyround.scad>
include <parameters.scad>

section_height = 42;

inner_y = 7.8;
conn_padding = 2;

conn_depth = 12;

8pin_inner_x = 10.7 * 4;
8pin_outer_x = 8pin_inner_x + 4*conn_padding;
outer_y = inner_y + 2*conn_padding;

socket_offset_x = 50;
socket_offset_z = 10;


module 8pin_outer() {
    cube(8pin_outer_x,section_height, conn_depth);
}

module 8pin_inner() {
    cube(8pin_inner_x, inner_y, conn_depth); 
}


//lip();

base();

module base() {
    union() {
        difference() {

            union() {
                difference() {
                    linear_extrude(section_height)
                        polygon(polyRound(base_polygon, 256));
                    translate([0,0,base_thickness])
                    linear_extrude(section_height + base_thickness)
                        polygon(polyRound(lip_inner_polygon, 256));            
                }
                translate([0, 0, section_height])
                    lip();
                   
                translate([socket_offset_x, -width/2, section_height/2])
                    8pin_outer();
                
            }
            union() {
                translate([0, width/2, section_height/2])
                    rotate([90,180,0])
                        pump_cutout();
                translate([pump_width, width/2, section_height/2])
                    rotate([90,180,0])
                        pump_cutout();
                translate([-pump_width, width/2, section_height/2])
                    rotate([90,180,0])
                        pump_cutout();
  
                translate([socket_offset_x, -width/2, socket_offset_z])
                    8pin_inner();
                
                translate([lower_mount_spacing, 0, 0])
                    lower_mount();
                
                translate([-lower_mount_spacing, 0, 0])
                    lower_mount();
                    
                translate([-length/2, 0, section_height/2])
                    side_mount();                   
                
                translate([length/2-side_thickness, 0, section_height/2])
                    side_mount();
 
            }
        }

    }
}

module mount(x,y, dia, height, hole) {
    translate([x,y,0]) {
        linear_extrude(height) {
            difference() {
                circle(d=dia);
                circle(d=hole);
            }
        }
    }
}

module pump_cutout() {
    //translate([0,0,90])
    linear_extrude(side_thickness) {
                circle(d=pump_hole, $fn=246);
            }
            translate([-pump_distance/2,0,0])
                linear_extrude(side_thickness) {
                    circle(d=3, $fn=246);
                }
            translate([pump_distance/2,0,0])
                linear_extrude(side_thickness) {
                    circle(d=3, $fn=246);
                 } 


}

module lower_mount() {
    translate([-lower_mount_offset/2, lower_mount_offset/2, 0])
        linear_extrude(base_thickness)
            circle(d=3);
     translate([lower_mount_offset/2, lower_mount_offset/2, 0])
        linear_extrude(base_thickness)
            circle(d=3);           
    translate([lower_mount_offset/2, -lower_mount_offset/2, 0])
        linear_extrude(base_thickness)
            circle(d=3);            
    translate([-lower_mount_offset/2, -lower_mount_offset/2, 0])
        linear_extrude(base_thickness)
            circle(d=3);
}

module pi_mount() {

    union() {
        translate([-pi_mount_x/2, -width/2 + side_thickness, base_thickness + pi_mount_y/2 + 10])
            rotate([90,0,0])
                linear_extrude(side_thickness)
                    circle(d=3);
        translate([pi_mount_x/2, -width/2 + side_thickness, base_thickness + pi_mount_y/2 + 10])
            rotate([90,0,0])
                linear_extrude(side_thickness)
                    circle(d=3);  
    }
}


module side_mount() {

    translate([0, lower_mount_offset/2, 0])
        rotate([0,90,0])
            linear_extrude(side_thickness)
                circle(d=3);
     translate([0, -lower_mount_offset/2, 0])
        rotate([0,90,0])
            linear_extrude(side_thickness)
                circle(d=3);    
}

module cube(x,y,d) {
 translate([0,d/2])
    rotate([90,0,0])
    linear_extrude(d)
        square([x,y], true);
}

