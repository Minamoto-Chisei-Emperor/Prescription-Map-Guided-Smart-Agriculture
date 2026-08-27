function traj = trajectoryFromPath(path, speed, dt)
%TRAJECTORYFROMPATH Create a sampled trajectory from a 2-D path.
% This version avoids duplicated time stamps, which would break interp1.

if isempty(path)
    traj.time = 0;
    traj.pos = [0, 0];
    return;
end

if size(path,1) < 2
    traj.time = 0;
    traj.pos = path(1,:);
    return;
end

times = 0;
positions = path(1,:);
tNow = 0;

for i = 1:size(path,1)-1
    p0 = path(i,:);
    p1 = path(i+1,:);
    segLen = norm(p1-p0);

    if segLen < eps
        continue;
    end

    segTime = segLen / speed;
    nSteps = max(2, ceil(segTime/dt)+1);

    localT = linspace(0, segTime, nSteps)';
    alpha = localT / segTime;
    segPts = p0 + alpha .* (p1-p0);

    % The first sample of every segment equals the previous segment's last
    % sample, so remove it to guarantee strictly increasing time stamps.
    localT = localT(2:end);
    segPts = segPts(2:end,:);

    times = [times; tNow + localT]; %#ok<AGROW>
    positions = [positions; segPts]; %#ok<AGROW>

    tNow = tNow + segTime;
end

% Extra safety: remove any accidental duplicate timestamps.
[tUnique, ia] = unique(times, 'stable');
traj.time = tUnique;
traj.pos = positions(ia,:);
end
