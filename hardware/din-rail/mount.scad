
$fn = 128;

length = 60;
width = 24;
thickness = 4;
bracket_width = 15;
mount_width = 50;
mount_offset = width/4;
mount_hole = 4;


left_bracket();

translate([20,0,0])
    right_bracket();

   
module left_bracket() {
    translate([0,0,12])
    rotate([0,180,0])
    union() {
        clip();
        translate([length/2, 20,0])
        rotate([90,0,0])
            difference() {
                linear_extrude(thickness) 
                    square([length, width], true);
                translate([0,-mount_offset,0])
                    mount_holes();
            }
    }
}

module right_bracket() {
    rotate([0,180,0])

    union() {
    rotate([0,180,0])
            clip();
        translate([-length/2, 20,-12])
        rotate([90,0,0])
            difference() {
                linear_extrude(thickness) 
                    square([length, width], true);
                translate([0,-mount_offset,0])
                    mount_holes();
            }
    }
}


module clip() {
    import("dins_clip.STL");
}

module mount_holes() {
    union() {
        translate([mount_width/2,0,0])
            linear_extrude(thickness)
                circle(d=mount_hole);
        translate([-mount_width/2,0,0])
            linear_extrude(thickness)
                circle(d=mount_hole);    
    }

}