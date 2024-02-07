$fn = 128;

board_width = 30;
board_length = 70;

board_mount_x = 65;
board_mount_y = 25;

length = board_length + 14;
width = board_width + 12;

base_mount = 50;
base_thickness = 4;

panel_thickness = 2.5;

top_thickness = 4;
top_mount_offset = 4;

lip_thickness = 3;
lip_height = 3;

lip_outer_x = length - top_thickness;
lip_outer_y = width - top_thickness;

lip_inner_x = lip_outer_x - lip_thickness;
lip_inner_y = lip_outer_y - lip_thickness;

lid_height = 11;
hole_depth = lid_height - 5;

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
