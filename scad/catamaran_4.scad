include <../library/roundedcube.scad>

$fn=1000;

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
    
    translate([0, 0, -height/2])
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
            cylinder(d=width_tip*0.95, h=height);
        }
    }
}

module hull_ribs(width_tip, width_max, length, height, thickness, visualize, num_ribs=4, rib_thickness=1.5, rib_interior_extent=15)
{
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
                        increment = length / (num_ribs + 1);
                        translate([0, -length/2, 0])
                        for( i = [1 : num_ribs] )
                        {
                            translate([0, i*increment, 0])
                            cube([1000, rib_thickness, 1000], center=true);
                        }
                    }
                    union()
                    {
                        catamaran_hull_v1(width_tip-rib_interior_extent, width_max-rib_interior_extent, length-rib_interior_extent, height-rib_interior_extent);
                    }
                }
            }
        }
    }
}

module hull_shell(width_tip, width_max, length, height, thickness, visualize)
{
    difference()
    {
        union()
        {
            hull()
            {
                catamaran_hull_v1(width_tip, width_max, length, height);
                
                translate([0, 0, -height/2 - 10])
                roundedcube([3, 0.9*length, 10], center=true, radius=2);
            }
        }
        union()
        {
            hull()
            {
                catamaran_hull_v1(width_tip-thickness, width_max-2*thickness, length-2*thickness, height - thickness);
            }
            
            if( visualize )
            {
                // remove_top (for visualization only)
                translate([0, 0, 3*thickness])
                catamaran_hull_v1(width_tip-thickness, width_max-2*thickness, length-2*thickness, height - thickness);
            }
        }
    }
}

module catamaran_hull(width_tip, width_max, length, height, thickness, visualize=false, num_ribs=4, left=false, right=false, wheel_reinforcement_width=5, wheel_reinforcement_depth=50, wheel_outer_rolling_reinforcement_diameter=20, wheel_outer_rolling_reinforcement_height=2, wheel_inner_rolling_reinforcement_height=10, wheel_shaft_diameter=6.6, cabin_mount_thickness=10, cabin_mount_depth=150, cabin_mount_width=15, cabin_mount_num_screws=3, cabin_mount_screw_spacing=40)
{
    difference()
    {
        union()
        {
            hull_shell(width_tip, width_max, length, height, thickness, visualize);
            hull_ribs(width_tip, width_max, length, height, thickness, visualize, num_ribs);
            
            translate([0, 0, height/2])
            union()
            {
                roundedcube([cabin_mount_width, cabin_mount_depth, 2*cabin_mount_thickness], center=true, apply_to="xy");
            }
            
            union()
            {
                if( left )
                {
                    translate([-width_max/2, 0, 0])
                    union()
                    {
                        cube([2*wheel_reinforcement_width, wheel_reinforcement_depth, height], center=true);
                        cube([2*wheel_inner_rolling_reinforcement_height, wheel_outer_rolling_reinforcement_diameter, height], center=true);
                        
                        translate([width_max/4, 0, height/2])
                        cube([width_max/2, wheel_outer_rolling_reinforcement_diameter, 2*cabin_mount_thickness], center=true);
                    }
                }
                if( right )
                {
                    translate([width_max/2, 0, 0])
                    union()
                    {
                        cube([2*wheel_reinforcement_width, wheel_reinforcement_depth, height], center=true);
                        cube([2*wheel_inner_rolling_reinforcement_height, wheel_outer_rolling_reinforcement_diameter, height], center=true);
                        
                        translate([-width_max/4, 0, height/2])
                        cube([width_max/2, wheel_outer_rolling_reinforcement_diameter, 2*cabin_mount_thickness], center=true);
                    }
                }
            }
        }
        union()
        {
            increment = cabin_mount_depth / (cabin_mount_num_screws + 1);
            translate([0, -cabin_mount_depth/2, height/2])
            for( i = [1 : cabin_mount_num_screws] )
            {
                translate([0, i*increment, 0])
                cylinder(d=7, h=cabin_mount_thickness, center=true);
            }
            
            difference()
            {
                cube([length, length, length], center=true);
                hull()
                {
                    hull_shell(width_tip, width_max, length, height, thickness, visualize);
                }
            }
            if( left )
            {
                translate([-width_max/2+6, 0, 0])
                rotate([0, -90, 0]) 
                cylinder(d=6.6, h=6);
            }
            if( right )
            {
                translate([width_max/2-6, 0, 0])
                rotate([0, 90, 0]) 
                cylinder(d=6.6, h=6);
            }
        }
    }
    union()
    {
        if( left )
        {
            translate([-width_max/2, 0, 0])
            union()
            {
                rotate([0, -90, 0])
                difference()
                {
                    cylinder(d=wheel_outer_rolling_reinforcement_diameter, wheel_outer_rolling_reinforcement_height);
                    cylinder(d=6.6, wheel_outer_rolling_reinforcement_height);
                }
            }
        }
        if( right )
        {
            translate([width_max/2, 0, 0])
            union()
            {
                rotate([0, 90, 0])
                difference()
                {
                    cylinder(d=wheel_outer_rolling_reinforcement_diameter, wheel_outer_rolling_reinforcement_height);
                    cylinder(d=6.6, wheel_outer_rolling_reinforcement_height);
                }
            }
        }
    }
}

