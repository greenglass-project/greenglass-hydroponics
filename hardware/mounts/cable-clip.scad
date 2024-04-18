
thickness = 4;

mount();

module clip() {

translate([-2.5,0,0])
    cable_clip(thickness);
translate([-7.5,0,0])
    cable_clip(thickness);
translate([2.5,0,0])
    cable_clip(thickness);
translate([7.5,0,0])
    cable_clip(thickness);
    translate([0,-2.5,0])
        linear_extrude(thickness)
            square([18,1.5],true);
}

module mount() {

translate([-2.5,0,1])
    cable_clip(thickness);
translate([-7.5,0,1])
    cable_clip(thickness);
translate([2.5,0,1])
    cable_clip(thickness);
translate([7.5,0,1])
    cable_clip(thickness);
    translate([0,-4.5,0])
        linear_extrude(6)
            square([18,6],true);
}
    
module cable_clip(thickness) {
    difference() {
        linear_extrude(thickness) {
            circle(d=4.5, $fn=128);
        }
        union() {
            linear_extrude(thickness) {
                circle(d=2.6, $fn=128);
            }
            translate([0,2,0]) {
                linear_extrude(thickness) {
                    square([2,4], true);
                }
            }
            
        }
    }
}