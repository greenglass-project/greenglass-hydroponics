include <parameters.scad>

bracket_thickness = 3;

bracket_width = 65;
bracket_length = 30;
flange_width = 26;

bracket();
translate([0,0,bracket_thickness + flange_width/2])
    rotate([90,0,0])
        flange();


module bracket() {
    difference() {
        linear_extrude(bracket_thickness)
            square([bracket_length, bracket_width], true);
       
        union() {
            translate([0, lower_mount_offset/2, 0])
                linear_extrude(bracket_thickness)
                    circle(d=3);
            translate([0, -lower_mount_offset/2, 0])
                linear_extrude(bracket_thickness)
                    circle(d=3);
        }
    }
}

module flange() {
    linear_extrude(bracket_thickness) 
        square([bracket_length, flange_width], true);

}