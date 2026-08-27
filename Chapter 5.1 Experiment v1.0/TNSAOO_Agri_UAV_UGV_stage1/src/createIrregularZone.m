function zone = createIrregularZone(center, baseRadius, fieldPoly, opts)
%CREATEIRREGULARZONE Create an irregular prescription or obstacle patch.
%
% The generated patch is a radial-perturbation polygon clipped by the real
% field boundary. This is used for Chapter 5.1 figures so that localized
% prescription regions do not appear as ideal circular targets.
%
% Inputs:
%   center      1x2 center point [x,y]
%   baseRadius  approximate radius in meters
%   fieldPoly   real field boundary as polyshape
%   opts        optional structure:
%               .numVertices
%               .perturbation
%               .aspectRatioRange
%               .rotationDeg

if nargin < 4 || isempty(opts)
    opts = struct();
end
if ~isfield(opts, 'numVertices'),        opts.numVertices = 30; end
if ~isfield(opts, 'perturbation'),       opts.perturbation = 0.30; end
if ~isfield(opts, 'aspectRatioRange'),   opts.aspectRatioRange = [0.70, 1.35]; end
if ~isfield(opts, 'rotationDeg'),        opts.rotationDeg = 360 * rand(); end

n = max(12, round(opts.numVertices));
theta = linspace(0, 2*pi, n+1);
theta(end) = [];

% Smooth radial randomness to avoid star-like shapes.
raw = rand(1, n) - 0.5;
kernel = [1, 2, 3, 2, 1];
kernel = kernel / sum(kernel);
pad = [raw(end-2:end), raw, raw(1:3)];
smoothed = conv(pad, kernel, 'same');
smoothed = smoothed(4:end-3);
smoothed = smoothed - mean(smoothed);
if max(abs(smoothed)) > 0
    smoothed = smoothed / max(abs(smoothed));
end

amp = min(max(opts.perturbation, 0.05), 0.48);
radii = baseRadius * (1 + amp * smoothed);
radii = max(0.50 * baseRadius, radii);

aspect = opts.aspectRatioRange(1) + rand() * diff(opts.aspectRatioRange);
phi = deg2rad(opts.rotationDeg);

x0 = radii .* cos(theta);
y0 = aspect * radii .* sin(theta);
R = [cos(phi), -sin(phi); sin(phi), cos(phi)];
xy = R * [x0; y0];

x = center(1) + xy(1,:);
y = center(2) + xy(2,:);

rawPatch = polyshape(x, y, 'Simplify', true);
zone = intersect(rawPatch, fieldPoly);
zone = rmholes(zone);

% Robust fallback.
if area(zone) <= 1e-6
    zone = createCircularZone(center, baseRadius, fieldPoly);
end
end
