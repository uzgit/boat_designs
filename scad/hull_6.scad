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

chord_length = 300;
max_width = 100;
step_mm = 1;