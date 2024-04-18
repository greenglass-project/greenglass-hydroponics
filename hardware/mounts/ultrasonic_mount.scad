include <Round-Anything/polyround.scad>

board_length = 51.0;
board_width = 22.0;
sensor_dia = 17;

sensor_spacing = 34.0;
mount_x = 46.0;
mount_y = 17;
mount_height = 3;

gap = 2;
wall_thickness = 2;
height = 30;

lug_length = 15;
lug_width = 20;

lip_height = 2;

outer_width = board_width + 2*gap + 2*wall_thickness;
outer_length = board_length + 2*gap + 2*wall_thickness;
inner_width = board_width + 2*gap ;
inner_length = board_length + 2*gap;

lip_inner_length = inner_length - 1.5;
lip_inner_width = inner_width - 1.5;

2pin_inner_x = 10.7;
4pin_inner_x = 2*2pin_inner_x;
inner_y = 7.8;
conn_padding = 2;
conn_depth = 12;
4pin_outer_x = 2*2pin_inner_x + 2*conn_padding;
outer_y = inner_y + 2*conn_padding;

outer_polygon = [
    [-outer_length/2, outer_width/2, 3],
    [outer_length/2, outer_width/2, 3],
    [outer_length/2, -outer_width/2, 3],
    [-outer_length/2, -outer_width/2, 3]
];
inner_polygon = [
    [-inner_length/2, inner_width/2, 3],
    [inner_length/2, inner_width/2, 3],
    [inner_length/2, -inner_width/2, 3],
    [-inner_length/2, -inner_width/2, 3]
];

lip_inner_polygon = [
    [-lip_inner_length/2, lip_inner_width/2, 3],
    [lip_inner_length/2, lip_inner_width/2, 3],
    [lip_inner_length/2, -lip_inner_width/2, 3],
    [-lip_inner_length/2, -lip_inner_width/2, 3]
];


translate([0,-20,0])
    lower();

translate([0,2s0,0])
    lid();

module lower() {
    difference () {
        union() {
            linear_extrude(wall_thickness + height)
                polygon(polyRound(outer_polygon, 256));
                
             translate([0,outer_width/2,lug_width/2])
                mount();
        }
        union() {

            translate([0,0,wall_thickness + mount_height])
                linear_extrude(height)
                    polygon(polyRound(inner_polygon, 256));   
            translate([0,0,wall_thickness])
                linear_extrude(mount_height)
                    square([sensor_spacing,inner_width], true);
            translate([-sensor_spacing/2, 0, 0])
                linear_extrude(wall_thickness + mount_height)
                    circle(d=sensor_dia, $fn=128);
             translate([sensor_spacing/2, 0, 0])
               linear_extrude(wall_thickness + mount_height) 
                    circle(d=sensor_dia, $fn=128);
  
             translate([-mount_x/2, mount_y/2, wall_thickness ])
                linear_extrude(mount_height)
                    circle(d=2.5, $fn=128);
                    
             translate([mount_x/2, mount_y/2, wall_thickness ])
                linear_extrude(mount_height)
                    circle(d=2.5, $fn=128);                     

             translate([mount_x/2, -mount_y/2, wall_thickness ])
                linear_extrude(mount_height)
                    circle(d=2.5, $fn=128);                     

             translate([-mount_x/2, -mount_y/2, wall_thickness ])
                linear_extrude(mount_height)
                    circle(d=2.5, $fn=128);
                    
             translate([-inner_length/2 - wall_thickness/2, 0, wall_thickness + height-1])
                linear_extrude(1)
                    square([wall_thickness,4], true);                        

             translate([inner_length/2 + wall_thickness/2, 0, wall_thickness + height-1])
                linear_extrude(1)
                    square([wall_thickness,4], true);     
         }        
           
    }


}

module mount() {
    rotate([90,0,0])
    difference() {
        linear_extrude(wall_thickness)
            square([outer_length + 2*lug_length, lug_width], true);
        union() {
            translate([-outer_length/2-lug_length/2,0,0])
                linear_extrude(wall_thickness)
                    circle(d=3, $fn=128);
            translate([outer_length/2+lug_length/2,0,0])
                linear_extrude(wall_thickness)
                    circle(d=3, $fn=128);
        }       
    }

}


module lid() {
    difference() {
        union() {
            linear_extrude(wall_thickness)
                polygon(polyRound(outer_polygon, 256));
            difference() {
                translate([0,0,wall_thickness])
                    linear_extrude(lip_height)
                        polygon(polyRound(inner_polygon, 256));

                translate([0,0,wall_thickness])
                    linear_extrude(lip_height)
                        polygon(polyRound(lip_inner_polygon, 256));    
        
            }
            translate([0,inner_y/2,0])
                cube(4pin_outer_x, outer_y, conn_depth);
        }
        translate([0,inner_y/2,0])
            cube(4pin_inner_x, inner_y, conn_depth);
    }
}


module cube(x,y,d) {
 //translate([0,d/2])
   // rotate([00,0,0])
    linear_extrude(d)
        square([x,y], true);
}





