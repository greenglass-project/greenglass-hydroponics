
use <Threads/Naca_sweep.scad>
use <Threads/Threading.scad>
use <threadlib/threadlib.scad>

outer = 115;
wall = 6;


connector();
translate([0,0,25])
    cone();
translate([0,0,85])
    thread();
filter();


module connector() {
    difference() {
        spacer();
        translate([0,0,25]) {
            linear_extrude(35) {
                circle(d = outer+2, $fn=128);
            }
        }
    }
}


module spacer() {
    translate([-outer/2, -outer/2, 0])
        import("/Users/steve/Development/projects/greenglass-hydroponics/hardware/tower/files/Module_Spacer_40mm.STL");

}

module cone() {
    difference() {
        cylinder(h=60, r1=115/2, r2=14, center=false, $fn=256);
        cylinder(h=60, r1=115/2-4, r2=14-4, center=false, $fn=256);

        //cylinder(h=40, r1=100/2-6, r2=14-4, center=false, $fn=256);
    }

}

module thread() {
difference() {
    linear_extrude(14) 
        circle(d=28, $fn=128);
     tap("G1/2", turns=9);
}
}

module filter() {
    difference() {
        linear_extrude(3) {
            circle(d=98, $fn=256);
        }
            
         union() {
            //linear_extrude(3) {
            //    circle(d=5.0, $fn=128);
            // }
            for(a = [0, 45, 90, 135, 180, 225, 270, 315]) {
     
                rotate([0,0,a]) {
                    for(i = [96*0.1, 96*0.2, 96*0.3, 96*0.4]) {
                        translate([0,i,0]) {
                            linear_extrude(3) {
                                circle(d=5.0, $fn=128);
                            }
                        }
                    }
                 }
             }
         }
     }
 }