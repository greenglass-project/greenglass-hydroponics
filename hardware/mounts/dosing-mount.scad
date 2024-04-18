include <Round-Anything/polyround.scad>


top_length = 50; //120;
top_width = 50;
top_thickness = 6;

cutout_length = 34;
cutout_width = 18;

clip_spacing = 5;
pipe_diameter = 5;

clip_length = pipe_diameter*3 + clip_spacing*4;
clip_width = pipe_diameter + 3;

clip_thickess = 5;


mount_polygon = [
    [-top_length/2, top_width/2,8],
    [top_length/2, top_width/2, 8],
    [top_length/2, -top_width/2, 0],
    [-top_length/2, -top_width/2, 0]
];

cutout_polygon = [
    [-cutout_length/2, cutout_width/2, 2],
    [cutout_length/2, cutout_width/2, 2],
    [cutout_length/2, -cutout_width/2, 2],
    [-cutout_length/2, -cutout_width/2, 2]
];

round_polygon = [
    [-clip_length/2, clip_width/2, 3],
    [clip_length/2, clip_width/2, 3],
    [clip_length/2, -clip_width/2, 3],
    [-clip_length/2, -clip_width/2, 3]
  ];

difference() {
    union() {
        base();
        translate([0, 20, top_thickness])
            round_clip();
    }
    translate([0, 20, 0])
        pipe_holes();
}

module base() {

    difference() {
        union() {
            linear_extrude(top_thickness)
                polygon(polyRound(mount_polygon, 256));
            
            translate([top_length/3, -top_width/2+10, top_thickness])
                linear_extrude(6)
                    square([6, 6], true);
               
      
         
            translate([-top_length/3,-top_width/2+10, top_thickness]) {
                linear_extrude(6) {
                    square([6, 6], true);
                }
            }

        }
        union() {
            translate([0,5, 0])

            linear_extrude(top_thickness)
                polygon(polyRound(cutout_polygon, 256));
                
            translate([0,-top_width/2+10, 0])
                linear_extrude(top_thickness)
                    circle(d=4, $fn=128);
        }
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

module pipe_holes() {
    linear_extrude(top_thickness)
        circle(d=pipe_diameter, $fn=128);
            
    translate([-pipe_diameter-clip_spacing,0,0])
        linear_extrude(top_thickness) 
            circle(d=pipe_diameter, $fn=128);
        
    
    translate([pipe_diameter+clip_spacing,0,0])
        linear_extrude(top_thickness)
            circle(d=pipe_diameter, $fn=128);
        
}

