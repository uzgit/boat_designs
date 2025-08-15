include <../library/roundedcube.scad>

$fn = 120;

hull_beam = 100;
hull_depth = 200;
hull_midship_longitude = 200;
hull_bow_longitude = 150;
hull_bow_stem_curvature_radius = 10;

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

//module hull_bow(size)
//{
//    linear_extrude(global_end_rib_longitude)
//    hull_midship_cross_section(size, thickness=global_rib_thickness);
//    
//    translate([0, 0, size[2] - hull_bow_stem_curvature_radius])
//    for( scalar = [-1, 1] )
//    {
//        translate([0, scalar * (size[1]/2 - hull_bow_stem_curvature_radius), 0])
//        sphere(r=hull_bow_stem_curvature_radius);
//    }
//}

function interpolate(x, x_min, x_max, y_min, y_max) =
    y_min + (x - x_min) * (y_max - y_min) / (x_max - x_min);

module hull_bow_shell(size, longitudinal_steps=50)
{
    difference()
    {
        hull()
        {
            for( i = [1 : longitudinal_steps] )
            {
                curvature_radius = interpolate(i, 0, longitudinal_steps, curving_radius, hull_bow_stem_curvature_radius);
                x_translation = (size[0]/2 - curvature_radius) * abs((1 - i / longitudinal_steps)^0.75);
                z_translation = (size[2] - curvature_radius) * i / longitudinal_steps;
                
                translate([0, 0, z_translation])
                for( scalar_x = [-1, 1] )
                translate([scalar_x * x_translation, 0, 0])
                for( scalar_y = [-1, 1] )
                {
                    translate([0, scalar_y * (size[1]/2 - curvature_radius), 0])
                    sphere(r=curvature_radius);
                }
            }
            
            local_thickness = 1;
            translate([0, 0, -local_thickness])
            linear_extrude(local_thickness)
            hull_midship_cross_section(size, thickness=local_thickness);
        }
        
        local_size = 1000;
        translate([0, 0, -local_size/2])
        cube([local_size, local_size, local_size], center=true);
    }
}

module hull_bow(size, thickness=hull_thickness, longitudinal_steps=100)
{
    // shell
    difference()
    {
        hull_bow_shell([hull_beam, hull_depth, hull_bow_longitude], longitudinal_steps);
        hull_bow_shell([hull_beam - 2*hull_thickness, hull_depth - 2*hull_thickness, hull_bow_longitude - hull_thickness], longitudinal_steps);
    }
    
    // ribs
    difference()
    {
        difference()
        {
            hull_bow_shell([hull_beam - hull_thickness, hull_depth - hull_thickness, hull_bow_longitude - hull_thickness], longitudinal_steps);
            hull_bow_shell([hull_beam - 2*global_rib_thickness, hull_depth - 2*global_rib_thickness, hull_bow_longitude - hull_thickness], longitudinal_steps);
        }
        difference()
        {
            local_size = 1000;
            union()
            {
                cube([local_size, local_size, local_size], center=true);
            }
            union()
            {
                // end rib
                translate([0, 0, global_end_rib_longitude/2])
                cube([local_size, local_size, global_end_rib_longitude], center=true);
                
                // intermediate rib
                translate([0, 0, hull_bow_longitude/2])
                cube([local_size, local_size, global_rib_longitude], center=true);
                
                // runner x
                translate([0, 0, hull_bow_longitude/2])
                cube([global_rib_longitude, hull_depth, hull_bow_longitude], center=true);
                // runners y
                translate([0, 0, hull_bow_longitude/2])
                for( i = [ 1 : hull_midship_runners_y ] )
                {
                    y_translation = size[1]/(hull_midship_runners_y + 1) * i - hull_depth/2;
                    translate([0, y_translation, 0])
                    cube([hull_beam, global_rib_longitude, hull_bow_longitude], center=true);
                }
            }
        }
    }
    
    // bow reinforcement
    difference()
    {
        hull_bow_shell([hull_beam - hull_thickness, hull_depth - hull_thickness, hull_bow_longitude - hull_thickness], longitudinal_steps);
        difference()
        {
            local_size = 1000;
            cube([local_size, local_size, local_size], center=true);
            
            difference()
            {
                translate([0, 0, hull_bow_longitude])
                cube([local_size, local_size, 40], center=true);
            }
        }
    }
}

hull_bow([hull_beam, hull_depth, hull_bow_longitude]);

//translate([0, 0, -hull_midship_longitude - 10])
//hull_midship([hull_beam, hull_depth, hull_midship_longitude], hull_midship_ribs, hull_midship_runners_x, hull_midship_runners_y);
//
//translate([0, 0, -2*hull_midship_longitude - 20])
//hull_midship([hull_beam, hull_depth, hull_midship_longitude], hull_midship_ribs, hull_midship_runners_x, hull_midship_runners_y);