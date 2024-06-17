include <./hull_17_june_2024_1.scad>
include <wing_1.scad>

hull_separation = 260;

for( y_translation = [-hull_separation/2, hull_separation/2] )
{
    translate([0, y_translation, 0])
    default_hull();
}

rotate([0, 0, 180])
wing_assembled();