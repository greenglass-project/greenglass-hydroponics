include <Round-Anything/polyround.scad>
include <../parameters.scad>



difference() {

    union() {
        linear_extrude(base_thickness)
            polygon(polyRound(base_polygon, 256));
        translate([0,0,base_thickness])
            pi_mount();
        translate([0,0,base_thickness])
            lip();
        translate([0,0,base_thickness])
            top_mounts()  ;   
    }
    union () {
        top_mount_holes();
        translate([-base_mount_x/2, base_mount_y/2,0])
            linear_extrude(base_thickness)
                circle(d=3);
        translate([base_mount_x/2,base_mount_y/2,0])
            linear_extrude(base_thickness)
                circle(d=3);
        translate([base_mount_x/2, -base_mount_y/2,0])
            linear_extrude(base_thickness)
                circle(d=3);
        translate([-base_mount_x/2,-base_mount_y/2,0])
            linear_extrude(base_thickness)
                circle(d=3);
    }
}



module pi_mount() {

    mount(-pi_mount_x/2, pi_mount_y/2, 6, 6, 3);
    mount(pi_mount_x/2, pi_mount_y/2, 6, 6, 3);
    mount(-pi_mount_x/2, pi_mount_y/2 - pi_0_mount_y, 6, 6, 3);
    mount(pi_mount_x/2, pi_mount_y/2 - pi_0_mount_y, 6, 6, 3);
    mount(pi_mount_x/2, -pi_mount_y/2, 6, 7.3, 3);
    mount(-pi_mount_x/2, -pi_mount_y/2, 5, 7.3, 3);

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
