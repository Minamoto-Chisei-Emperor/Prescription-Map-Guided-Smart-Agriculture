function path = adaptiveThetaStarPath(startPt, goalPt, env, cfg)
%ADAPTIVETHETASTARPATH Grid-based any-angle path for UAV transfers.
%
% This function approximates the adaptive Theta* lower-layer transfer
% planner by first solving an obstacle-free grid A* problem and then applying
% greedy line-of-sight path shortening. It avoids obstacle regions and field
% exterior in the local planar coordinate system.

startPt = startPt(:).';
goalPt = goalPt(:).';

if isSegmentInFreeSpace(startPt, goalPt, env, cfg)
    path = [startPt; goalPt];
    return;
end

raw = gridAStarPath(startPt, goalPt, env, cfg, 'uav');
if isfield(cfg.planner, 'smoothUAVPath') && cfg.planner.smoothUAVPath
    smoothed = smoothPathLineOfSight(raw, env, cfg);
else
    smoothed = raw;
end

path = [startPt; smoothed; goalPt];
path = removeNearDuplicatePoints(path);
end
