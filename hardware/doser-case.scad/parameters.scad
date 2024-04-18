include <Round-Anything/polyround.scad>

$fn = 128;

side_thickness = 3.0;

base_surround_x = 7;
base_surround_y = 7;
base_thickness = 3.5;

lip_thickness = 3;
lip_height = 4;

pi_mount_x = 58;
pi_mount_y = 49;

pi_0_mount_x = pi_mount_x;
pi_0_mount_y = 23;

pi_board_x = 65;
pi_board_y = 56.5;

pi_0_board_x = 65;
pi_0_board_y = 30;
pi_0_sd_offset = 12.5;


pump_width = 56;
pump_depth = 40;

pump_distance = 49;
pump_hole = 30;

length = 3*pump_width + 2*base_surround_x;
width = pump_depth + 35;;


lip_outer_x = length - side_thickness;
lip_outer_y = width - side_thickness;

lip_inner_x = lip_outer_x - lip_thickness;
lip_inner_y = lip_outer_y - lip_thickness;

lid_height = 55.0;

connector_width = 10.5;

clip_bottom_width = 2;
clip_top_width = 0.75;
clip_length = 5;

notch_length = 10;
notch_height = 1.5;

lower_mount_offset = 50;
lower_mount_spacing = 50;

base_polygon = [
    
    [-length/2, width/2, 3],
    [length/2, width/2, 3],
    [length/2, -width/2, 3],
    [-length/2, -width/2, 3]   
];


lip_outer_polygon = [
    [-lip_outer_x/2, lip_outer_y/2, 3],
    [lip_outer_x/2, lip_outer_y/2, 3],
    [lip_outer_x/2, -lip_outer_y/2, 3],
    [-lip_outer_x/2, -lip_outer_y/2, 3]
];

lip_inner_polygon = [
    [-lip_inner_x/2, lip_inner_y/2, 3],
    [lip_inner_x/2, lip_inner_y/2, 3],
    [lip_inner_x/2, -lip_inner_y/2, 3],
    [-lip_inner_x/2, -lip_inner_y/2, 3]
];


module notches() {
    union() {
        translate([length/2,0,0])
            linear_extrude(notch_height)
                square([lip_thickness,notch_length], true);
        translate([-length/2,0,0])
            linear_extrude(notch_height)
                square([lip_thickness, notch_length], true);    
    }
}



module lip() {
    union() {
        linear_extrude(lip_height) {
            difference() {
                polygon(polyRound(lip_outer_polygon, 256));
                polygon(polyRound(lip_inner_polygon, 256));
            }
         }
    }
}


