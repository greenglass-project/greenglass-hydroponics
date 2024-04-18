include <extrusion-mount.scad>


pipe_dia = 27; 

mount_thickness = 3;
mount_length = 20;
mount_width = 35;
gap = 18;
base_thickness = 30;

union() {
    difference() {
        linear_extrude(mount_length) {
            difference() {
                circle(d = pipe_dia + 2*mount_thickness, $fn = 128);
                circle(d = pipe_dia, $fn = 128);
            }
        }
        translate([pipe_dia/2,0,0])
        linear_extrude(mount_length)
            square([mount_thickness*2,gap], true);
    }
    translate([-pipe_dia/2 - base_thickness/2,0, 0]) {
        linear_extrude(mount_length)
            square([base_thickness, mount_width], true);
        
    }
    translate([-43.5,0,10])
        rotate([0,180,0])

    extrusion_mount(mount_width);
    
    
}