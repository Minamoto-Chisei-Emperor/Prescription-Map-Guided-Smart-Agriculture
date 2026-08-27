function zone = createCircularZone(center, radius, fieldPoly)
%CREATECIRCULARZONE Create a circular task/obstacle zone clipped by field.
% This version avoids duplicated first/last vertices in the circle polygon.

theta = linspace(0, 2*pi, 65);
theta(end) = [];   % remove duplicated 2*pi point

x = center(1) + radius*cos(theta);
y = center(2) + radius*sin(theta);

circle = polyshape(x, y, 'Simplify', true);
zone = intersect(circle, fieldPoly);

if area(zone) <= 1e-6
    zone = circle;
end
end
