include <../library/roundedcube.scad>

$fn = 120;

hull_beam = 100;
hull_depth = 200;
hull_midship_longitude = 200;

curving_radius = 30;
hull_thickness = 1;
global_rib_thickness = 15;
global_rib_longitude = 2;
global_end_rib_longitude = 4;
hull_midship_ribs = 1;
hull_midship_runners_x = 1;
hull_midship_runners_y = 2;

module rounded_square(size, radius, center = true)
{
	size = (size[0] == undef) ? [size, size] : size;

    diameter = 2*radius;
    
    centering_translation = center ? [-size[0]/2, -size[1]/2] : [0, 0];
    x_translation = size[0] - diameter;
    y_translation = size[1] - diameter;
    
    translate(centering_translation)
    translate([radius, radius])
    hull()
    {
        translate([0, 0, 0])
        circle(r=radius);
        translate([x_translation, 0, 0])
        circle(r=radius);
        translate([0, y_translation, 0])
        circle(r=radius);
        translate([x_translation, y_translation, 0])
        circle(r=radius);
    }
}

module hull_midship_cross_section(size, thickness=-1)
{
    cross_section_size = [size[0], size[1]];
    inner_cross_section_size = [size[0] - 2*thickness, size[1] - 2*thickness];
    inner_curving_radius = curving_radius - hull_thickness/2;
    
    difference()
    {
        rounded_square(cross_section_size, radius=curving_radius);
        if( thickness != -1 )
            rounded_square(inner_cross_section_size, radius=inner_curving_radius);
    }
}

module hull_midship(size, num_ribs, num_runners_x, num_runners_y)
{
    // shell
    linear_extrude(size[2])
    hull_midship_cross_section(size, thickness=hull_thickness);
    
    // longitudinal ends
    for( longitudinal_translation = [0, size[2] - global_end_rib_longitude] )
    {
        translate([0, 0, longitudinal_translation])
        linear_extrude(global_end_rib_longitude)
        hull_midship_cross_section(size, thickness=global_rib_thickness);
    }
    
    // ribs
    for( i = [ 1 : num_ribs ] )
    {
        translate([0, 0, size[2]/(num_ribs + 1) * i])
        linear_extrude(global_rib_longitude)
        hull_midship_cross_section(size, thickness=global_rib_thickness);
    }
    
    // runners, translating across the beam
    for( i = [ 1 : num_runners_x ] )
    {
        x_translation = size[0]/(num_runners_x + 1) * i - size[0]/2;
        y_translation = size[1]/2 - global_rib_thickness/2;
        z_translation = size[2]/2;
        
        for( scalar = [-1, 1] )
        {
            translate([x_translation, scalar * y_translation, z_translation])
            cube([global_rib_longitude, global_rib_thickness, size[2]], center=true);
        }
    }
    
    // runners, translating across the depth
    for( i = [ 1 : num_runners_y ] )
    {
        y_translation = size[1]/(num_runners_y + 1) * i - size[1]/2;
        x_translation = size[0]/2 - global_rib_thickness/2;
        z_translation = size[2]/2;
        
        for( scalar = [-1, 1] )
        {
            translate([scalar * x_translation, y_translation, z_translation])
            cube([global_rib_thickness, global_rib_longitude, size[2]], center=true);
        }
    }
}

hull_midship([hull_beam, hull_depth, hull_midship_longitude], hull_midship_ribs, hull_midship_runners_x, hull_midship_runners_y);