module paddle_wheel(spoke_radius=40, spoke_thickness=3, wheel_thickness=30, hub_radius=10, tread_thickness=10, tread_outer_diameter=85, tread_inner_diameter=79, left=false, right=false)
{
    difference()
    {
        union()
        {
            cylinder(r=hub_radius, h=wheel_thickness, center=true);
            num_spokes = 10;
            angle_increment = 360 / num_spokes;
            for( angle = [ 0 : angle_increment: 360] )
            {
                rotate([0, 0, angle])
                translate([0, spoke_radius/2, 0])
                cube([spoke_thickness, spoke_radius, wheel_thickness], center=true);
            }
            
            translate([0, 0, -wheel_thickness/2])
            difference()
            {
                cylinder(d=tread_outer_diameter, h=tread_thickness);
                cylinder(d=tread_inner_diameter, h=tread_thickness);
            }
        }
        union()
        {
            // shaft hole
            cylinder(d=6.6, h=wheel_thickness, center=true);
        }
    }
}

hull_width_tip = 20;
hull_width_max = 100;
hull_length    = 500;
hull_height    = 50;
hull_wall_thickness = 1.5;
num_ribs = 4;

hull_separation = 200;

visualize = true;

spoke_radius=50;
spoke_thickness=3;
wheel_thickness=30;
hub_radius=10;
tread_thickness=10;
tread_outer_diameter=105;
tread_inner_diameter=79;

translate([-hull_separation/2, 0, 0])
catamaran_hull(hull_width_tip, hull_width_max, hull_length, hull_height, hull_wall_thickness, visualize=false, left=true);

translate([hull_separation/2, 0, 0])
catamaran_hull(hull_width_tip, hull_width_max, hull_length, hull_height, hull_wall_thickness, visualize=true, right=true);

translate([ hull_separation/2 + hull_width_max/2 + 20, 0, 0])
rotate([0, 90, 0])
paddle_wheel(spoke_radius=spoke_radius, spoke_thickness=3, wheel_thickness=wheel_thickness, hub_radius=hub_radius, tread_thickness=tread_thickness, tread_outer_diameter=tread_outer_diameter, tread_inner_diameter=tread_inner_diameter, vi);

translate([-hull_separation/2 - hull_width_max/2 - 20, 0, 0])
rotate([0, -90, 0])
paddle_wheel(spoke_radius=spoke_radius, spoke_thickness=3, wheel_thickness=wheel_thickness, hub_radius=hub_radius, tread_thickness=tread_thickness, tread_outer_diameter=tread_outer_diameter, tread_inner_diameter=tread_inner_diameter);

//translate([0, 0, hull_height/2])
//translate([0, 0, 30])
//union()
//{
//    hull()
//    {
//        intersection()
//        {
//            hull()
//            {
//                translate([-hull_separation/2, 0, 0])
//                catamaran_hull_v1(hull_width_tip, hull_width_max, hull_length, hull_height, hull_wall_thickness, visualize=false, left=true);
//
//                translate([hull_separation/2, 0, 0])
//                catamaran_hull_v1(hull_width_tip, hull_width_max, hull_length, hull_height, hull_wall_thickness, visualize=true, right=true);
//            }
//            cube([1000, 150, hull_height], center=true);
//        }
//        
////        translate([0, 0, 50])
////        roundedcube([150, 100, 1], center=true, apply_to="all", radius=5);
//    }
//}

$fa = 1; $fs = 0.5;
translate([0, 0, 100])
hull() {
    rotate([0, 90, 0]) rotate_extrude() translate([15, 0]) circle(r=2);
}