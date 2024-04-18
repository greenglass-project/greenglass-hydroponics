include <Round-Anything/polyround.scad>

2pin_inner_x = 10.7;
3pin_inner_x = 15.3;
4pin_inner_x = 2*2pin_inner_x;

inner_y = 7.8;
conn_padding = 2;

conn_depth = 12;
        
2pin_outer_x = 2pin_inner_x + 2*conn_padding;
3pin_outer_x = 3pin_inner_x + 2*conn_padding;
4pin_outer_x = 2*2pin_inner_x + 2*conn_padding;

outer_y = inner_y + 2*conn_padding;

module 2pin_outer() {
    cube(2pin_outer_x,outer_y, conn_depth);
}

module 2pin_inner() {
    cube(2pin_inner_x, inner_y, conn_depth); 
}

module 3pin_outer() {
    cube(3pin_outer_x, outer_y, conn_depth);
}

module 3pin_inner() {
    cube(3pin_inner_x, inner_y, conn_depth); 
}
    
module 4pin_outer() {
    cube(4pin_outer_x, outer_y, conn_depth);
}

module 4pin_inner() { 
    cube(4pin_inner_x, inner_y, conn_depth);
}


module cube(x,y,d) {
 translate([0,d/2])
    rotate([90,0,0])
    linear_extrude(d)
        square([x,y], true);
}