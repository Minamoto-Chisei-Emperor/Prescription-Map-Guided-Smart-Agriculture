function rec = batchRecordTemplate()
%BATCHRECORDTEMPLATE Standard field layout for batch experiment records.
% v1.4.2:
% Text fields are stored as string scalars, and numeric fields are scalar
% doubles. This makes struct2table(...,'AsArray',true) stable for both
% one-record and multi-record batches.

rec = struct();

rec.status = "";
rec.errorMessage = "";
rec.fieldName = "";
rec.country = "";
rec.seed = NaN;
rec.area_m2 = NaN;
rec.width_m = NaN;
rec.height_m = NaN;
rec.runtime_s = NaN;
rec.archiveSize = NaN;

rec.makespan = NaN;
rec.weightedEnergy = NaN;
rec.driftPenalty = NaN;
rec.violation = NaN;

rec.uavTime = NaN;
rec.ugvTime = NaN;
rec.uavPathLength = NaN;
rec.ugvPathLength = NaN;
rec.totalPathLength = NaN;
rec.uavEnergy = NaN;
rec.ugvEnergy = NaN;
rec.totalEnergy = NaN;
rec.totalWaitingTime = NaN;
rec.conflictCount = NaN;
rec.minAirGroundDistance = NaN;
rec.sprayingCoverageRate = NaN;
rec.fertilizationCoverageRate = NaN;
rec.missedSprayingRatio = NaN;
rec.missedFertilizationRatio = NaN;
rec.uavEnergyUtilization = NaN;
rec.ugvEnergyUtilization = NaN;

rec.uavSeq = "";
rec.ugvSeq = "";
rec.activeRefillIds = "";
end
