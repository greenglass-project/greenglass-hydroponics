
use <Threads/Naca_sweep.scad>
use <Threads/Threading.scad>
use <threadlib/threadlib.scad>


pitch = 2.75;
windings = 2;
angle = 60;


    difference() {
        union() {

            threading(pitch = 2.75, d=97, windings = 4, angle = 60, center=false, $fn = 256);
            linear_extrude(10)
                circle(d=93, $fn=128);

            translate([0,0,10]) {
                union() {
                    linear_extrude(1) {
                        circle(d=98, $fn=256);
                    }
        
                    translate([0,0,1])
                        cylinder(4, 98/2, 110/2, false, $fn=256);

                    translate([0,0,5]) {
                        linear_extrude(6)
                            circle(d=110, $fn=256);
                    }
 

                    translate([0,0,11])
                        cylinder(4, 110/2, 98/2, false, $fn=256);
                        
                   
                }
            }
        }
        linear_extrude(100) { //6.9+1+3+10) {
            circle(d=84, $fn=256);
        }
    }


translate([0,0,10+1+4+10 ]) {
    difference() {
        cylinder(h=40, r1=88/2, r2=17, center=false, $fn=256);
        cylinder(h=40, r1=84/2, r2=17-4, center=false, $fn=256);

        //cylinder(h=40, r1=100/2-6, r2=14-4, center=false, $fn=256);
    }
}

translate([0,0,10+1+4+10+40]) {
difference() {
    linear_extrude(14) 
        circle(d=34, $fn=128);
     tap("G3/4", turns=8);
}
}


 





