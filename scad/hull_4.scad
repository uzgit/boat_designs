$fn=120;

// Function to calculate NACA 4-digit airfoil thickness
// at a given position along the chord
// x in [0,1]: position along the chord length from beginning to end
// t_max in [0,1]: max thickness as a proportion of chord length
function naca2412_thickness(x, t_max) = t_max / 0.02 * (
    0.2969 * sqrt(x) 
    - 0.1260 * x 
    - 0.3516 * pow(x, 2) 
    + 0.2843 * pow(x, 3) 
    - 0.1015 * pow(x, 4)
);

module airfoil(chord_length_mm, max_thickness_mm, max_thickness_position, steps)
{
    max_camber_step = steps * max_thickness_position;
    x_translation_step = chord_length_mm / steps;
    
    hull()
    {
        for( step = [1 : steps] )
        {
            thickness = naca2412_thickness(step / steps, 0.12) * max_thickness_mm;
        
            translate([ x_translation_step * (step-max_camber_step), 0, 0])
            circle(d=2*thickness);
        }
    }
}

wingspan = 420;
wingspan_inflection_position = 0.5;
chord_length_mm = 500;
max_thickness_mm = 100;
max_thickness_position = 0.33;
top_chord_length_mm = 100;
top_max_thickness_mm = 30;
steps = 100;

screw_attachment_angle = 30;
screw_attachment_y_offset = 0;
screw_head_diameter = 6;
screw_head_hole_z_offset = 5;
screw_inset_diameter = 4;
screw_hole_diameter = 3.1;
screw_hole_depth = 100;
screw_inset_depth = 8;
screw_inset_x_min = -40;
screw_inset_x_max = 60;
num_screw_insets = 4; // needs to be even

airfoil(chord_length_mm, max_thickness_mm, max_thickness_position, steps);

//hull()
//{
//    rotate([0, 0, -5])
//    translate([chord_length_mm * max_thickness_position, 0, 0])
//    airfoil(chord_length_mm, max_thickness_mm, max_thickness_position, steps);
//    
//    rotate([0, 0,  5])
//    translate([chord_length_mm * max_thickness_position, 0, 0])
//    airfoil(chord_length_mm, max_thickness_mm, max_thickness_position, steps);
//}
