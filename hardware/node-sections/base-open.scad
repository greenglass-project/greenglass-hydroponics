include <Round-Anything/polyround.scad>
include <common/parameters.scad>
include <common/connectors.scad>

section_height = outer_y + base_thickness + 2;

pi_mount_height = 4;
conn_offset = 22;

base();

module base() {
    union() {
        difference() {

            union() {
                difference() {
                    linear_extrude(section_height)
                        polygon(polyRound(base_polygon, 256));
                    translate([0,0,base_thickness])
                        linear_extrude(section_height + base_thickness)
                            polygon(polyRound(lip_inner_polygon, 256));            
                }
                translate([0,0,base_thickness])
                    pi0_mount(pi_mount_height);
                 
 
                //translate([0, -width/2 - conn_depth/2+top_thickness+ 0.5, 0])
                //    linear_extrude(section_height)
                //        square([lip_inner_x, conn_depth], true); 
                
                translate([0,0,section_height])
                    lip();
            }
                             
            union () {
                //top_mount_holes();
                translate([-base_mount_x/2, base_mount_y/2,0])
                    linear_extrude(base_thickness)
                        circle(d=3);
                translate([base_mount_x/2,base_mount_y/2,0])
                    linear_extrude(base_thickness)
                        circle(d=3);
                translate([base_mount_x/2, -base_mount_y/2,0])
                    linear_extrude(base_thickness)
                        circle(d=3);
                translate([-base_mount_x/2,-base_mount_y/2,0])
                    linear_extrude(base_thickness)
                        circle(d=3);
                 //translate([0,0,section_height-lip_height])
                 //   lip();

                translate([-width/2 - 2*top_thickness, 
                            pi_mount_y/2 - pi_0_mount_y + pi_0_sd_offset,  
                            base_thickness + pi_mount_height + 2.5])
                    sd_slot(); 

            }

            translate([0, -width/2, 5])
                    linear_extrude(section_height-10)
                        square([lip_inner_x - 10, conn_depth], true);     
    }
 

    }
}

module sd_slot() {
    outer_x = 20;
    inner_x = 11;
    outer_y = 6;
    inner_y = 1.5;
    
  cubePoints = [
      [  -outer_x/2,  -outer_y/2,  0 ],               //0
      [ outer_x/2, -outer_y/2 ,  0 ],                 //1
      [ outer_x/2,  outer_y/2,  0 ],                  //2
      [  -outer_x/2,  outer_y/2,  0 ],                //3
      [  -inner_x/2,  -inner_y/2,  1.5*top_thickness ], //4
      [ inner_x/2, -inner_y/2 ,  1.5*top_thickness ],   //5
      [ inner_x/2,  inner_y/2,  1.5*top_thickness ],    //6
      [  -inner_x/2,  inner_y/2,  1.5*top_thickness]    //7
    ]; 
  
    cubeFaces = [
      [0,1,2,3],  // bottom
      [4,5,1,0],  // front
      [7,6,5,4],  // top
      [5,6,2,1],  // right
      [6,7,3,2],  // back
      [7,4,0,3]
    ]; // left
    
    rotate([90,0,90])
        polyhedron( cubePoints, cubeFaces ); 
}

module power_mount() {
    width = 14.0;
    height = 10.0;
    
    
    mount(-width/2, height/2, 5, 3.5, 1.5);
    mount(width/2, -height/2, 5, 3.5, 1.5);
}
