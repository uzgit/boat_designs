include <../library/roundedcube.scad>

$fn=60;

w1 = 10;
w2 = 20;
h  = 100;

r = ((w1^2 + h^2)/4 - (w1*w2)/2 + w2^2/4)/(w2 - w1);
d = 2*r - w2;

linear_extrude(10)
intersection()
{
    translate([-d/2, 0, 0])
    circle(r=r);

    translate([d/2, 0, 0])
    circle(r=r);
}

translate([0, 0, -5])
roundedcube([5, 90, 5], center=true);
