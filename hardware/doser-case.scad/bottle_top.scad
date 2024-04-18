

side = 1.6;
top_hole = 14.5;
inner_hole = top_hole -  2*side;
pipe_hole = inner_hole - 2*side;

base = 22;
thickness = 10;


top();

translate([30,0,0])
    bottom();

module top() {
    difference() {
        union() {
            linear_extrude(side)
                circle(d=base, $fn=128);
            translate([0,0,side])
                linear_extrude(thickness)
                    circle(d=top_hole, $fn=128);
         }
     
        linear_extrude(thickness + side)
            circle(d=inner_hole, $fn=128);
    }
}

module bottom() {
    difference() {
        union() {
            linear_extrude(side)
                circle(d=base, $fn=128);
            linear_extrude(side + 1)
                circle(d=top_hole, $fn=128);
            translate([0,0,side])
                linear_extrude(thickness + side + 1)
                    circle(d=inner_hole, $fn=128);
         }
     
        linear_extrude(thickness + 2 * side +1)
            circle(d=pipe_hole, $fn=128);
    }



}

