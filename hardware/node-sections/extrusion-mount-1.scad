
include <Round-Anything/polyround.scad>
include <common/parameters.scad>

thickness = 3.0;
    centre_width = 6.4;
    center_height = 5.5;
    extrusion_side = 20.5;
    side_thickness = 3;
    
    
    mount_width = base_mount_y + 10;
    mount_length = base_mount_x + 10;
    
    mount_polygon = [
        [-mount_length/2, mount_width/2, 5],
        [mount_length/2, mount_width/2, 5],
        [mount_length/2, -mount_width/2, 5],
        [-mount_length/2,- mount_width/2, 5]
    ];

rotate([270,0,0])
mount();
    
module mount() {    
    difference() {
        union() {
            linear_extrude(thickness)
                polygon(polyRound(mount_polygon, 256));
            
            //translate([mount_length/2, 0,thickness + extrusion_side/2 + side_thickness])
            translate([0, mount_width/2,thickness + extrusion_side/2 + side_thickness])
                rotate([90,0,0])
                    extrusion_bracket(mount_length/2);
        }
        union() {
            translate([-base_mount_x/2, base_mount_y/2,0])
                linear_extrude(thickness)
                    circle(d=3);
            translate([base_mount_x/2,base_mount_y/2,0])
                linear_extrude(thickness)
                    circle(d=3);
            translate([base_mount_x/2, -base_mount_y/2,0])
                linear_extrude(thickness)
                    circle(d=3);
            translate([-base_mount_x/2,-base_mount_y/2,0])
                linear_extrude(thickness)
                    circle(d=3);
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

