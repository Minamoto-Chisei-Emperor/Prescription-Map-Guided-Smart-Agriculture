function plan = planUGVPath(env, ugvSeq, refillActive, cfg)
%PLANUGVPATH Simplified row-guided UGV fertilization path.
% Current stage: row-guided coverage strips inside each fertilization zone
% plus straight-line transfers. It is not yet full row-constrained Hybrid A*.

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
        path = appendPoint(path, refillPoint);
        current = refillPoint;
        distanceSinceRefill = 0;
    end

    zonePath = generateCoverageStripsInPolygon(task.zone, env.rowAngleDeg, cfg.ugv.fertWidth);
    if ~isempty(zonePath)
        path = appendPoint(path, zonePath(1,:));
        path = [path; zonePath]; %#ok<AGROW>
        current = zonePath(end,:);
        fArea = area(task.zone);
        len = pathLength(zonePath);
        fertArea = fertArea + fArea;
        coveredAreaApprox = coveredAreaApprox + min(fArea, len*cfg.ugv.fertWidth);
        turnCount = turnCount + max(0, size(zonePath,1)-2);
        distanceSinceRefill = distanceSinceRefill + distToTask + len;
    end
end

path = appendPoint(path, env.depot);

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
plan.note = 'Stage-1 simplified row-guided UGV coverage; no Hybrid A* yet.';
end

function path = appendPoint(path, pt)
if isempty(path)
    path = pt;
elseif norm(path(end,:) - pt) > 1e-9
    path = [path; pt]; %#ok<AGROW>
end
end
