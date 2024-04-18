width = 140;

upper = 10;
lower = 3;

upper_thickness = 1.5;
lower_thickness = 3;

union() {
    linear_extrude(upper_thickness)
        square([width, upper], true);
    linear_extrude(upper_thickness+ lower_thickness)
        square([width, lower], true);
}
