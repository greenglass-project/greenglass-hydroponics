include <Round-Anything/polyround.scad>
include <parameters.scad>



base();

module base() {
    
    difference() {

        union() {
            linear_extrude(base_thickness)
                polygon(polyRound(base_polygon, 256));
            translate([0,0,base_thickness])
                lip();
            translate([0,0,base_thickness])
                top_mounts();
                
             translate([0,0,base_thickness])
                mount(-board_mount_x/2, board_mount_y/2, 4, 4, 1.5);

             translate([0,0,base_thickness])
                mount(board_mount_x/2, board_mount_y/2, 4, 4, 1.5);
                
             translate([0,0,base_thickness])
                mount(board_mount_x/2, -board_mount_y/2, 4, 4, 1.5);
            
             translate([0,0,base_thickness])
                mount(-board_mount_x/2, -board_mount_y/2, 4, 4, 1.5);
                
        }
        union () {
            top_mount_holes();

            translate([-base_mount/2, 0,0])
                linear_extrude(base_thickness)
                    circle(d=3);
            translate([base_mount/2,0,0])
                linear_extrude(base_thickness)
                    circle(d=3);

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
