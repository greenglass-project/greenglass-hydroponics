include <Round-Anything/polyround.scad>
//include <./parameters.scad>

pipe_diameter = 5;
clip_spacing = 1.5;
probe_length = 140;
probe_thickness = 3;

clip_length = 30;
clip_width = pipe_diameter + clip_spacing*2;

centre_width = 6.4;
center_height = 5.5;
extrusion_side = 20.0;
side_thickness = 3;


flat_polygon = [
    [-clip_length/2, clip_width/2, 3],
    [clip_length/2, clip_width/2, 3],
    [clip_length/2, -clip_width/2, 0],
    [-clip_length/2, -clip_width/2, 0]
  
];

round_polygon = [
    [-clip_length/2, clip_width/2, 3],
    [clip_length/2, clip_width/2, 3],
    [clip_length/2, -clip_width/2, 3],
    [-clip_length/2, -clip_width/2, 3]
  ];

cutout_polygon = [
    [-clip_length/2, clip_width/2+probe_thickness, 3],
    [clip_length/2, clip_width/2+probe_thickness, 3],
    [clip_length/2, -clip_width/2-+probe_thickness, 0],
    [-clip_length/2, -clip_width/2-+probe_thickness, 0]
  
];


extrusion_bracket(30);
translate([0, -extrusion_side/2-3,0])
    rotate([0,270,90])
        flat_clip(4);
 translate([0, -extrusion_side/2-3,extrusion_side-1])
    rotate([0,270,90])
        flat_clip(4);   

module top() {
    difference() {
        union() {
            linear_extrude(top_thickness) {
                square([top_length, mount_total_width], true);
            }
            translate([top_length/2-3,-mount_total_width/2 + 10 , top_thickness]) {
                linear_extrude(6) {
                    square([6, 6], true);
                }
            }
            translate([-top_length/2+3,-mount_total_width/2 + 10 , top_thickness]) {
                linear_extrude(6) {
                    square([6, 6], true);
                }
            }
        }
        union() {
            translate([0,mount_total_width/2-20,0]) {
                linear_extrude(top_thickness) {
                    polygon(polyRound(cutout_polygon, 128));
                }
            }
            translate([0,-mount_total_width/2 + 10 , 0]) {
                linear_extrude(top_thickness) {
                    circle(d=3.5, $fn=128);
                }
            }
        }
    }
}

module flat_clip(thickness) {
    translate([0,0,clip_width/2]) {
        rotate([90,0,90]) {
            difference() {
               linear_extrude(thickness) {
                   polygon(polyRound(flat_polygon, 128));
               }
           
                union() {
                    linear_extrude(thickness) {
                        circle(d=pipe_diameter, $fn=128);
                    }
                    translate([-pipe_diameter-clip_spacing,0,0]) {
                        linear_extrude(thickness) {
                            circle(d=pipe_diameter, $fn=128);
                        }
                    }
                    translate([pipe_diameter+clip_spacing,0,0]) {
                        linear_extrude(thickness) {
                            circle(d=pipe_diameter, $fn=128);
                        }
                    }
                }
            }
        }
    }
}

module round_clip(thickness) {
   difference() {
        union() {
            linear_extrude(thickness)
                polygon(polyRound(round_polygon, 128));
            translate([0,5.5,0]) 
                cable_clip(thickness);
            translate([-5,5.5,0]) 
                cable_clip(thickness);
            
             translate([5,5.5,0]) 
                cable_clip(thickness);
        }
     
        union() {
            linear_extrude(thickness) {
                circle(d=pipe_diameter, $fn=128);
            }
            translate([-pipe_diameter-clip_spacing,0,0]) {
                linear_extrude(thickness) {
                    circle(d=pipe_diameter, $fn=128);
                }
            }
            translate([pipe_diameter+clip_spacing,0,0]) {
                linear_extrude(thickness) {
                    circle(d=pipe_diameter, $fn=128);
                }
            }
        }
    }
}


module probe() {
    linear_extrude(top_thickness) {
        square([probe_length, clip_length], true);
    }
}



module guide(thickness) {
    difference() {
        clip(thickness);
        union() {
            linear_extrude(thickness) {
                circle(d=pipe_diameter, $fn=128);
            }
            translate([-pipe_diameter-clip_spacing,0,0]) {
                linear_extrude(thickness) {
                    circle(d=pipe_diameter, $fn=128);
                }
            }
            translate([pipe_diameter+clip_spacing,0,0]) {
                linear_extrude(thickness) {
                    circle(d=pipe_diameter, $fn=128);
                }
            }
        }
    }
}


module clip(thickness) {
    union() {
        linear_extrude(thickness) {
            square([2*(pipe_diameter+clip_spacing), pipe_diameter + 2*clip_spacing], true);
        }
        translate([pipe_diameter+clip_spacing, 0, 0]) {
            linear_extrude(thickness) {
                circle(d=pipe_diameter + 2*clip_spacing, $fn=129);
            }        
        }
        translate([-pipe_diameter-clip_spacing, 0, 0]) {
            linear_extrude(thickness) {
                circle(d=pipe_diameter + 2*clip_spacing, $fn=129);
            }        
        }
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
        


