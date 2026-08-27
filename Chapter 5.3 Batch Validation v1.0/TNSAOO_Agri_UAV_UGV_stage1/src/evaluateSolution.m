function ind = evaluateSolution(ind, env, cfg)
%EVALUATESOLUTION Run lower-layer planners and evaluate objectives.

decoded = ind.decoded;

uavPlan = planUAVPath(env, decoded.uavSeq, decoded.refillActive, cfg);
ugvPlan = planUGVPath(env, decoded.ugvSeq, decoded.refillActive, cfg);

conflict = detectAndRepairConflicts(uavPlan.path, ugvPlan.path, cfg);

[objectives, objectiveMetrics] = computeObjectives(uavPlan, ugvPlan, conflict, cfg);
metrics = computeMetrics(uavPlan, ugvPlan, conflict, objectiveMetrics, cfg);

violation = 0;
violation = violation + max(0, uavPlan.energy - cfg.uav.maxEnergy);
violation = violation + max(0, ugvPlan.energy - cfg.ugv.maxEnergy);
violation = violation + max(0, 0.90 - uavPlan.coverageRate) * cfg.obj.coveragePenaltyWeight;
violation = violation + max(0, 0.90 - ugvPlan.coverageRate) * cfg.obj.coveragePenaltyWeight;
if ~cfg.conflict.enableRepair
    violation = violation + conflict.conflictCount * cfg.obj.conflictPenaltyWeight;
end

ind.objectives = objectives;
ind.violation = violation;
ind.metrics = metrics;
ind.details = struct('uavPlan',uavPlan,'ugvPlan',ugvPlan,'conflict',conflict);
end
