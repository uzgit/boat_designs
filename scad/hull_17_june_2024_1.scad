include <../library/roundedcube.scad>

$fn=60;

// Define the function
function naca4_thickness_mm(x_mm, chord_length, t_max_mm) = 10 * t_max_mm * (
    0.2969 * sqrt(x_mm / chord_length) 
    - 0.1260 * (x_mm / chord_length) 
    - 0.3516 * pow(x_mm / chord_length, 2) 
    + 0.2843 * pow(x_mm / chord_length, 3) 
    - 0.1015 * pow(x_mm / chord_length, 4)
);

module airfoil( chord_length, max_thickness, step_density_100mm, rounding_radius=2 )
{
    step_mm = chord_length / step_density_100mm;
    
    steps = [for(step=[ 1 : step_mm : chord_length] ) step ];
    thickness_values = [for(x = steps) naca4_thickness_mm(x, chord_length, max_thickness) ];
 
    hull()
    {
        for( step = steps )
        {
            translate([ step, 0, 0])
            circle(d=naca4_thickness_mm(step, chord_length, max_thickness));
        }
    }
}

module spherefoil( chord_length, max_thickness, step_density_100mm )
{
    step_mm = chord_length / step_density_100mm;
    
    steps = [for(step=[ 1 : step_mm : chord_length] ) step ];
    thickness_values = [for(x = steps) naca4_thickness_mm(x, chord_length, max_thickness) ];
 
    hull()
    {
        for( step = steps )
        {
            translate([ step, 0, 0])
            sphere(d=naca4_thickness_mm(step, chord_length, max_thickness));
        }
    }
}

module sphered_spherefoil( chord_length, max_thickness, step_density_100mm )
{
    step_mm = chord_length / step_density_100mm;
    
    steps = [for(step=[ 1 : step_mm : chord_length] ) step ];
    thickness_values = [for(x = steps) naca4_thickness_mm(x, chord_length, max_thickness) ];
 
    hull()
    {
        for( step = steps )
        {
            translate([ step, 0, 0])
            sphere(d=naca4_thickness_mm(step, chord_length, max_thickness));
        }
        
        sphere(d=max_thickness);
    }
}

module squared_spherefoil( chord_length, max_thickness, step_density_100mm )
{
    step_mm = chord_length / step_density_100mm;
    
    steps = [for(step=[ 1 : step_mm : chord_length] ) step ];
    thickness_values = [for(x = steps) naca4_thickness_mm(x, chord_length, max_thickness) ];
 
    hull()
    {
        for( step = steps )
        {
            translate([ step, 0, 0])
            sphere(d=naca4_thickness_mm(step, chord_length, max_thickness));
        }
        
        roundedcube([max_thickness, max_thickness, max_thickness], radius=10, center=true);
    }
}

module squared_airfoil( chord_length, max_thickness, step_density_100mm, rounding_radius=2 )
{
    step_mm = chord_length / step_density_100mm;
    
    steps = [for(step=[ 1 : step_mm : chord_length] ) step ];
    thickness_values = [for(x = steps) naca4_thickness_mm(x, chord_length, max_thickness) ];
    
    hull()
    {
        for( step = steps )
        {
            translate([ step, 0, 0])
            circle(d=naca4_thickness_mm(step, chord_length, max_thickness));
        }
        
        translate([rounding_radius,   max_thickness/2 - rounding_radius, 0])
        circle(r=rounding_radius);
        
        translate([rounding_radius, -(max_thickness/2 - rounding_radius), 0])
        circle(r=rounding_radius);
    }
}

module catamaran_hull( top_length, bottom_length, max_hull_thickness, bottom_rear_offset, bottom_vertical_offset, spine_rear_offset, spine_radius, spine_length )
{
    translate([ -0.4 * top_length, 0, 0, ])
    hull()
    {
        translate([0, 0, -1])
        linear_extrude(1)
        squared_airfoil( chord_length, max_thickness, step_density_100mm );

        translate([bottom_rear_offset, 0, bottom_vertical_offset])
        linear_extrude(1)
        squared_airfoil( chord_length, max_thickness, step_density_100mm );
        
        translate([spine_rear_offset, 0, bottom_vertical_offset])
        sphered_spherefoil( spine_length, spine_radius, step_density_100mm );
    }
}

// Parameters
chord_length  = 300; // Example chord length in mm
max_thickness = 90;      // Example maximum thickness in mm
step_density_100mm         = 300;   // Number of points to sample

top_length = 330;
bottom_length = 300;
max_hull_thickness = 90;
bottom_vertical_offset = -70;
bottom_rear_offset = -50;
spine_rear_offset = -20;
spine_radius = 30;
spine_length = 280;

module default_hull()
{
    catamaran_hull( top_length, bottom_length, max_hull_thickness, bottom_rear_offset, bottom_vertical_offset, spine_rear_offset, spine_radius, spine_length );
}

//default_hull();