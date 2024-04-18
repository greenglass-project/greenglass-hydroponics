include <Round-Anything/polyround.scad>
include <common/parameters.scad>
include <common/section.scad>

section_height = 21.5;
hat_mount_height = 4;

connector_dia = 8.0;
connector_offset = 18.5;

connector_centre =  connector_dia/2 + lower_offset + lip_height-1.75;

difference() {
    union() {
        section(section_height);
        hat_mount(hat_mount_height);
        
    }
    translate([0, -width/2 + top_thickness + 1, connector_centre ])
        connector_hole() ;
    translate([-connector_offset, -width/2 + top_thickness + 1, connector_centre ])
        connector_hole() ;
    translate([connector_offset, -width/2 + top_thickness + 1, connector_centre ])
        connector_hole() ;
}

module connector_hole() {
    rotate([90,0,0])
    linear_extrude(top_thickness +1)
        circle(d=connector_dia, $fn=128);

 }