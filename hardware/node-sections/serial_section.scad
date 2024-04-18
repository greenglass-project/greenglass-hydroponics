include <Round-Anything/polyround.scad>
include <common/parameters.scad>
include <common/section.scad>
include <common/connectors.scad>

section_height = 17.5;
hat_mount_height = 4;

conn_offset = 16;

difference() {
    union() {
        section(section_height);
        
        translate([0, -width/2 - conn_depth/2+top_thickness+ 0.5, 0])        
            linear_extrude(section_height)
                square([lip_inner_x, conn_depth], true); 

    }   
    union() {
        lip();
        translate([conn_offset, -width/2 - conn_depth/2+top_thickness+0.5, lip_height + outer_y/2])
            4pin_inner();
            
    }
        
}