include <front-panel.scad>

socket_mount_x = 48.5;
socket_mount_y = 18.0;

mount_outer_dia = 5;
mount_outer_length = 1;
mount_inner_dia = 3;
mount_inner_length = 3;

slot_width = 8;
slot_length = 54;

slot_x = -lip_inner_x/2 + (lip_inner_x - slot_length)/2;
slot_y = 7.5-slot_width/2;




$fn=256;

difference() {
    union() {
        base_panel();
        
        translate([socket_mount_x/2, slot_y + socket_mount_y/2 + slot_width/2-1.25, panel_thickness]) {
            union() {
                linear_extrude(mount_outer_length)
                    circle(d=mount_outer_dia);
                linear_extrude(mount_outer_length + mount_inner_length )
                    circle(d=mount_inner_dia);
            }

        }
        translate([-socket_mount_x/2, slot_y + socket_mount_y/2 + slot_width/2-1.25, panel_thickness]) {
            union() {
                linear_extrude(mount_outer_length)
                    circle(d=mount_outer_dia);
                linear_extrude(mount_outer_length + mount_inner_length )
                    circle(d=mount_inner_dia);
            }
         }

        translate([socket_mount_x/2, slot_y - socket_mount_y/2 + slot_width/2-1.25, panel_thickness]) {
         union()  {
                linear_extrude(mount_outer_length)
                    circle(d=mount_outer_dia);
                linear_extrude(mount_outer_length + mount_inner_length )
                    circle(d=mount_inner_dia);
            }
        }
        
        translate([-socket_mount_x/2, slot_y - socket_mount_y/2  + slot_width/2-1.25, panel_thickness]) {
            union() {
                linear_extrude(mount_outer_length)
                    circle(d=mount_outer_dia);
                linear_extrude(mount_outer_length + mount_inner_length )
                    circle(d=mount_inner_dia);
            }
         }
         
    }
    union() {
    //translate([0, 7.5, 0]) {
        translate([slot_x, slot_y, 0]) {
            linear_extrude(panel_thickness)
                square([connector_width, slot_width], false);
        }
        translate([slot_x + connector_width + 12, slot_y, 0]) {
            linear_extrude(panel_thickness)
                square([3*connector_width, slot_width], false);
        }
    }
        
}

