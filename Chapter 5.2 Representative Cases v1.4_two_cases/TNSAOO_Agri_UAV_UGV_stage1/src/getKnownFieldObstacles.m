function knownObs = getKnownFieldObstacles(field, cfg)
%GETKNOWNFIELDOBSTACLES Return manually defined non-croppable patches.
%
% Some Fields2Benchmark examples contain visible non-croppable objects in
% the satellite image, such as a tree/woodland patch inside the field. The
% WKT boundary may not encode such internal objects as holes. For Chapter
% 5.2, ee_field_9 is given a fixed known obstacle corresponding to the
% visible tree patch highlighted in the satellite image.

knownObs = polyshape.empty;

if ~isfield(cfg.env, 'includeKnownFieldObstacles') || ~cfg.env.includeKnownFieldObstacles
    return;
end

if strcmpi(field.name, 'ee_field_9.wkt')
    % Local-coordinate polygon approximating the internal tree/woodland
    % patch visible in the satellite image. The coordinates are in the same
    % local XY system produced by lonLatToLocalXY for ee_field_9.wkt.
    %
    % This obstacle covers the lower-left internal tree patch, preventing
    % spraying/fertilization patches and UGV path segments from being placed
    % in that non-croppable region.
    x = [-101.0, -100.3, -87.2, -80.3, -70.5, -57.3, -43.8, -26.3, ...
          -7.4,  -2.3,   0.1,   1.1,   2.2,   7.4,   9.8,   9.2, ...
           8.0,   6.5,   4.4,   1.9,  -3.0, -17.1, -52.6, -76.1, ...
         -82.3, -82.9, -83.6, -86.2, -88.7, -90.5, -92.4, -94.4, ...
         -97.7, -99.2, -100.7, -101.0];

    y = [-111.5, -113.3, -116.0, -117.7, -118.9, -119.6, -120.5, -123.0, ...
         -124.9, -124.2, -122.3, -118.9, -111.3,  -74.5,  -62.5,  -57.3, ...
          -54.6,  -52.8,  -51.1,  -49.4,  -47.8,  -45.9,  -44.5,  -43.6, ...
          -43.8,  -47.0,  -53.4,  -68.0,  -83.0,  -90.3,  -94.3,  -97.7, ...
         -102.7, -104.7, -106.8, -111.5];

    obs = polyshape(x, y, 'Simplify', true);
    obs = intersect(obs, field.poly);
    obs = rmholes(obs);

    if area(obs) > 1e-6
        knownObs(1) = obs;
    end
end
end
