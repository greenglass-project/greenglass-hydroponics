include <Round-Anything/polyround.scad>
include <extrusion-mount.scad>
thickness = 4;
small_dia = 28.5;
large_dia = 34.5;
mount_length = 30;

/*mount_polygon = [
[-3,0,1],
[-6,4,0.25],
[-3,4,0],
[-3,6,0],
[3,6,0],
[3,4,0],
[6,4,0.25],
[3,0,1]
];*/

//translate([0, 25, 0])
    mount(small_dia);
//translate([0, -25, 0])
//    mount(large_dia);


//mount(large_dia);

//linear_extrude(20)
//    polygon(polyRound(mount_polygon, 256));
    
 module mount(dia) {
 
    outer_dia = dia + 2*thickness;
 
    difference() {
     union() {
        linear_extrude(14) 
            circle(d=outer_dia, $fn=128);
            
        translate([mount_length/2,0,0]) {
            linear_extrude(14) 
            square([mount_length, outer_dia], true);
        }

        translate([mount_length, 0,14/2])
            extrusion_mount(outer_dia);
        
       }
       linear_extrude(14) 
            circle(d=dia, $fn=128);
    }
  }
  
  
  
  /*module extrusion_mount(length) {
    translate([6,length/2,0]) {
        rotate([90,270,0]) {
            linear_extrude(length)
                polygon(polyRound(mount_polygon, 256));
        }
    }
  }*/