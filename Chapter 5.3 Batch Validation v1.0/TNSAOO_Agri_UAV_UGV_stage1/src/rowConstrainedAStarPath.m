function path = rowConstrainedAStarPath(startPt, goalPt, env, cfg)
%ROWCONSTRAINEDASTARPATH Row-biased obstacle-free path for UGV transfers.
%
% This is a row-constrained grid A* transfer planner. It biases motion along
% the estimated crop-row direction while avoiding obstacle regions. It is a
% high-precision stage-1 replacement for straight-line transfer, but still a
% simplified proxy for a full continuous-state Hybrid A* with vehicle
% kinematics.

startPt = startPt(:).';
goalPt = goalPt(:).';

raw = gridAStarPath(startPt, goalPt, env, cfg, 'ugv');

if isfield(cfg.planner, 'smoothUGVPath') && cfg.planner.smoothUGVPath
    raw = smoothPathLineOfSight(raw, env, cfg);
end

path = [startPt; raw; goalPt];
path = removeNearDuplicatePoints(path);
end
