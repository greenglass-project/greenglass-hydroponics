include <Round-Anything/polyround.scad>


$fn = 128;

side_thickness = 3.0;

base_surround_x = 7;
base_surround_y = 7;
base_thickness = 2;

lip_thickness = 3;
lip_height = 4;

clip_bottom_width = 2;
clip_top_width = 0.75;
clip_length = 5;
notch_length = 10;
notch_height = 1.5;

conn_padding = 2;
conn_depth = 12;
inner_y = 7.8;
outer_y = inner_y + 2*conn_padding;

2pin_inner_x = 10.7;
4pin_inner_x = 2*2pin_inner_x;
2pin_outer_x = 2pin_inner_x + 2*conn_padding;
4pin_outer_x = 2*2pin_inner_x + 2*conn_padding;

spacing = 5;

length = 4 * 4pin_outer_x + 2 * spacing;
width = 2.5 * conn_depth;

mount_spacing = length -24;
mount_extension = 15;
mount_width = 20;

lip_outer_x = length - side_thickness;
lip_outer_y = width - side_thickness;

lip_inner_x = lip_outer_x - lip_thickness;
lip_inner_y = lip_outer_y - lip_thickness;

lid_thickness = 2;

section_height = outer_y;

offset1 = 4pin_outer_x/2;
offset2 = offset1 + 4pin_outer_x;

mount_y = width/2 + conn_depth/2 - side_thickness;

centre_width = 6.4;
center_height = 5.5;
extrusion_side = 20.5;


base_polygon = [
    [-length/2, width/2, 3],
    [length/2, width/2, 3],
    [length/2, -width/2, 3],
    [-length/2, -width/2, 3]   
];

mount_polygon = [
    
    [-length/2 - mount_extension, mount_width/2, 3],
    [length/2 + mount_extension, mount_width/2, 3],
    [length/2 + mount_extension, -mount_width/2, 3],
    [-length/2 - mount_extension, -mount_width/2, 3] 
];


lip_outer_polygon = [
    [-lip_outer_x/2, lip_outer_y/2, 3],
    [lip_outer_x/2, lip_outer_y/2, 3],
    [lip_outer_x/2, -lip_outer_y/2, 3],
    [-lip_outer_x/2, -lip_outer_y/2, 3]
];

lip_inner_polygon = [
    [-lip_inner_x/2, lip_inner_y/2, 3],
    [lip_inner_x/2, lip_inner_y/2, 3],
    [lip_inner_x/2, -lip_inner_y/2, 3],
    [-lip_inner_x/2, -lip_inner_y/2, 3]
];

spigot_offset = 45;


//translate([0,-55,0])
    //base();
//lid();
//translate([0,55,0])
mount();

module base() {
   
   difference() {
       union() {
           difference() {
                linear_extrude(section_height)
                    polygon(polyRound(base_polygon, 256));
                translate([0,0,base_thickness])
                    linear_extrude(section_height + base_thickness)
                        polygon(polyRound(lip_inner_polygon, 256));            
            }
            
            translate([0,0,section_height])
                lip();
            
            translate([offset1, mount_y, outer_y/2])
                cube(4pin_outer_x, outer_y, conn_depth);

            translate([offset2, mount_y, outer_y/2])
                cube(4pin_outer_x, outer_y, conn_depth);
            
            translate([-offset1, mount_y, outer_y/2])
                cube(4pin_outer_x, outer_y, conn_depth);
                
            translate([-offset2 -4, mount_y, outer_y/2])
                cube(2pin_outer_x, outer_y, conn_depth);
        }
        union() {
       
            translate([offset1, mount_y, outer_y/2])
                cube(4pin_inner_x, inner_y, conn_depth);

            translate([offset2, mount_y, outer_y/2])
                cube(4pin_inner_x, inner_y, conn_depth);
        
            translate([-offset1, mount_y, outer_y/2])
                cube(4pin_inner_x, inner_y, conn_depth);
            
            translate([-offset2 -4, mount_y, outer_y/2])
                cube(2pin_inner_x, inner_y, conn_depth);
                
            translate([mount_spacing/2, 0, 0])
                linear_extrude(base_thickness)
                    circle(d=3, $fn=126);
                    
            translate([-mount_spacing/2, 0, 0])
                linear_extrude(base_thickness)
                    circle(d=3, $fn=126);
        }
    }
}


module lid() {
    difference() {
        linear_extrude(lid_thickness + lip_height)
            polygon(polyRound(base_polygon, 256));
        union() {
            translate([0,0,lid_thickness])
                linear_extrude(lip_height)
                    polygon(polyRound(lip_outer_polygon, 256));
            translate([0,0,lid_thickness + lip_height - notch_height])
                notches();
        }
    }
}

module mount() {
    mount_thickness = 3;
    difference() {
        union() {
            linear_extrude(mount_thickness)
                polygon(polyRound(mount_polygon , 256));
            
            translate([spigot_offset/2, 0, mount_thickness])
                linear_extrude(6)
                    square([6, 6], true);
            
            translate([-spigot_offset/2, 0, mount_thickness])
                linear_extrude(6)
                    square([6, 6], true);
                
            
        }
        union() {
           translate([mount_spacing/2, 0, 0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=126);
                    
            translate([-mount_spacing/2, 0, 0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=126);
                    
            translate([-length/2 - mount_extension/2, 0, 0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=126);
                    
            translate([length/2 + mount_extension/2, 0, 0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=126);                   
        }
    }
    //translate([0, -width/2, mount_thickness + extrusion_side/2 + side_thickness ])
    //    rotate([270,0,0])
    //extrusion_bracket(length-40);
}

module extrusion_bracket(length) {
    union() {
        difference() {
            linear_extrude(extrusion_side + side_thickness)
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

module notches() {
    union() {
        translate([lip_outer_x/2,0,0])
            linear_extrude(notch_height)
                square([side_thickness,notch_length], true);
        translate([-lip_outer_x/2,0,0])
            linear_extrude(notch_height)
                square([side_thickness, notch_length], true);    
    }
}


module lip() {
    difference() {
        linear_extrude(lip_height) {
            difference() {
                polygon(polyRound(lip_outer_polygon, 256));
                polygon(polyRound(lip_inner_polygon, 256));
            }
         }
    }
}

module cube(x,y,d) {
 translate([0,d/2])
    rotate([90,0,0])
    linear_extrude(d)
        square([x,y], true);
}

