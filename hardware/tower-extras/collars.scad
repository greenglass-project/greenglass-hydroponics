use <Threads/Naca_sweep.scad>
use <Threads/Threading.scad>
use <threadlib/threadlib.scad>
outer = 115;
wall = 6;

//top();
bottom();

module top() {
    union() {
        rotate([180,0,00]) {
            translate([0,0,-55.5])
                difference() {
                    spacer();
                    linear_extrude(30)
                        circle(d=outer+2, $fn=128);
                }
        }
        translate([0,0,25.5])
            thread_ring();
        translate([0,0,16.5])
            ring();
            
    }
}

module bottom() {
    union() {
        //rotate([180,0,00]) {
            //translate([0,0,-55.5])
                difference() {
                    spacer();
                    translate([0,0,35]) {
                    linear_extrude(30)
                        circle(d=outer+2, $fn=128);
                }
        }
        translate([0,0,25.5])
            thread_ring();
        translate([0,0,16.5])
            ring();
            
    }
}


module spacer() {
    translate([-outer/2, -outer/2, 0])
        import("/Users/steve/Development/projects/greenglass-hydroponics/hardware/tower/files/Module_Spacer_40mm.STL");

}

module thread_ring() {
        difference() {
            cylinder(15.5, 115/2, 115/2, false, $fn=256);
            cylinder(15.5, 102/2, 102/2, false, $fn=256);
        }    
        Threading(D=104, pitch = 2.75, windings = 5, d=98, angle = 60, center=false, $fn=256);
    
}

module ring() {
    difference() {
        cylinder(8, 115/2, 115/2, false, $fn=256);
        cylinder(8, 115/2, 86/2, false, $fn=256);
    }
        
        translate([0,0,8]) {

        difference() {
            cylinder(4, 115/2, 115/2, false, $fn=256);
            cylinder(4, 86/2, 86/2, false, $fn=256);
        } 
        }
     //}
}