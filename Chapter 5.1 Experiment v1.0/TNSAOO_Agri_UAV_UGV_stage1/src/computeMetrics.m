function metrics = computeMetrics(uavPlan, ugvPlan, conflict, objectiveMetrics, cfg)
%COMPUTEMETRICS Collect auxiliary metrics for reporting.

metrics = objectiveMetrics;
metrics.uavPathLength = uavPlan.length;
metrics.ugvPathLength = ugvPlan.length;
metrics.totalPathLength = uavPlan.length + ugvPlan.length;
metrics.uavEnergy = uavPlan.energy;
metrics.ugvEnergy = ugvPlan.energy;
metrics.totalEnergy = uavPlan.energy + ugvPlan.energy;
metrics.totalWaitingTime = conflict.waitingTime;
metrics.conflictCount = conflict.conflictCount;
metrics.minAirGroundDistance = conflict.minDistance;
metrics.sprayingCoverageRate = uavPlan.coverageRate;
metrics.fertilizationCoverageRate = ugvPlan.coverageRate;
metrics.repeatedSprayingRatio = uavPlan.repeatRatio;
metrics.repeatedFertilizationRatio = ugvPlan.repeatRatio;
metrics.missedSprayingRatio = uavPlan.missedRatio;
metrics.missedFertilizationRatio = ugvPlan.missedRatio;
metrics.uavEnergyUtilization = uavPlan.energy / cfg.uav.maxEnergy;
metrics.ugvEnergyUtilization = ugvPlan.energy / cfg.ugv.maxEnergy;
end
