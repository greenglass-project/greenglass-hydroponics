include <Round-Anything/polyround.scad>
include <parameters.scad>

mount_offset_x = 11;
mount_offset_y = 5;
mount_thicknes = 3;
bracket_width = 9;
extrusion_width = 20;

lug_length = 15;

lug_hole_x = (length + lug_length)/2;


mount_length = length/2 - mount_offset_x;
mount_width = width/2 - mount_offset_y;

inner_length = mount_length - bracket_width;
inner_width = mount_width - bracket_width;

lugs_polygon = [
    [-length/2 - lug_length, extrusion_width/2, 3],
    [length/2 + lug_length, extrusion_width/2, 3],
    [length/2 + lug_length, -extrusion_width/2, 3],
    [-length/2 - lug_length, -extrusion_width/2, 3],
];


outer_polygon = [
    [-mount_length, mount_width, 3],
    [mount_length, mount_width, 3],
    [mount_length, -mount_width, 3],
    [-mount_length, -mount_width, 3]   
];

inner_polygon = [
    
    [-inner_length, inner_width, 3],
    [inner_length, inner_width, 3],
    [inner_length, -inner_width, 3],
    [-inner_length, -inner_width, 3]   
];

difference() {
    union() {
        linear_extrude(base_thickness)
            polygon(polyRound(outer_polygon, 256));
        linear_extrude(base_thickness)
            polygon(polyRound(lugs_polygon, 256));   
   
        translate([30,0,base_thickness])
            linear_extrude(6)
                square([6,6], true);
        
        translate([-30,0,base_thickness])
            linear_extrude(6)
                square([6,6], true);   
    }
    union() {    
        linear_extrude(base_thickness)
            polygon(polyRound(inner_polygon, 256));
        
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
 
        translate([-lug_hole_x,0,0])
            linear_extrude(base_thickness)
                circle(d=4);
        
        translate([lug_hole_x,0,0])
            linear_extrude(base_thickness)
                circle(d=4); 
    }    
}