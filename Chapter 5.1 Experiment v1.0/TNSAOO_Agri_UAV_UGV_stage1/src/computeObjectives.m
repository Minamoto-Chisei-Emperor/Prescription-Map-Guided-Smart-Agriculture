function [objectives, metrics] = computeObjectives(uavPlan, ugvPlan, conflict, cfg)
%COMPUTEOBJECTIVES Calculate three core objectives.

uavTime = uavPlan.time;
ugvTime = ugvPlan.time + conflict.waitingTime;

makespan = max(uavTime, ugvTime);
weightedEnergy = cfg.obj.uavEnergyWeight*uavPlan.energy + cfg.obj.ugvEnergyWeight*ugvPlan.energy;
driftPenalty = uavPlan.driftPenalty;

objectives = [makespan, weightedEnergy, driftPenalty];

metrics = struct();
metrics.uavTime = uavTime;
metrics.ugvTime = ugvTime;
metrics.makespan = makespan;
metrics.weightedEnergy = weightedEnergy;
metrics.driftPenalty = driftPenalty;
end
