function metrics = computeFieldShapeMetricsFromPoly(poly, xy)
%COMPUTEFIELDSHAPEMETRICSFROMPOLY Compute geometric metrics for a field.

a = area(poly);
bbox = [min(xy(:,1)), max(xy(:,1)), min(xy(:,2)), max(xy(:,2))];
w = bbox(2) - bbox(1);
h = bbox(4) - bbox(3);

try
    p = perimeter(poly);
catch
    p = localPerimeter(xy);
end

shapeIndex = p / max(2*sqrt(pi*a), eps);
compactness = 4*pi*a / max(p^2, eps);
aspectRatio = max(w,h) / max(min(w,h), eps);

try
    k = convhull(xy(:,1), xy(:,2));
    convexArea = polyarea(xy(k,1), xy(k,2));
    convexityRatio = a / max(convexArea, eps);
catch
    convexityRatio = NaN;
end

metrics = struct();
metrics.area_m2 = a;
metrics.area_ha = a/10000;
metrics.width_m = w;
metrics.height_m = h;
metrics.perimeter_m = p;
metrics.shapeIndex = shapeIndex;
metrics.compactness = compactness;
metrics.aspectRatio = aspectRatio;
metrics.convexityRatio = convexityRatio;
end

function p = localPerimeter(xy)
if isempty(xy)
    p = NaN;
    return;
end
xy = xy(all(isfinite(xy),2),:);
if size(xy,1) < 2
    p = NaN;
    return;
end
d = diff([xy; xy(1,:)],1,1);
p = sum(sqrt(sum(d.^2,2)));
end
