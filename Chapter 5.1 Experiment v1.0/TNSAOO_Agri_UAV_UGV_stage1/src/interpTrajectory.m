function pos = interpTrajectory(traj, tGrid)
%INTERPTRAJECTORY Linear interpolation of trajectory positions.
% This version is robust to accidental duplicated timestamps.

if isempty(traj.time) || isempty(traj.pos)
    pos = zeros(numel(tGrid), 2);
    return;
end

[tUnique, ia] = unique(traj.time(:), 'stable');
pUnique = traj.pos(ia,:);

if numel(tUnique) == 1
    pos = repmat(pUnique(1,:), numel(tGrid), 1);
    return;
end

x = interp1(tUnique, pUnique(:,1), tGrid, 'linear', 'extrap');
y = interp1(tUnique, pUnique(:,2), tGrid, 'linear', 'extrap');
pos = [x(:), y(:)];
end
