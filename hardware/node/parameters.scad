$fn = 128;

base_mount_x = 40;
base_mount_y = 50;

base_surround_x = 8;
base_surround_y = 15;
base_thickness = 5;

panel_thickness = 2.5;

top_thickness = 4;
top_mount_offset = 4;
top_mount_height = 24;

lip_thickness = 3;
lip_height = 3;

pi_mount_x = 58;
pi_mount_y = 49;

pi_0_mount_x = pi_mount_x;
pi_0_mount_y = 23;

pi_board_x = 65;
pi_board_y = 56.5;

pi_0_board_x = 65;
pi_0_board_y = 30;

usb_width = 15;
usb_height = 9.0;
usb_centre_z = 11.5;
usb_centre = 31.45;
usb_offset = usb_centre - pi_board_y/2;
usb_cutout_height = 17;

length = pi_board_x + base_surround_x;
width = pi_board_y + base_surround_y;

lip_outer_x = length - top_thickness;
lip_outer_y = width - top_thickness;

lip_inner_x = lip_outer_x - lip_thickness;
lip_inner_y = lip_outer_y - lip_thickness;

lid_height = 55.0;

connector_width = 10.5;


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
