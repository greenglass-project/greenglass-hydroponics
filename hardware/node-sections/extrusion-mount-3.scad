include <Round-Anything/polyround.scad>
include <common/parameters.scad>


mount_thickness = 4;

extrusion_width = 20;
extrusion_extension = 15;


mount();
module mount() {
    difference() {
        union() {
            linear_extrude(mount_thickness)
                polygon(polyRound(base_polygon, 256));
            translate([0, base_mount_y/4, 0])
                linear_extrude(mount_thickness)
                    square([width + 2*extrusion_extension, extrusion_width], true);
            
            translate([-base_mount_x/2, base_mount_y/4,mount_thickness])
                linear_extrude(6)
                    square([6, 6], true);
            
            translate([base_mount_x/2, base_mount_y/4,mount_thickness])
                linear_extrude(6)
                    square([6, 6], true);       
                    
        }                  
        union () {
            translate([-base_mount_x/2, base_mount_y/2,0])
                linear_extrude(mount_thickness)
                    circle(d=3);
            translate([base_mount_x/2,base_mount_y/2,0])
                linear_extrude(mount_thickness)
                    circle(d=3);
            translate([base_mount_x/2, -base_mount_y/2,0])
                linear_extrude(mount_thickness)
                    circle(d=3);
            translate([-base_mount_x/2,-base_mount_y/2,0])
                linear_extrude(mount_thickness)
                    circle(d=3);

            translate([-width/2 - extrusion_extension/2 - 1 , base_mount_y/4,0])
                linear_extrude(mount_thickness)
                    circle(d=3);
            translate([width/2 + extrusion_extension/2 + 1 , base_mount_y/4,0])
                linear_extrude(mount_thickness)
                    circle(d=3);
         }
    }
}
