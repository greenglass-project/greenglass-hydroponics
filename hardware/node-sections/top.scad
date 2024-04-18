include <Round-Anything/polyround.scad>
include <common/parameters.scad>

section_height = 4;

top();

module top() {        
    difference() {
        difference() {
            linear_extrude(section_height + lip_height)
                polygon(polyRound(base_polygon, 256));
            translate([0,0,top_thickness])
                linear_extrude(section_height + lip_height - top_thickness)
                    polygon(polyRound(lip_inner_polygon, 256));            
                
        }
        union() {
            translate([0,0,section_height])
                lip();
            translate([0,0,section_height + lip_height - notch_height])
                notches();
            translate([-base_mount_x/2, base_mount_y/2,0])
                linear_extrude(base_thickness)
                    circle(d=3);
            translate([base_mount_x/2,base_mount_y/2,0])
                linear_extrude(base_thickness)
                     circle(d=3);
            translate([base_mount_x/2, -base_mount_y/2,0])
                linear_extrude(base_thickness)
                    circle(d=3);
            translate([-base_mount_x/2,-base_mount_y/2,0])
                linear_extrude(base_thickness)
                    circle(d=3);
        }
    /*difference() {
        
        
            linear_extrude(section_height + top_thickness)
                polygon(polyRound(base_polygon, 256));
            union() {
                translate([0,0,lip_height])
                    linear_extrude(section_height-top_thickness)
                        polygon(polyRound(lip_inner_polygon, 256));
                translate([0,0,lip_height])
                    notches();
            }
        }*/
        
    }
}