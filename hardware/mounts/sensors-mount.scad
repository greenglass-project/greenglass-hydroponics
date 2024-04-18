include <Round-Anything/polyround.scad>


top_length = 50; //120;
top_width = 65;
top_thickness = 6;

centre_width = 6.4;
center_height = 5.5;
extrusion_side = 20.0;
side_thickness = 3;

difference() {
    union() {
        translate([0, -top_width/2 + extrusion_side/2 + side_thickness, 0])
            extrusion_bracket(top_length);        
        translate([0,-6,])
            back();
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

module round_clip() {
   difference() {
       linear_extrude(clip_thickess) {
           polygon(polyRound(round_polygon, 128));
       }
   
        union() {
            linear_extrude(clip_thickess) {
                circle(d=pipe_diameter, $fn=128);
            }
            translate([-pipe_diameter-clip_spacing,0,0]) {
                linear_extrude(clip_thickess) {
                    circle(d=pipe_diameter, $fn=128);
                }
            }
            translate([pipe_diameter+clip_spacing,0,0]) {
                linear_extrude(clip_thickess) {
                    circle(d=pipe_diameter, $fn=128);
                }
            }
        }
    }
}


module back() {

    linear_extrude(120)
        square([top_length, 5], true);
                    translate([0,0,-60])


    translate([20, 4.5, 168])
        rotate([0,0,0])
            clip();
    translate([20,4.5,90])
        rotate([0,0,0])
            clip();
     
    translate([20,4,5])
        cable_clip(5);
    translate([-top_length/2+30, 4, 5])
        cable_clip(5);
   translate([-top_length/2 +30, 7,103])
        holder(); 

    translate([-top_length/2+10,4,5])
        cable_clip(5);
    translate([-top_length/2 +10,7,103])
        holder();


      
      
}

module holder() {
    difference() {

    union() {
        linear_extrude(15)
            square([20,10], true);
        translate([0,6,0])
            linear_extrude(15)
                circle(d=20, $fn=128);       
     }     
     translate([0,6,0])
        linear_extrude(15)
            circle(d=13, $fn=128);
     }
}

module clip() {
    difference() {

        linear_extrude(10) {
            circle(d=6, $fn=128);
        }
        union() {
            linear_extrude(10) {
                circle(d=4, $fn=128);
            }
            translate([0,2,0]) {
                linear_extrude(10) {
                    square([2,4], true);
                }
            }
            
        }
    }
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

