include <../library/roundedcube.scad>

$fn=120;

module middle_cross_section(width=10, height=75, rounding_radius=5)
{
//    square([width, height], center=true);
    x_coordinate = width/2 - rounding_radius;
    y_coordinate = height/2 - rounding_radius;
    
    hull()
    for( x_translation=[-x_coordinate, x_coordinate] )
    {
        for( y_translation=[-y_coordinate, y_coordinate] )
        {
            translate([x_translation, y_translation, 0])
            circle(r=rounding_radius);
        }
    }
}

module catamaran_hull(width=100, height=75, length=140, rounding_radius=5, thickness=1, mounting_rib_thickness=10, mounting_rib_loft_height=5)
{
    translate([0, 0, -length/2])
    linear_extrude(length)
    difference()
    {
        middle_cross_section(width, height, rounding_radius=5);
        middle_cross_section(width-thickness, height-thickness, rounding_radius=5);
    }
    
    translate([0, 0, length/2-thickness])
    loft()
    {
        linear_extrude(thickness)
        difference()
        {
            middle_cross_section(width, height, rounding_radius=5);
            middle_cross_section(width-mounting_rib_thickness, height-mounting_rib_thickness, rounding_radius=5);
        }
        translate([0, 0, -mounting_rib_loft_height-thickness])
        linear_extrude(thickness)
        difference()
        {
            middle_cross_section(width, height, rounding_radius=5);
            middle_cross_section(width-thickness, height-thickness, rounding_radius=5);
        }
    }
}

catamaran_hull();