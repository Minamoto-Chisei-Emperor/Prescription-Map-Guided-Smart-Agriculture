function conflict = detectAndRepairConflicts(uavPath, ugvPath, cfg)
%DETECTANDREPAIRCONFLICTS Detect horizontal air-ground conflicts.
% Stage-1 v1.3:
% - creates time-stamped UAV/UGV trajectories;
% - detects horizontal projection conflicts;
% - ignores initial co-location at the depot/base;
% - applies waiting-time repair approximation.
%
% Note:
% This is still a simplified repair module. It does not yet implement local
% replanning or continuous speed-profile optimization.

uTraj = trajectoryFromPath(uavPath, cfg.uav.speed, cfg.conflict.dt);
gTraj = trajectoryFromPath(ugvPath, cfg.ugv.speed, cfg.conflict.dt);

tEnd = min(uTraj.time(end), gTraj.time(end));
tGrid = 0:cfg.conflict.dt:tEnd;

uPos = interpTrajectory(uTraj, tGrid);
gPos = interpTrajectory(gTraj, tGrid);

dist = sqrt(sum((uPos-gPos).^2,2));
rawConflictMask = dist < cfg.conflict.safetyDistance;

% Allow initial co-location at the common base/depot.
depotApprox = uavPath(1,:);
nearDepotBoth = vecnorm(uPos - depotApprox, 2, 2) <= cfg.conflict.ignoreDepotRadius & ...
                vecnorm(gPos - depotApprox, 2, 2) <= cfg.conflict.ignoreDepotRadius;
initialWindow = tGrid(:) <= cfg.conflict.ignoreInitialTime;

allowedMask = nearDepotBoth | initialWindow;

conflictMask = rawConflictMask & ~allowedMask;

% Count conflict events, not every time step.
if any(conflictMask)
    starts = find(diff([false; conflictMask(:)]) == 1);
    conflictCount = numel(starts);
else
    conflictCount = 0;
end

waitingTime = 0;
if cfg.conflict.enableRepair && conflictCount > 0
    waitingTime = conflictCount * cfg.conflict.waitPerConflict;
end

validDist = dist(~allowedMask);
if isempty(validDist)
    effectiveMinDistance = Inf;
else
    effectiveMinDistance = min(validDist);
end

conflict = struct();
conflict.conflictCount = conflictCount;
conflict.waitingTime = waitingTime;
conflict.minDistance = effectiveMinDistance;
conflict.rawMinDistance = min(dist);
conflict.rawConflictCountApprox = sum(rawConflictMask);
conflict.uavTrajectory = uTraj;
conflict.ugvTrajectory = gTraj;
conflict.note = 'Stage-1 v1.3 conflict repair uses waiting-time approximation and ignores depot co-location.';
end
