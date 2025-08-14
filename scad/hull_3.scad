$fn = 120;

function max_to_zero_monotonic_decreasing(x, length, max_value, squareness) = max_value * ( 1 - (x^squareness)/(length^squareness));

function hull_radius_horizontal(x, length, max_width, squareness) = max_width/2 * (1 - (abs(x)^squareness)/((length/2)^squareness));

module hull_horizontal_cross_section(length, max_width, squareness)
{
//    hull()
    for( x = [-length/2 : 5 : length/2] )
    {
        translate([x, 0, 0])
        sphere(r=max_to_zero_monotonic_decreasing(x, length, max_width, squareness));
    }
}

length = 400;
height = 100;
max_width = 100;
squareness = 4;

height_2 = 40;

intersection()
{
    hull()
    {
        translate([0, 0, -(height/2 - max_width/4)])
        hull_horizontal_cross_section(length, max_width, squareness);
        
        translate([0, 0, height/2 - max_width/4])
        hull_horizontal_cross_section(length, max_width, squareness);
    }
    
    
}