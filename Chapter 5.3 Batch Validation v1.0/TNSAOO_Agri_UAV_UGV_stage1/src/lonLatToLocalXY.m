function [x, y, origin] = lonLatToLocalXY(lon, lat)
%LONLATTOLocalXY Convert lon/lat degrees to local meter coordinates.
% Equirectangular approximation is accurate enough for small agricultural
% parcels.

R = 6371000; % Earth radius, m
lon0 = mean(lon(:), 'omitnan');
lat0 = mean(lat(:), 'omitnan');

x = deg2rad(lon - lon0) * R * cosd(lat0);
y = deg2rad(lat - lat0) * R;

origin = struct('lon0', lon0, 'lat0', lat0, 'method', 'local_equirectangular');
end
