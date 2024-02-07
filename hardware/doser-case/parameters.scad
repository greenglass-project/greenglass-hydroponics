$fn = 128;

base_mount = 50;
base_surround_x = 8;
base_surround_y = 15;
base_thickness = 5;

panel_thickness = 2.5;

top_thickness = 4;
top_mount_offset = 4;

lip_thickness = 3;
lip_height = 3;


socket_mount = 40.0;
mount_outer_dia = 6;
mount_outer_length = 1;
mount_inner_dia = 3;
mount_inner_length = 3;
mount_height = 50;

slot_width = 8;
slot_length = 54;

indent_thickness = 2.5;

pi_mount_x = 58;
pi_mount_y = 49;

pi_board_x = 65;
pi_board_y = 56.5;

pump_width = 60;

length = base_surround_y + 3*pump_width;
width = pi_board_x + base_surround_x;

lip_outer_x = length - top_thickness;
lip_outer_y = width - top_thickness;

lip_inner_x = lip_outer_x - lip_thickness;
lip_inner_y = lip_outer_y - lip_thickness;



connector_width = 10.5;

large_mount_lower_dia = 8;
large_mount_lower_height = 5;
large_mount_upper_dia = 5;
large_mount_upper_height = 5;

large_mount_offset = 10;

lid_height = base_mount + large_mount_lower_height + panel_thickness;


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
