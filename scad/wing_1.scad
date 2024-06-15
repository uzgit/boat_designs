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
            circle(d=thickness);
        }
    }
}

module wing_sharp(wingspan, chord_length_mm, max_thickness_mm, max_thickness_position, wingspan_inflection_position, top_chord_length_mm, top_max_thickness_mm, steps, center_on_max=true)
{
    intermediate_thickness = 0.1;
    
    translate([-chord_length_mm * max_thickness_position, 0, 0])
    difference()
    {
        hull()
        {
            // bottom
            translate([chord_length_mm * max_thickness_position, 0, 0])
            linear_extrude(intermediate_thickness)
            airfoil(chord_length_mm, max_thickness_mm, max_thickness_position, steps);
            
            // inflection point
            translate([chord_length_mm * max_thickness_position, 0, 0])
            translate([0, 0, wingspan * wingspan_inflection_position - intermediate_thickness])
            linear_extrude(intermediate_thickness)
            airfoil(chord_length_mm, max_thickness_mm, max_thickness_position, steps);
            
            // top
            translate([top_chord_length_mm * max_thickness_position, 0, 0])
            translate([0, 0, wingspan - intermediate_thickness])
            linear_extrude(intermediate_thickness)
            airfoil(top_chord_length_mm, max_thickness_mm, max_thickness_position, steps);
        }
        union()
        {
            translate([chord_length_mm * max_thickness_position, 0, 0])
            cylinder(d=10, h=wingspan);
        }
    }
}

function get_chord_length(x, x0, x1, y0, y1, a) = y0 - (y0 - y1) * ((x - x0) / (x1 - x0)) ^ a;

// Example usage:
// Uncomment and adjust values to test the function
// echo(custom_function(10, 0, 20, 100, 50, 2));


module wing_curved(wingspan, chord_length_mm, max_thickness_mm, max_thickness_position, wingspan_inflection_position, top_chord_length_mm, top_max_thickness_mm, steps, center_on_max=true)
{
    intermediate_thickness = 1;
    z_translation_step = wingspan / intermediate_thickness;
    
    translate([-chord_length_mm * max_thickness_position, 0, 0])
    hull()
    {
        for( z = [ 0 : intermediate_thickness : wingspan - intermediate_thickness ] )
        {
//            current_chord_length = chord_length_mm*exp(ln(top_chord_length_mm/chord_length_mm)*z/wingspan);
            current_chord_length = get_chord_length(z, 0, wingspan, chord_length_mm, top_chord_length_mm, 1.5);
            
            translate([current_chord_length*max_thickness_position, 0, z])
            linear_extrude(intermediate_thickness)
            airfoil(current_chord_length, max_thickness_mm, max_thickness_position, steps);
        }
    }
}

wingspan = 420;
wingspan_inflection_position = 0.5;
chord_length_mm = 150;
max_thickness_mm = 30;
max_thickness_position = 0.33;
top_chord_length_mm = 100;
top_max_thickness_mm = 30;
steps = 100;

screw_attachment_angle = 30;
screw_attachment_y_offset = 2;
screw_head_diameter = 6;
screw_head_hole_z_offset = 5;
screw_inset_diameter = 4;
screw_hole_diameter = 3.1;
screw_hole_depth = 100;
screw_inset_depth = 8;
screw_inset_x_min = -40;
screw_inset_x_max = 60;
num_screw_insets = 4; // needs to be even

module wing_top()
{
    difference()
    {
        union()
        {
    wing_curved(wingspan/2, chord_length_mm, max_thickness_mm, max_thickness_position, wingspan_inflection_position, top_chord_length_mm, top_max_thickness_mm, steps, center_on_max=true);
        }
        union()
        {   
            screw_inset_x_increment = (screw_inset_x_max - screw_inset_x_min) / (num_screw_insets / 2);
//            translate([0, 0, wingspan/2])
            translate([screw_inset_x_min, 0, 0])
            union()
            {
                for( i = [0 : num_screw_insets/2 - 1] )
                translate([i * screw_inset_x_increment, screw_attachment_y_offset, 0 ])
                rotate([-screw_attachment_angle, 0, 0])
                {
                    cylinder(d=screw_hole_diameter, screw_hole_depth*2, center=true);
                    
                    translate([0, 0, screw_head_hole_z_offset])
                    cylinder(d=screw_head_diameter, screw_hole_depth*2);
                }
                
                for( i = [0 : num_screw_insets/2 - 1] )
                translate([(i+0.5) * screw_inset_x_increment, -screw_attachment_y_offset, 0 ])
                rotate([screw_attachment_angle, 0, 0])
                {
                    cylinder(d=screw_hole_diameter, screw_hole_depth*2, center=true);
                    
                    translate([0, 0, screw_head_hole_z_offset])
                    cylinder(d=screw_head_diameter, screw_hole_depth*2);
                }
            }
            cylinder(d=10, h=wingspan);
        }
    }
}

module wing_bottom()
{
    difference()
    {
        union()
        {
            wing_curved(wingspan/2, chord_length_mm, max_thickness_mm, max_thickness_position, wingspan_inflection_position, chord_length_mm, top_max_thickness_mm, steps, center_on_max=true);
        }
        union()
        {   
            screw_inset_x_increment = (screw_inset_x_max - screw_inset_x_min) / (num_screw_insets / 2);
            translate([0, 0, wingspan/2])
            translate([screw_inset_x_min, 0, 0])
            union()
            {
                for( i = [0 : num_screw_insets/2 - 1] )
                translate([i * screw_inset_x_increment, screw_attachment_y_offset, 0 ])
                rotate([-screw_attachment_angle, 0, 0])
                cylinder(d=screw_inset_diameter, screw_inset_depth*2, center=true);
                
                for( i = [0 : num_screw_insets/2 - 1] )
                translate([(i+0.5) * screw_inset_x_increment, -screw_attachment_y_offset, 0 ])
                rotate([screw_attachment_angle, 0, 0])
                cylinder(d=screw_inset_diameter, screw_inset_depth*2, center=true);
            }
            cylinder(d=10, h=wingspan);
        }
    }
}

//difference()
//{
//    wing_top();
//    
//    translate([0, 0, 500+20])
//    cube(1000, center=true);
//}
//
//difference()
//{
//    translate([0, 0, -wingspan/2])
//    translate([0, 30, 0])
//    wing_bottom();
//    
//    translate([0, 0, -500-20])
//    cube(1000, center=true);
//}

//wing_top();
//translate([0, 0, -wingspan/2])
//translate([0, 30, 0])
//wing_bottom();

module wing_assembled()
{
    wing_bottom();
    
//    translate([0, 0, 20])
    translate([0, 0, wingspan/2])
    wing_top();
}

//wing_assembled();