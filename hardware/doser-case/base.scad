include <Round-Anything/polyround.scad>
include <parameters.scad>



base();

module base() {
    
    union() {
        difference() {

            union() {
                linear_extrude(base_thickness)
                    polygon(polyRound(base_polygon, 256));
                translate([0,0,base_thickness])
                    lip();
                translate([0,0,base_thickness])
                    top_mounts();
                translate([0,0,base_thickness])
                    main_mounts();
            }
            union () {
                top_mount_holes();
                translate([base_mount/2,base_mount/2,0])
                    linear_extrude(base_thickness)
                        circle(d=3);
                translate([-base_mount/2,base_mount/2,0])
                    linear_extrude(base_thickness)
                        circle(d=3);
                translate([base_mount/2,-base_mount/2,0])
                    linear_extrude(base_thickness)
                        circle(d=3);
                translate([-base_mount/2,-base_mount/2,0])
                    linear_extrude(base_thickness)
                        circle(d=3); 
                translate([-60,-16,indent_thickness])
                    linear_extrude(base_thickness-indent_thickness)
                    square([60,25], true);
                    
                 translate([-60,-16,0])
                   linear_extrude(indent_thickness)
                        square([3*connector_width, slot_width], true);
             }
        }
        
        translate([-60+socket_mount/2, -16, indent_thickness]) {
           union() {
                linear_extrude(mount_outer_length)
                    circle(d=mount_outer_dia);
                linear_extrude(mount_outer_length + mount_inner_length )
                        circle(d=mount_inner_dia);
            }
        }
        translate([-60-socket_mount/2, -16, indent_thickness]) {
            union() {
                linear_extrude(mount_outer_length)
                    circle(d=mount_outer_dia);
                linear_extrude(mount_outer_length + mount_inner_length )
                        circle(d=mount_inner_dia);
            }
        }       
    }
}

module mount(x,y ,dia, height, hole) {
    translate([x,y,0]) {
        linear_extrude(height) {
            difference() {
                circle(d=dia);
                circle(d=hole);
            }
        }
    }
}


module top_mounts() {
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
        linear_extrude(lip_height + base_thickness)
            circle(d=3);
    translate([length/2 - top_mount_offset, width/2 - top_mount_offset, 0])
        linear_extrude(lip_height + base_thickness)
            circle(d=3);
    translate([length/2 - top_mount_offset, -width/2 + top_mount_offset, 0])
        linear_extrude(lip_height + base_thickness)
            circle(d=3);
    translate([-length/2 + top_mount_offset, -width/2 + top_mount_offset, 0])
        linear_extrude(lip_height + base_thickness)
            circle(d=3);
}


module lip() {
    linear_extrude(lip_height) {
        difference() {
            polygon(polyRound(lip_outer_polygon, 256));
            polygon(polyRound(lip_inner_polygon, 256));
        }
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
    difference() {
        linear_extrude(mount_height)
            circle(d=large_mount_lower_dia);
        translate([0,0,mount_height-large_mount_upper_height]) {
            linear_extrude(large_mount_upper_height)
                circle(d=large_mount_upper_dia);
         }
    }            
}


module connectors_test() {

    thickness = 2.5;
    difference() {
        union() {
            linear_extrude(thickness)
                square([60,30], true);
            translate([socket_mount/2, 0, panel_thickness]) {
                union() {
                    linear_extrude(mount_outer_length)
                        circle(d=mount_outer_dia);
                    linear_extrude(mount_outer_length + mount_inner_length )
                        circle(d=mount_inner_dia);
                }
            }
            translate([-socket_mount/2, 0, panel_thickness]) {
                union() {
                    linear_extrude(mount_outer_length)
                        circle(d=mount_outer_dia);
                    linear_extrude(mount_outer_length + mount_inner_length )
                        circle(d=mount_inner_dia);
                }
            }
        }
        linear_extrude(thickness)
            square([3*connector_width, slot_width], true);
    }
}
