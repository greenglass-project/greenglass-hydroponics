include <Round-Anything/polyround.scad>
include <parameters.scad>


pi_board_x = 65;
pi_board_y = 56.5;

pi_mount_x = 58;
pi_mount_y = 49;

pi_0_mount_x = pi_mount_x;
pi_0_mount_y = 23;

pi_board_x = 65;
pi_board_y = 56.5;

pi_0_board_x = pi_board_x;
pi_0_board_y = 30;
pi_0_sd_offset = 12.5;

pi_mount_height = 4;
hat_mount_height = 18 + pi_mount_height;

mount_thickness = 3;
mount_spacing = 3;
mount_width = 12;

mount_x = pi_board_x + 2 * mount_spacing;
mount_y =  pi_board_y + 2 * mount_spacing;
mount_inner_x = mount_x - 2*mount_width;
mount_inner_y = mount_y - 2*mount_width;

base_width = 20;
base_hole_spacing = 40;

mount_outer_polygon = [
    [-mount_x/2, mount_y/2, 5],
    [mount_x/2, mount_y/2, 5],
    [mount_x/2, -mount_y/2, 5],
    [-mount_x/2, -mount_y/2, 5]
];

mount_inner_polygon = [
    [-mount_inner_x/2, mount_inner_y/2, 5],
    [mount_inner_x/2, mount_inner_y/2, 5],
    [mount_inner_x/2, -mount_inner_y/2, 5],
    [-mount_inner_x/2, -mount_inner_y/2, 5]
];


back();

module pi_mount() {
    translate([0,-pi_mount_y/2,0]) {
        union() {
            board_mount(-pi_mount_x/2, 0, 6, pi_mount_height, 2.5);
            board_mount(pi_mount_x/2, 0, 6, pi_mount_height, 2.5);
            
            board_mount(-pi_mount_x/2, pi_0_mount_y, 6, pi_mount_height, 2.5);
            board_mount(pi_mount_x/2, pi_0_mount_y, 6, pi_mount_height, 2.5);

            board_mount(-pi_mount_x/2, pi_mount_y, 6, hat_mount_height, 2.5);
            board_mount(pi_mount_x/2, pi_mount_y, 6, hat_mount_height, 2.5);
        }
    }
}


module board_mount(x,y, dia, height, hole) {
    translate([x,y,0]) {
        linear_extrude(height) {
            difference() {
                circle(d=dia);
                circle(d=hole);
            }
        }
    }
}

module back() {
    
    difference() {
        union() {
            linear_extrude(mount_thickness)
                difference() {
                    polygon(polyRound(mount_outer_polygon, 256));
                    polygon(polyRound(mount_inner_polygon, 256));

                }
            translate([0,0,mount_thickness])
                pi_mount();
         }
         union() {
            translate([-pi_mount_x/2, 10,0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=128);
             translate([pi_mount_x/2, 10,0])
                linear_extrude(mount_thickness)
                    circle(d=3, $fn=128);
          }
      }
  }
          



module base() {

    difference() {
        linear_extrude(mount_thickness)
            square([mount_x,base_width], true);
        union() {
            translate([-base_hole_spacing/2,2,0])
                linear_extrude()
                    circle(d=3, $fn=128);
            translate([base_hole_spacing/2,2,0])
                linear_extrude()
                    circle(d=3, $fn=128);
        }
    }

}

