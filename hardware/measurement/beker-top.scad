difference() {
    union() {
        linear_extrude(5)
            circle(d=55, $fn=128);
        linear_extrude(15)
            circle(d=41.4, $fn=128);
     }
     linear_extrude(15)
        circle(d=12.6, $fn=128);
}
