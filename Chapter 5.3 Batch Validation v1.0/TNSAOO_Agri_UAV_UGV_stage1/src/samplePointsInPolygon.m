function pts = samplePointsInPolygon(poly, n, bbox)
%SAMPLEPOINTSINPOLYGON Rejection sample points inside a polyshape.

pts = zeros(n,2);
count = 0;
tries = 0;
maxTries = max(10000, n*2000);

while count < n && tries < maxTries
    tries = tries + 1;
    x = bbox(1) + rand()*(bbox(2)-bbox(1));
    y = bbox(3) + rand()*(bbox(4)-bbox(3));
    if isinterior(poly, x, y)
        count = count + 1;
        pts(count,:) = [x,y];
    end
end

if count < n
    error('Failed to sample enough points inside polygon. Sampled %d of %d.', count, n);
end
end
