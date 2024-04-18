include <Round-Anything/polyround.scad>

mount_polygon = [
    [-3,0,1],
    [-6,4,0.25],
    [-3,4,0],
    [-3,6,0],
    [3,6,0],
    [3,4,0],
    [6,4,0.25],
    [3,0,1]
];

 module extrusion_mount(length) {
    translate([6,length/2,0]) {
        rotate([90,270,0]) {
            linear_extrude(length)
                polygon(polyRound(mount_polygon, 256));
        }
    }
  }