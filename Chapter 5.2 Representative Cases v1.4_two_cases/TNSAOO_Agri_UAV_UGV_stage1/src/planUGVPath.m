function plan = planUGVPath(env, ugvSeq, refillActive, cfg)
%PLANUGVPATH Simplified row-guided UGV fertilization path with fast transfers.
%
% v1.3 fast setting:
% - Same-type prescription patch non-overlap is preserved in scenario generation.
% - Obstacles are excluded from prescription regions.
% - Transfers use the lightweight visibility-graph planner instead of the
%   slow grid-based row-constrained A* planner.
%
% This version is intended for practical figure generation in Chapter 5.2.

current = env.depot;
path = current;
fertArea = 0;
coveredAreaApprox = 0;
turnCount = 0;

activeRefs = find(refillActive);
distanceSinceRefill = 0;

for idx = 1:numel(ugvSeq)
    task = env.fertTasks(ugvSeq(idx));

    distToTask = norm(task.center-current);
    if distanceSinceRefill + distToTask > cfg.ugv.maxSegmentDistance && ~isempty(activeRefs)
        refillPts = reshape([env.refillStations(activeRefs).center], 2, []).';
        [~, j] = min(vecnorm(refillPts-current, 2, 2));
        refillPoint = refillPts(j,:);
        transfer = planTransferPath(current, refillPoint, env, cfg);
        path = appendPolyline(path, transfer);
        current = refillPoint;
        distanceSinceRefill = 0;
    end

    zonePath = generateCoverageStripsInPolygon(task.zone, env.rowAngleDeg, cfg.ugv.fertWidth);
    if ~isempty(zonePath)
        transfer = planTransferPath(current, zonePath(1,:), env, cfg);
        path = appendPolyline(path, transfer);
        path = appendPolyline(path, zonePath);
        current = zonePath(end,:);
        fArea = area(task.zone);
        len = pathLength(zonePath);
        fertArea = fertArea + fArea;
        coveredAreaApprox = coveredAreaApprox + min(fArea, len*cfg.ugv.fertWidth);
        turnCount = turnCount + max(0, size(zonePath,1)-2);
        distanceSinceRefill = distanceSinceRefill + pathLength(transfer) + len;
    end
end

transfer = planTransferPath(current, env.depot, env, cfg);
path = appendPolyline(path, transfer);

len = pathLength(path);
time = len / cfg.ugv.speed;
energy = len * cfg.ugv.energyPerMeter;

coverageRate = min(0.99, coveredAreaApprox / max(fertArea, eps));
repeatRatio = max(0, (coveredAreaApprox - fertArea) / max(fertArea, eps));
missedRatio = max(0, 1 - coverageRate);

plan = struct();
plan.path = path;
plan.length = len;
plan.time = time;
plan.energy = energy;
plan.coverageRate = coverageRate;
plan.repeatRatio = repeatRatio;
plan.missedRatio = missedRatio;
plan.turnCount = turnCount;
plan.fertArea = fertArea;
plan.note = 'Fast UGV row-guided coverage with lightweight obstacle-aware visibility transfers.';
end

function path = appendPolyline(path, polyline)
if isempty(polyline)
    return;
end
if exist('removeNearDuplicatePoints','file') == 2
    polyline = removeNearDuplicatePoints(polyline);
end
if isempty(path)
    path = polyline;
elseif norm(path(end,:) - polyline(1,:)) < 1e-8
    path = [path; polyline(2:end,:)]; %#ok<AGROW>
else
    path = [path; polyline]; %#ok<AGROW>
end
end
