include <front-panel.scad>

socket_mount = 22.75;
mount_outer_dia = 6;
mount_outer_length = 1;
mount_inner_dia = 3;
mount_inner_length = 3;

socket_mount_x = 26;


slot_width = 8;
slot_length = 54;

slot_x = -lip_inner_x/2 + (lip_inner_x - slot_length)/2;
slot_y = 7.5-slot_width/2;


$fn=256;

difference() {
    union() {
        base_panel();
        translate([socket_mount_x/2, 0, panel_thickness])
            board_mount();
        translate([-socket_mount_x/2, 0, panel_thickness])
            board_mount();
}
   
    linear_extrude(panel_thickness)
        square([connector_width, slot_width], true);       
}

module board_mount() {
    union() {
        linear_extrude(mount_outer_length)
            circle(d=mount_outer_dia);
        linear_extrude(mount_outer_length + mount_inner_length )
            circle(d=mount_inner_dia);
    }
}
