$fn = 128;

base_mount_x = 40;
base_mount_y = 50;

base_surround_x = 7;
base_surround_y = 7;
base_thickness = 3.5;

panel_thickness = 2.5;

top_thickness = 2.5;



pi_mount_x = 58;
pi_mount_y = 49;

pi_0_mount_x = pi_mount_x;
pi_0_mount_y = 23;

pi_board_x = 65;
pi_board_y = 56.5;

pi_0_board_x = 65;
pi_0_board_y = 30;
pi_0_sd_offset = 12.5;

cutout_x = pi_mount_x - 3;
cutout_y = pi_mount_y - 3;
cutout_thickness = 3;

length = pi_board_x + base_surround_x;
width = pi_board_y + base_surround_y;

lip_thickness = 3;
lip_height = 4;

lip_outer_x = length - top_thickness;
lip_outer_y = width - top_thickness;

lip_inner_x = lip_outer_x - lip_thickness;
lip_inner_y = lip_outer_y - lip_thickness;

lid_height = 55.0;

connector_width = 10.5;


clip_bottom_width = 2;
clip_top_width = 0.75;
clip_length = 5;

notch_length = 8;
notch_height = 1.5;


base_polygon = [
    
    [-length/2, width/2, 3],
    [length/2, width/2, 3],
    [length/2, -width/2, 3],
    [-length/2, -width/2, 3]   
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


module pi0_mount(height) {

    mount(-pi_mount_x/2, pi_mount_y/2, 6, height, 2.5);
    mount(pi_mount_x/2, pi_mount_y/2, 6, height, 2.5);
    mount(-pi_mount_x/2, pi_mount_y/2 - pi_0_mount_y, 6, height, 2.5);
    mount(pi_mount_x/2, pi_mount_y/2 - pi_0_mount_y, 6, height, 2.5);

}


module mount(x,y, dia, height, hole) {
    translate([x,y,0]) {
        linear_extrude(height) {
            difference() {
                circle(d=dia);
                circle(d=hole);
            }
        }
    }
}

module notches() {

    linear_extrude(notch_height) 
        square([length, notch_length], true);
   /* union() {
        translate([length/2 +2,0,0])
            linear_extrude(notch_height)
                square([lip_thickness, notch_length*], true);
        translate([-length/2,0,0])
            linear_extrude(notch_height)
                square([lip_thickness, notch_length], true);    
    }*/
}


module clip() {
    clip_polygon = [
        [-clip_bottom_width/2, 0, 0],
         [-clip_top_width/2,lip_thickness/4, 0.4],
         [clip_top_width/2,lip_thickness/4, 0.4],
         [clip_bottom_width/2, 0, 0]
     ];
      
     linear_extrude(clip_length)
        polygon(polyRound(clip_polygon, 256));
}

module right_clip() {
    translate([0,clip_length/2,0])
    rotate([90,-90,0])
       clip();
}

module left_clip() {
    translate([0,clip_length/2,0])
    rotate([90,90,0])
       clip();
}

module lip() {
    union() {
        linear_extrude(lip_height) {
            difference() {
                polygon(polyRound(lip_outer_polygon, 256));
                polygon(polyRound(lip_inner_polygon, 256));
            }
         }
         //translate([lip_outer_x/2, 0, lip_height/3])
         //   left_clip();
         //translate([-lip_outer_x/2, 0, lip_height/3])
         //   right_clip();
    }
}


