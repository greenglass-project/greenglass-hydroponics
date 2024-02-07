include <Round-Anything/polyround.scad>
include <parameters.scad>


mount_overall_length = length + 30;
mount_centre_size = base_mount + 16;
mount_width = 20;

top_y = mount_width;
bottom_y = 0;

mount_thickness = 6;

cutout_side = 45;

mount_polygon = [

    [-mount_overall_length/2, top_y, 8],
    [-mount_centre_size/2, top_y, 15],
    [-mount_centre_size/2, mount_centre_size/2, 8],
    [mount_centre_size/2, mount_centre_size/2, 8],
    [mount_centre_size/2, top_y, 15],
    [mount_overall_length/2, top_y, 8],
    [mount_overall_length/2, bottom_y, 8],
    [mount_centre_size/2, bottom_y, 15],
    [mount_centre_size/2, -mount_centre_size/2, 8],
    [-mount_centre_size/2, -mount_centre_size/2, 8],
    [-mount_centre_size/2, bottom_y, 15],
    [-mount_overall_length/2, bottom_y, 8]
];

cutout_polygon = [
    [-cutout_side/2, cutout_side/2, 8],
    [cutout_side/2, cutout_side/2, 8],
    [cutout_side/2, -cutout_side/2, 8],
    [-cutout_side/2, -cutout_side/2, 8]
];


difference() {
    union() {
        linear_extrude(mount_thickness)
            polygon(polyRound(mount_polygon, 256));
            
        translate([-50,mount_width/2,mount_thickness])
            linear_extrude(6)
                square([6,6], true);
        translate([-90,mount_width/2,mount_thickness])
            linear_extrude(6)
                square([6,6], true);       
 
        translate([50,mount_width/2,mount_thickness])
            linear_extrude(6)
                square([6,6], true);
        translate([90,mount_width/2,mount_thickness])
            linear_extrude(6)
                square([6,6], true);       
 
    }
    union() {
        translate([base_mount/2,base_mount/2,0])
            linear_extrude(mount_thickness)
                circle(d=4);
        translate([-base_mount/2,base_mount/2,0])
            linear_extrude(mount_thickness)
                circle(d=4);
        translate([base_mount/2,-base_mount/2,0])
            linear_extrude(mount_thickness)
                circle(d=4);
        translate([-base_mount/2,-base_mount/2,0])
            linear_extrude(mount_thickness)
                circle(d=4);
    
        translate([-mount_overall_length/2+7.5,mount_width/2,0])
            linear_extrude(mount_thickness)
                circle(d=4);
        translate([mount_overall_length/2-7.5, mount_width/2,0])
            linear_extrude(mount_thickness)
                circle(d=4);
                
        linear_extrude(mount_thickness)
            polygon(polyRound(cutout_polygon, 256));

    }
}

