include <../library/roundedcube.scad>

$fn=120;

// Function to calculate NACA 4-digit airfoil thickness
// at a given position along the chord in mm
// x_mm in mm: position along the chord length from beginning to end
// chord_length in mm: the total chord length of the airfoil
// t_max_mm in mm: the maximum thickness of the airfoil in millimeters
function naca4_thickness_mm(x_mm, chord_length, t_max_mm) = 10*t_max_mm * (
    0.2969 * sqrt(x_mm / chord_length) 
    - 0.1260 * (x_mm / chord_length) 
    - 0.3516 * pow(x_mm / chord_length, 2) 
    + 0.2843 * pow(x_mm / chord_length, 3) 
    - 0.1015 * pow(x_mm / chord_length, 4)
);

module airfoil( chord_length, max_width, step_mm )
{
    translate([naca4_thickness_mm(step_mm, chord_length, max_width)/2-step_mm, 0, 0])
    hull()
    for( x = [ 0 : step_mm : chord_length ] )
    {
        translate([x, 0, 0])
        circle( d=naca4_thickness_mm(x, chord_length, max_width) );
    }
}

module spherefoil( chord_length, max_width, step_mm )
{
    translate([naca4_thickness_mm(step_mm, chord_length, max_width)/2-step_mm, 0, 0])
    hull()
    for( x = [ 0 : step_mm : chord_length ] )
    {
        translate([x, 0, 0])
        sphere( d=naca4_thickness_mm(x, chord_length, max_width) );
    }
}

// Example usage:
// chord_length = 100 mm
// t_max_mm = 12 mm (12% of chord length)
// Calculate thickness at x_mm = 50 mm (midpoint of the chord)

//translate([naca4_thickness_mm(0.05, 100, 12)/2, 0, 0])
chord_length = 300;
max_width = 100;
step_mm = 1;
////translate([3.40741/2 - 1, 6, 0])
//translate([naca4_thickness_mm(step_mm, chord_length, max_width)/2-step_mm, 0, 0])
//linear_extrude(1)
//hull()
//for( x = [ 0 : step_mm : chord_length ] )
//{
//    echo( x );
//    translate([x, 0, 0])
//    circle( d=naca4_thickness_mm(x, chord_length, max_width) );
//    
//    translate([310, 0, 0])
//    square([1, 60], center=true);
//}

hull()
{
    translate([15, 0, -35])
//    linear_extrude(1)
//    translate([275, 0, 0])
//    rotate([0, 0, 180])
    spherefoil(275, 50, step_mm );
    
    translate([310, 0, -35])
    roundedcube([1, 40, 1], radius=10, center=true);
    
    translate([0, 0, -1])
    linear_extrude(1)
    hull()
    {
        airfoil( chord_length, max_width, step_mm );
//        translate([310, 0, 0])
//        square([1, 60], center=true);
    }
    
    translate([300, 0, -18])
    roundedcube([1, 60, 1], radius=10, center=true);
}