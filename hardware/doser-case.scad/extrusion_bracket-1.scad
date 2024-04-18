include <Round-Anything/polyround.scad>
include <parameters.scad>


mount_spacing = 50;
mount_side = mount_spacing + 10;

mount_extension = 17;
mount_thickness = 6;
mount_width = 20;


offset = mount_spacing/3-6;

outer_polygon = [
    [-mount_side/2, mount_side/2, 3],
    [mount_side/2, mount_side/2, 3],
    [mount_side/2, -mount_side/2, 3],
    [-mount_side/2, -mount_side/2, 3]
  
];


mount();


module mount() {

    difference() {
        union() {
            translate([-0, offset,0])
                linear_extrude(mount_thickness) 
                    square([length + 2 * mount_extension, mount_width], true);
                
            translate([-lower_mount_spacing/2 -lower_mount_offset,0,0])
                linear_extrude(mount_thickness)
                
                    square([mount_width, width], true);
            translate([lower_mount_spacing/2 +lower_mount_offset,0,0])
                linear_extrude(mount_thickness)
                    square([mount_width, width], true);
        
            translate([-lower_mount_spacing/2, offset,mount_thickness])
                linear_extrude(6)
                    square([6, 6], true);
            
            translate([lower_mount_spacing/2, offset,mount_thickness])
                linear_extrude(6)
                    square([6, 6], true);       

            translate([-lower_mount_spacing/2 -lower_mount_offset, offset ,mount_thickness])
                linear_extrude(6)
                    square([6, 6], true);
            
            translate([lower_mount_spacing/2 + lower_mount_offset, offset,mount_thickness])
                linear_extrude(6)
                    square([6, 6], true);         
            
        }
        union() {
            translate([length/2 + mount_extension/2, offset,0])
                linear_extrude(mount_thickness)
                    circle(d=4.5, $fn=128);

            translate([-length/2 - mount_extension/2, offset,0])
                linear_extrude(mount_thickness)
                    circle(d=4.5, $fn=128);
            
            translate([-lower_mount_spacing/2 -lower_mount_offset, mount_spacing/2,0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=128);

            translate([-lower_mount_spacing/2 -lower_mount_offset, -mount_spacing/2,0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=128);
                    
            translate([lower_mount_spacing/2 +lower_mount_offset, mount_spacing/2,0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=128);
                    
            translate([lower_mount_spacing/2 + lower_mount_offset, -mount_spacing/2,0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=128);    

                    
        }
    }
}


/*module mount() {
    difference() {
        union() {
            linear_extrude(mount_thickness)
                polygon(polyRound(outer_polygon, 256));
             translate([0,-mount_spacing/4+5,mount_thickness])
                extrusion_bracket(mount_side);

        }
        
        union() {
            translate([-mount_spacing/2, mount_spacing/2, 0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=128);
            translate([mount_spacing/2, mount_spacing/2, 0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=128);        
            translate([mount_spacing/2, -mount_spacing/2, 0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=128);
            translate([-mount_spacing/2, -mount_spacing/2, 0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=128);        
        }
    }
}*/


module extrusion_bracket(length) {
    centre_width = 6.4;
    center_height = 5.5;
    extrusion_side = 20;
    side_thickness = 3;

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


module extrusion_mount(length) {
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
    translate([length/2, 0, 6]) {
        rotate([270,0,90]) {
            linear_extrude(length)
                polygon(polyRound(mount_polygon, 256));
        }
    }
  }