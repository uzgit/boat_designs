$fn = 120;

function hull_diameter_horizontal(x, length, max_width, squareness) = max_width/2 * (1 - (abs(x)^squareness)/((length/2)^squareness));

module hull_horizontal_cross_section(length, max_width, squareness)
{
    hull()
    for( x = [-length/2 : 1 : length/2] )
    {
        translate([x, 0, 0])
        circle(d=hull_diameter_horizontal(x, length, max_width, squareness));
    }
}

function max_to_zero_monotonic_decreasing(x, length, max_value, squareness) = max_value * ( 1 - (x^squareness)/(length^squareness));

module catamaran_hull(length, max_width, squareness, height, vertical_inflection_point, length_squareness, width_squareness)
{
    hull()
    {
        vertical_section_height = height*vertical_inflection_point;
        translate([0, 0, -vertical_section_height/2])
        linear_extrude(vertical_section_height)
        hull_horizontal_cross_section(length, max_width, squareness);
        
        intermediate_thickness = 1;
        top_bottom_height = (height - vertical_section_height) / 2;
        
    //    translate([0, 0, vertical_section_height/2])
        for( z = [ 0 : intermediate_thickness : top_bottom_height + intermediate_thickness*2])//  - intermediate_thickness*2] )
        {
            current_length = max_to_zero_monotonic_decreasing(z, top_bottom_height, length, length_squareness);
            current_max_width = max_to_zero_monotonic_decreasing(z, top_bottom_height, max_width, width_squareness);
        
            translate([0, 0, vertical_section_height/2 + z])
            linear_extrude(intermediate_thickness)
            hull_horizontal_cross_section(current_length, current_max_width, squareness);
            
            translate([0, 0, -vertical_section_height/2 - z - intermediate_thickness])
            linear_extrude(intermediate_thickness)
            hull_horizontal_cross_section(current_length, current_max_width, squareness);
        }
    }
}

length = 300;
max_width = 100;
squareness = 2.4;
length_squareness = 6;
width_squareness = 2.4;
height = 100;
vertical_inflection_point = 0.5;

catamaran_hull(length, max_width, squareness, height, vertical_inflection_point, length_squareness, width_squareness);