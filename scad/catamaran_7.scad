include <../library/roundedcube.scad>
include <./wing_1.scad>
include <./hull_1.scad>

translate([0, 0, 75])
wing_assembled();

hull_separation = 120;

translate([30, 0, 0])
union()
{
//    catamaran_hull(350, 150, squareness, height, vertical_inflection_point, length_squareness, width_squareness);

    for( y_translation = [-hull_separation, hull_separation] )
    {
        translate([0, y_translation, 0])
        catamaran_hull(350, max_width, squareness, height, vertical_inflection_point, length_squareness, width_squareness);
    }
}