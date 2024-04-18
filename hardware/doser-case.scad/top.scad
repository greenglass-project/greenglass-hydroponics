include <Round-Anything/polyround.scad>
include <parameters.scad>

top_thickness = 4.0;
section_height = 3;

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
        translate([0,0,section_height])
            lip();
        translate([0,0,section_height + lip_height - notch_height])
            notches();
    }
}