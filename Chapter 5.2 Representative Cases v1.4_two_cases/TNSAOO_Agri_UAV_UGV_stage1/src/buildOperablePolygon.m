function operablePoly = buildOperablePolygon(fieldPoly, obstacles)
%BUILDOPERABLEPOLYGON Subtract obstacle regions from the field polygon.
%
% The resulting polygon represents the traversable/croppable region for
% generating synthetic prescription patches, refill stations, depot, crop
% rows, and coverage paths.

operablePoly = fieldPoly;

for k = 1:numel(obstacles)
    if area(obstacles(k)) > 1e-9
        operablePoly = subtract(operablePoly, obstacles(k));
    end
end

operablePoly = rmholes(operablePoly);

if area(operablePoly) <= 1e-6
    error('The operable polygon is empty after obstacle subtraction.');
end
end
