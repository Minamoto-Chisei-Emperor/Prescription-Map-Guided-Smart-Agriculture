function plan = planUAVPath(env, uavSeq, refillActive, cfg)
%PLANUAVPATH Simplified UAV spraying coverage path.
% Current stage: coverage strips inside each spraying task zone plus
% straight-line transfers between zones/refill stations. It is not yet the
% full prescription-map-guided adaptive Theta*.

current = env.depot;
path = current;
stripTotal = 0;
sprayArea = 0;
coveredAreaApprox = 0;
turnCount = 0;

activeRefs = find(refillActive);
distanceSinceRefill = 0;

for idx = 1:numel(uavSeq)
    task = env.sprayTasks(uavSeq(idx));

    % Insert nearest active refill if simplified segment range is exceeded.
    distToTask = norm(task.center-current);
    if distanceSinceRefill + distToTask > cfg.uav.maxSegmentDistance && ~isempty(activeRefs)
        refillPts = reshape([env.refillStations(activeRefs).center], 2, []).';
        [~, j] = min(vecnorm(refillPts-current, 2, 2));
        refillPoint = refillPts(j,:);
        path = appendPoint(path, refillPoint);
        current = refillPoint;
        distanceSinceRefill = 0;
    end

    [zonePath, stripLen, turns, zoneArea] = bestCoverageStrips(task.zone, current, cfg.uav.sprayWidth, cfg.uav.overlapRate, cfg.uav.candidateAnglesDeg);
    if ~isempty(zonePath)
        path = appendPoint(path, zonePath(1,:));
        path = [path; zonePath]; %#ok<AGROW>
        current = zonePath(end,:);
        stripTotal = stripTotal + stripLen;
        turnCount = turnCount + turns;
        sprayArea = sprayArea + zoneArea;
        coveredAreaApprox = coveredAreaApprox + min(zoneArea, stripLen * cfg.uav.sprayWidth * (1-cfg.uav.overlapRate));
        distanceSinceRefill = distanceSinceRefill + distToTask + stripLen;
    end
end

path = appendPoint(path, env.depot);

len = pathLength(path);
time = len / cfg.uav.speed;
energy = len * cfg.uav.energyPerMeter + sprayArea * cfg.uav.energyPerArea;
coverageRate = min(0.99, coveredAreaApprox / max(sprayArea, eps));
repeatRatio = max(0, (coveredAreaApprox - sprayArea) / max(sprayArea, eps));
missedRatio = max(0, 1 - coverageRate);

driftPenalty = cfg.uav.driftBase * time * ...
    (1 + cfg.uav.driftHeightCoeff*cfg.uav.flightHeight + cfg.uav.driftSpeedCoeff*cfg.uav.speed);

plan = struct();
plan.path = path;
plan.length = len;
plan.time = time;
plan.energy = energy;
plan.coverageRate = coverageRate;
plan.repeatRatio = repeatRatio;
plan.missedRatio = missedRatio;
plan.driftPenalty = driftPenalty;
plan.turnCount = turnCount;
plan.sprayArea = sprayArea;
plan.note = 'Stage-1 simplified UAV coverage strips; no adaptive Theta* yet.';
end

function [zonePath, stripLen, turns, zoneArea] = bestCoverageStrips(zone, current, width, overlap, candidateAngles)
bestCost = Inf;
zonePath = [];
stripLen = 0;
turns = 0;
zoneArea = area(zone);

for a = candidateAngles
    cand = generateCoverageStripsInPolygon(zone, a, width*(1-overlap));
    if isempty(cand)
        continue;
    end
    cLen = pathLength(cand);
    cost = norm(cand(1,:)-current) + cLen + 0.2*numel(cand);
    if cost < bestCost
        bestCost = cost;
        zonePath = cand;
        stripLen = cLen;
        turns = max(0, size(cand,1)-2);
    end
end
end

function path = appendPoint(path, pt)
if isempty(path)
    path = pt;
elseif norm(path(end,:) - pt) > 1e-9
    path = [path; pt]; %#ok<AGROW>
end
end
