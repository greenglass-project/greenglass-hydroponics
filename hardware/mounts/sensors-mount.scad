include <Round-Anything/polyround.scad>


top_length = 80; //120;
top_width = 80;
top_thickness = 6;

top_top = 28;
slot_bottom = 25;
slot_depth = 10;

cutout_length = 59;
cutout_width = 35;


mount_polygon = [
    [-top_length/2, top_width/2,10],
    [top_length/2, top_width/2, 10],
    [top_length/2, -top_width/2, 0],
    [-top_length/2, -top_width/2, 0]
];

cutout_polygon = [
    [-cutout_length/2, cutout_width/2, 5],
    [cutout_length/2, cutout_width/2, 5],
    [cutout_length/2, -cutout_width/2, 5],
    [-cutout_length/2, -cutout_width/2, 5]
];

difference() {
    union() {
        base();
        translate([-top_length/3, 30, top_thickness])
            rotate([0,0,90])
                tower();
        translate([0, 30, top_thickness])
            rotate([0,0,90])
                tower();
        translate([top_length/3, 18, top_thickness+60])
            rotate([90,0,180])
                probe();
     }
     union() {
        translate([0,-3,0])
        linear_extrude(top_thickness)
            polygon(polyRound(cutout_polygon, 256));
            
        translate([top_length/3, 30, 0])    
            linear_extrude(top_thickness)
                circle(d = 12, $fn=256);
                
        translate([0,30,0])         
            linear_extrude(top_thickness)
                circle(d = 12, $fn=256);
                
         translate([-top_length/3, 30, 0])    
            linear_extrude(top_thickness)
                circle(d = 12, $fn=256);
 
     }
}


module base() {


    difference() {
        union() {
            linear_extrude(top_thickness)
                polygon(polyRound(mount_polygon, 256));
            
            translate([top_length/5, -top_width/2+10, top_thickness]) {
                linear_extrude(6) {
                    square([6, 6], true);
                }
            }
 
           translate([0, -top_width/2+10, top_thickness]) {
                linear_extrude(6) {
                    square([6, 6], true);
                }
            }
            
            translate([-top_length/5,-top_width/2+10, top_thickness]) {
                linear_extrude(6) {
                    square([6, 6], true);
                }
            }
            //translate([0,mount_total_width/2-32, 0]) {
                //tower();
            //}
        }
        union() {
          
             translate([-top_length*2/5,-top_width/2+10, 0]) {
                linear_extrude(top_thickness) {
                    circle(d=4, $fn=128);
                }
            }
            translate([top_length*2/5,-top_width/2+10, 0]) {
                linear_extrude(top_thickness) {
                    circle(d=4, $fn=128);
                }
            }
        }
    }
}




module tower() {
    difference() {
        union() {
            translate([-9,0,0])
            linear_extrude(120)
                square([5,10],true);
            
            translate([0,0,95])
                linear_extrude(25)
                    circle(d=20, $fn=128);
            

            
        }
        union() {
            
            translate([-9, -2.5,37])
                linear_extrude(4)
                    square([5,2], true);
               
           translate([-9, 2.5,37])
                linear_extrude(4)
                    square([5,2], true);               
            
            translate([-9, -2.5,77])
                linear_extrude(4)
                    square([5,2], true);
               
            translate([-9, 2.5,77])
                linear_extrude(4)
                    square([5,2], true);      
 
            translate([4,0,105])
                linear_extrude(5){
                square([20,20],true);
            }
            translate([8,0,95])
                linear_extrude(30){
                square([5,5],true);
            }
            translate([0,0,95])
                linear_extrude(25)
                    circle(d=16, $fn=128);
            
            /*translate([0,0,70]) {
                linear_extrude(30){
                circle(d=16, $fn=128);
                }
            }*/
        
        }
    }
}


module probe() {

    difference() {
        union() {
            linear_extrude(5) {
                square([10,120],true);
            }
            //translate([0, -50-top_thickness/2,0]) {
            //    linear_extrude(4.5)          
            //        square([4.5,5], true);
            //}
            rotate([90,0,0])
                translate([0,7.5,-60]) {
                    clip();
            }
        }
        union() {
            translate([2.5,20,0]) {
                linear_extrude(5) {
                    square([2,4], true);
                }
            }
            translate([-2.5,20,0]) {
                linear_extrude(5) {
                    square([2,4], true);
                }
            }
            translate([2.5,-20,0]) {
                linear_extrude(5) {
                    square([2,4], true);
                }
            }
            translate([-2.5,-20,0]) {
                linear_extrude(5) {
                    square([2,4], true);
                }
            }
           
           /* translate([4,0,70])
                linear_extrude(5){
                square([20,20],true);
            }
            translate([4,0,85])
                linear_extrude(5){
                square([20,20],true);
            }
            translate([8,0,75])
                linear_extrude(30){
                square([5,5],true);
            }
             //translate([0,mount_total_width/2-20, 0]) {
            linear_extrude(70) {
                circle(d=12, $fn=128);
            }*/
            ///translate([0,0,0]) {
            //    linear_extrude(70){
            //    circle(d=16, $fn=128);
            //    }
            //}
        
        }
    }
}

module clip() {
    difference() {

        linear_extrude(10) {
            circle(d=6, $fn=128);
        }
        union() {
            linear_extrude(10) {
                circle(d=4, $fn=128);
            }
            translate([0,2,0]) {
                linear_extrude(10) {
                    square([2,4], true);
                }
            }
            
        }
    }
        
    
}
