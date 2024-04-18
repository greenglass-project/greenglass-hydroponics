
use <Threads/Naca_sweep.scad>
use <Threads/Threading.scad>
use <threadlib/threadlib.scad>

outer = 115;
wall = 6;

rotate([0,180,0]) {
    connector();
    translate([0,0,20])
        cone();
    translate([0,0,80])
        thread();
}

module connector() {
    translate([0,0,60]) {
        rotate([0,180, 0]) {
            difference() {
                spacer();
                linear_extrude(40) {
                    circle(d = outer+2, $fn=128);
                }
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
        cylinder(h=60, r1=115/2, r2=17, center=false, $fn=256);
        cylinder(h=60, r1=115/2-4, r2=17-4, center=false, $fn=256);

        //cylinder(h=40, r1=100/2-6, r2=14-4, center=false, $fn=256);
    }

}

module thread() {
difference() {
    linear_extrude(14) 
        circle(d=34, $fn=128);
     tap("G3/4", turns=8);
}
}