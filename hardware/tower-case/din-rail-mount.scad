include <Round-Anything/polyround.scad>
include <parameters.scad>

mount_length = width - 12;
mount_width = 10;
din_width = 7.5;
din_curve = 30;

mount_polygon = [

    [-mount_length/2, mount_width/2, 3],
    [-din_width/2, mount_width/2, 10],
    [-din_width/2, din_curve/2, 0],
    [din_width/2, din_curve/2, 0],
    [din_width/2,  mount_width/2, 10],
    [mount_length/2, mount_width/2, 3],
    [mount_length/2, -mount_width/2, 3],
    [din_width/2, -mount_width/2, 10],
    [din_width/2, -din_curve/2, 0],
    [-din_width/2, -din_curve/2, 0],
    [-din_width/2, -mount_width/2, 10],
    [-mount_length/2, -mount_width/2, 3]
];


difference() {
    linear_extrude(3) 
            polygon(polyRound(mount_polygon, 256));
        
    union() {
        translate([base_mount/2,0,0])
            linear_extrude(base_thickness)
                circle(d=3);
        translate([-base_mount/2,0,0])
            linear_extrude(base_thickness)
                circle(d=3);
    } 
}
translate([-3.75,0,14.75])
    rotate([180,0,0])
import("../dins_clip.stl");
