include <Round-Anything/polyround.scad>
include <parameters.scad>


base();


module base() {
    difference() {
        union() {
            difference() {
       
                linear_extrude(height)
                    polygon(polyRound(base_polygon, 256));
                translate([0,0,base_thickness])
                    linear_extrude(height-base_thickness)
                        polygon(polyRound(inner_polygon, 256));
            }
            translate([pi_mount_center_x,0,base_thickness])
                pi_mount();
        }
        translate([-length/2 + side_thickness - 3,0, + fan_side/2 + base_thickness])
        fan_cutouts(3);
        
    }

}



//cooling_grill(20,20,2.5,0.5,2);


module cooling_grill(horizontal_holes, vertical_holes, hole_size, gap, thickness) {
    
    length = horizontal_holes*(hole_size+gap)-gap;
    width = vertical_holes*(hole_size+gap)-gap;
    
    translate([-length/2, -width/2]) {
    
        for ( i = [0 : horizontal_holes-1] ){
            x = i*(hole_size + gap) + hole_size;
            translate([x,0,0])
                vertical_holes(vertical_holes, hole_size, gap,thickness);
         }
     }
 }
 
 module vertical_holes(vertical_holes, hole_size, gap, thickness) {
    
    y = 0;
    for ( i = [0 : vertical_holes-1] ){
        y = i*(hole_size + gap) + hole_size;
        translate([0,y,0])
            linear_extrude(thickness)
                circle(d=hole_size);
    }
}


module pi_mount() {

    mount(-pi5_mount_x/2, pi5_mount_y/2, 6, 6, 3);
    mount(pi5_mount_x/2, pi5_mount_y/2, 6, 6, 3);
    mount(pi5_mount_x/2, -pi5_mount_y/2, 6, 6, 3);
    mount(-pi5_mount_x/2, -pi5_mount_y/2, 5, 6, 3);

}


module mount(x,y ,dia, height, hole) {
    translate([x,y,0]) {
        linear_extrude(height) {
            difference() {
                circle(d=dia);
                circle(d=hole);
            }
        }
    }
}

module fan_cutouts(thickness) {
    rotate([90,0,90])
    union() {
        translate([-fan_side/2,0,0])
            fan_mount(thickness);
        translate([fan_side/2,0,0])
            fan_mount(thickness);
    }
}

module fan_mount(thickness) {
     union() {
        linear_extrude(thickness)
            circle(d=fan_cutout);
        translate([-fan_mount/2, fan_mount/2, 0])
            linear_extrude(thickness)
                circle(d=fan_mount_hole);
        translate([fan_mount/2, fan_mount/2, 0])
            linear_extrude(thickness)
                circle(d=fan_mount_hole);
        translate([fan_mount/2, -fan_mount/2, 0])
            linear_extrude(thickness)
                circle(d=fan_mount_hole);        
        translate([-fan_mount/2, -fan_mount/2, 0])
            linear_extrude(thickness)
                circle(d=fan_mount_hole);        
    
    }
}


    
