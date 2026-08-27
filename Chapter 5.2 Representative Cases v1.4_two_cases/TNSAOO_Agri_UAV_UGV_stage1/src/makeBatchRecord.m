function rec = makeBatchRecord(env, best, archive, cfgRun, runtime, status, errorMessage)
%MAKEBATCHRECORD Convert one successful run into a flat standardized record.

rec = batchRecordTemplate();

m = best.metrics;

rec.status = string(status);
rec.errorMessage = string(errorMessage);
rec.fieldName = string(cfgRun.data.fieldFileName);
rec.country = string(cfgRun.data.fieldFileName(1:min(2,end)));
rec.seed = cfgRun.seed;
rec.area_m2 = env.field.area;
rec.width_m = env.field.width;
rec.height_m = env.field.height;
rec.runtime_s = runtime;
rec.archiveSize = numel(archive);

rec.makespan = best.objectives(1);
rec.weightedEnergy = best.objectives(2);
rec.driftPenalty = best.objectives(3);
rec.violation = best.violation;

rec.uavTime = safeMetric(m, 'uavTime');
rec.ugvTime = safeMetric(m, 'ugvTime');
rec.uavPathLength = safeMetric(m, 'uavPathLength');
rec.ugvPathLength = safeMetric(m, 'ugvPathLength');
rec.totalPathLength = safeMetric(m, 'totalPathLength');
rec.uavEnergy = safeMetric(m, 'uavEnergy');
rec.ugvEnergy = safeMetric(m, 'ugvEnergy');
rec.totalEnergy = safeMetric(m, 'totalEnergy');
rec.totalWaitingTime = safeMetric(m, 'totalWaitingTime');
rec.conflictCount = safeMetric(m, 'conflictCount');
rec.minAirGroundDistance = safeMetric(m, 'minAirGroundDistance');
rec.sprayingCoverageRate = safeMetric(m, 'sprayingCoverageRate');
rec.fertilizationCoverageRate = safeMetric(m, 'fertilizationCoverageRate');
rec.missedSprayingRatio = safeMetric(m, 'missedSprayingRatio');
rec.missedFertilizationRatio = safeMetric(m, 'missedFertilizationRatio');
rec.uavEnergyUtilization = safeMetric(m, 'uavEnergyUtilization');
rec.ugvEnergyUtilization = safeMetric(m, 'ugvEnergyUtilization');

rec.uavSeq = string(mat2str(best.decoded.uavSeq));
rec.ugvSeq = string(mat2str(best.decoded.ugvSeq));
rec.activeRefillIds = string(mat2str(best.decoded.activeRefillIds));

rec = standardizeBatchRecord(rec);
end

function val = safeMetric(m, name)
if isfield(m, name)
    val = m.(name);
else
    val = NaN;
end
end
