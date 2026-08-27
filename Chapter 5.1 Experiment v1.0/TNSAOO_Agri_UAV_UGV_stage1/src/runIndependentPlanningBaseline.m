function [best, archive, history] = runIndependentPlanningBaseline(env, cfg)
%RUNINDEPENDENTPLANNINGBASELINE Deterministic no-optimizer baseline.
%
% This baseline fixes the UAV and UGV task orders as their natural task
% indices and activates the refill station nearest to the depot. It still
% uses the same lower-layer path planning and objective calculation.
%
% It should be interpreted as "without upper-layer collaborative scheduling
% optimization", not as a sophisticated independent planner.

nU = numel(env.sprayTasks);
nG = numel(env.fertTasks);
nR = numel(env.refillStations);

uGenes = linspace(-1, 1, max(nU,1));
gGenes = linspace(-1, 1, max(nG,1));

rGenes = -10 * ones(1, nR);
if nR > 0
    refillCenters = reshape([env.refillStations.center], 2, []).';
    d = sqrt(sum((refillCenters - env.depot).^2, 2));
    [~, nearestId] = min(d);
    rGenes(nearestId) = 10;
end

position = [uGenes(1:nU), gGenes(1:nG), rGenes];

ind = struct();
ind.position = position;
ind.decoded = decodeSolution(position, env, cfg);
ind.objectives = [];
ind.violation = [];
ind.rank = [];
ind.crowding = [];
ind.details = [];
ind.metrics = [];

best = evaluateSolution(ind, env, cfg);
archive = best;
archive.rank = 1;
archive.crowding = Inf;

history = struct();
history.bestMakespan = best.objectives(1);
history.bestEnergy = best.objectives(2);
history.bestDrift = best.objectives(3);
history.archiveSize = 1;
end
