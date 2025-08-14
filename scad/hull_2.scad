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

function hull_diameter_vertical(x, length, max_width, squareness) = max_width/2 * (1 - (abs(x)^squareness)/((length/2)^squareness));

module hull_vertical_cross_section(length, max_height, squareness)
{
    max_radius = hull_diameter_vertical(0, length, max_height, squareness) / 2;

    hull()
    {
        translate([0, -max_height/2 + max_radius, 0])
        for( x = [-length/2 : 1 : length/2] )
        {
            translate([x, 0, 0])
            circle(d=hull_diameter_vertical(x, length, max_height, squareness));
        }
        
        translate([0, max_height/2 - max_radius, 0])
        for( x = [-length/2 : 1 : length/2] )
        {
            translate([x, 0, 0])
            circle(d=hull_diameter_vertical(x, length, max_height, squareness));
        }
    }
}

function max_to_zero_monotonic_decreasing(x, length, max_value, squareness) = max_value * ( 1 - (x^squareness)/(length^squareness));

module catamaran_hull_horizontal_top_bottom(length, max_width, squareness, height, vertical_inflection_point, length_squareness, width_squareness)
{
    hull()
    {
        vertical_section_height = height*vertical_inflection_point;
//        translate([0, 0, -vertical_section_height/2])
//        linear_extrude(vertical_section_height)
//        hull_horizontal_cross_section(length, max_width, squareness);
        
        intermediate_thickness = 1;
        top_bottom_height = (height - vertical_section_height) / 2;
        
//        translate([0, 0, vertical_section_height/2])
        for( z = [ 0 : intermediate_thickness : top_bottom_height + intermediate_thickness*2])//  - intermediate_thickness*2] )
        {
            current_length = max_to_zero_monotonic_decreasing(z, top_bottom_height, length, length_squareness);
            current_max_width = max_to_zero_monotonic_decreasing(z, top_bottom_height, max_width, width_squareness);
        
            translate([0, 0, vertical_section_height/2 + z])
            linear_extrude(intermediate_thickness)
            hull_horizontal_cross_section(current_length, current_max_width, squareness);
            
        }
    }
}

module catamaran_hull_horizontal_middle(length, max_width, squareness, height, vertical_inflection_point, length_squareness, width_squareness)
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
        
//            translate([0, 0, vertical_section_height/2 + z])
//            linear_extrude(intermediate_thickness)
//            hull_horizontal_cross_section(current_length, current_max_width, squareness);
//            
//            translate([0, 0, -vertical_section_height/2 - z - intermediate_thickness])
//            linear_extrude(intermediate_thickness)
//            hull_horizontal_cross_section(current_length, current_max_width, squareness);
        }
    }
}

module catamaran_hull_vertical(length, height, squareness, max_width,  vertical_squareness_1, vertical_squareness_2, vertical_squareness_3)
{
    side_width = max_width / 2;
    layer_height = 1;
    for( y = [0 : layer_height : max_width/2 - 1] )
    {
        current_length = max_to_zero_monotonic_decreasing(y, side_width, length, vertical_squareness_1);
        current_max_width = max_to_zero_monotonic_decreasing(y, side_width, max_width, vertical_squareness_2);
       
        translate([0, 0, y])
        linear_extrude(layer_height)
        hull_vertical_cross_section(current_length, current_max_width, vertical_squareness_3);
    }
}

length = 300;
max_width = 100;
squareness = 2.4;
length_squareness = 6;
width_squareness = 2.4;
height = 100;
vertical_inflection_point = 0.5;
vertical_section_height = height*vertical_inflection_point;
vertical_squareness_1 = 2;
vertical_squareness_2 = 2;
vertical_squareness_3 = 2;

//hull_horizontal_cross_section(length, max_width, squareness);

//catamaran_hull_horizontal(length, max_width, squareness, height, vertical_inflection_point, length_squareness, width_squareness);

rotate([90, 0, 0])
hull()
{
    catamaran_hull_vertical(length, max_width/2, squareness, height,  vertical_squareness_1, vertical_squareness_2, vertical_squareness_3);
    
    rotate([180, 0, 0])
    catamaran_hull_vertical(length, max_width/2, squareness, height,  vertical_squareness_1, vertical_squareness_2, vertical_squareness_3);
}

//hull()
//{
//    catamaran_hull_horizontal_middle(length, max_width, squareness, height, vertical_inflection_point, length_squareness, width_squareness);
//
//    catamaran_hull_horizontal_top_bottom(length, max_width, squareness, height, vertical_inflection_point, length_squareness, width_squareness);
//
//    rotate([180, 0, 0])
//    catamaran_hull_horizontal_top_bottom(length, max_width, squareness, height, vertical_inflection_point, length_squareness, width_squareness);
//}