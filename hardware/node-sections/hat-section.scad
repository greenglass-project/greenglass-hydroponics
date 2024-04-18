include <Round-Anything/polyround.scad>
include <common/parameters.scad>
include <common/section.scad>

section_height = 16.5;
hat_mount_height = 4;

union() {
    section(section_height);
    //translate([0,0,lip_thickness +hat_mount_offset ])
    //    mount_plate();
    hat_mount(hat_mount_height);

}