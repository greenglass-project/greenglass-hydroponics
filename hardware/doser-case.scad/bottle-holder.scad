include <Round-Anything/polyround.scad>

bottle_height = 165;
bottle_dia = 72;
outer_dia = bottle_dia + 6;

pump_distance = 49;
spacing = 6;

thickness = 20;
hole_depth = 17;

centre_width = 6.4;
center_height = 5.5;
extrusion_side = 20.0;
side_thickness = 3;

base();

module base() {
    difference() {
        union() {
            linear_extrude(thickness + side_thickness)
                circle(d=outer_dia, $fn=128);
   
            translate([0,outer_dia/2-3,0])
                linear_extrude(thickness + side_thickness)
                    square([bottle_dia/2,5 ], true);
                    
            translate([0,outer_dia/2 + extrusion_side/2, thickness + side_thickness])
                rotate([180,0,0])
                    extrusion_bracket(bottle_dia/2);
        }
        translate([0,0, side_thickness])
            linear_extrude(thickness)
                circle(d=bottle_dia, $fn=128);               
    }
}


module extrusion_bracket(length) {

    union() {
        difference() {
            linear_extrude(extrusion_side+side_thickness)
                square([length, extrusion_side + 2*side_thickness], true);
            translate([0,0,side_thickness])
                linear_extrude(extrusion_side)
                    square([length, extrusion_side], true);   
        
        }
        translate([0,0,side_thickness])
            linear_extrude(center_height)
                square([length, centre_width], true);         
    }
}


