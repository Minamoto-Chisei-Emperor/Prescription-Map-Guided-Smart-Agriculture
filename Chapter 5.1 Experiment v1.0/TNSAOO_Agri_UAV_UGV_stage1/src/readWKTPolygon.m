function [lon, lat] = readWKTPolygon(wktPath)
%READWKTPOLYGON Minimal WKT polygon reader for Fields2Benchmark files.
% Supports typical POLYGON WKT. For MULTIPOLYGON, this stage uses all
% coordinate pairs as one boundary and should later be replaced by a full
% geometry parser if needed.

txt = fileread(wktPath);
nums = regexp(txt, '[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?', 'match');
vals = str2double(nums);
if mod(numel(vals),2) ~= 0 || numel(vals) < 6
    error('Could not parse coordinate pairs from WKT: %s', wktPath);
end

lon = vals(1:2:end);
lat = vals(2:2:end);

% Remove duplicate final point for cleaner operations; polyshape closes it.
if numel(lon) > 2 && abs(lon(1)-lon(end)) < 1e-12 && abs(lat(1)-lat(end)) < 1e-12
    lon(end) = [];
    lat(end) = [];
end
end
