
$fn = 128;

pi5_length = 85;
pi5_width = 56;

pi5_mount_x = 58;
pi5_mount_y = 49;

fan_space = 20;
side_thickness = 3;
base_thickness = 4;
spacer = 1.0;

fan_side = 30;
fan_cutout = 28;
fan_mount = 24;
fan_mount_hole = 2.5;

length = pi5_length + fan_space + 2*side_thickness + 2*spacer;;
width = 2*fan_side + 2*side_thickness;
height = fan_side + base_thickness + 8;

pi_mount_center_x = (side_thickness + spacer + fan_space + 3.5 + pi5_mount_x/2) - length/2;

//pi_mount_offset = pi5_length - pi5_mount_x - 7 + side_thickness + spacer;



base_polygon = [
    [-length/2, width/2, 5],
    [length/2, width/2, 5],
    [length/2, -width/2, 5],
    [-length/2, -width/2, 5]
];

inner_polygon  = [
    [-length/2 + side_thickness + 5, width/2 -side_thickness, 0],
    [length/2 - side_thickness, width/2 - side_thickness, 5],
    [length/2 - side_thickness, -width/2 + side_thickness, 5],
    [-length/2 + side_thickness + 5, -width/2 + side_thickness, 0]
];

