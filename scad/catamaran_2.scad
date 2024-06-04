include <../library/roundedcube.scad>

$fn=500;

w1 = 0;
w2 = 20;
h  = 150;

r = ((w1^2 + h^2)/4 - (w1*w2)/2 + w2^2/4)/(w2 - w1);
d = 2*r - w2;

module catamaran_hull_v1(width_tip, width_max, length, height)
{
    w1 = width_tip;
    w2 = width_max;
    h  = length;

    r = ((w1^2 + h^2)/4 - (w1*w2)/2 + w2^2/4)/(w2 - w1);
    d = 2*r - w2;
    
    hull()
    {
    linear_extrude(height)
        intersection()
        {
            translate([-d/2, 0, 0])
            circle(r=r);

            translate([d/2, 0, 0])
            circle(r=r);
            
            square(length, center=true);
        }
        
        // smooth ends
        for( y_translation = [-length/2, length/2] )
        {
            translate([0, y_translation, 0])
            cylinder(d=width_tip-0.1, h=height);
        }
//        translate([0, length/2, height/2])
//        roundedcube([15, 1, height], center=true, apply_to="xy");
    }
}

module hull_shell_v1(width_tip, width_max, length, height, thickness, num_ribs=3, rib_thickness=1.5, rib_interior_extent=3)
{
    difference()
    {
        catamaran_hull_v1(width_tip, width_max, length, height);
        
        translate([0, 0, thickness])
        catamaran_hull_v1(width_tip-thickness, width_max-2*thickness, length-2*thickness, height - thickness);
    }
    
    // ribs
    difference()
    {
        union()
        {
            catamaran_hull_v1(width_tip, width_max, length, height);
        }
        difference()
        {
            catamaran_hull_v1(width_tip, width_max, length, height);
            union()
            {
                difference()
                {
                    union()
                    {
                    
        //                // center rib
        //                cube([1000, rib_thickness, 1000], center=true);
                        

                        increment = length / (num_ribs + 1);
                        translate([0, -length/2, 0])
                        for( i = [1 : num_ribs] )
                        {
                            translate([0, i*increment, 0])
                            cube([1000, rib_thickness, 1000], center=true);
                        }
                    }
                    
                    translate([0, 0, 2*rib_interior_extent - rib_thickness])
                    catamaran_hull_v1(width_tip - 2*thickness - rib_interior_extent, width_max - 2*thickness - rib_interior_extent, length - 2*thickness - rib_interior_extent, height - 2*thickness - rib_interior_extent);
                }
            }
        }
    }
}

hull_width_tip = 5;
hull_width_max = 30;
hull_length    = 150;
hull_height    = 30;
hull_wall_thickness = 1.5;
num_ribs = 5;

hull_separation = 100;

translate([-hull_separation/2, 0, 0])
hull_shell_v1(hull_width_tip, hull_width_max, hull_length, hull_height, hull_wall_thickness, num_ribs);

translate([hull_separation/2, 0, 0])
hull_shell_v1(hull_width_tip, hull_width_max, hull_length, hull_height, hull_wall_thickness, num_ribs);

//translate([-hull_separation/2, 0, 0])
//catamaran_hull_v1(hull_width_tip, hull_width_max, hull_length, hull_height);
//
//translate([hull_separation/2, 0, 0])
//catamaran_hull_v1(hull_width_tip, hull_width_max, hull_length, hull_height);