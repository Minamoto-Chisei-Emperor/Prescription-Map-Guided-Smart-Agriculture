function rec = chapter53RecordTemplate()
%CHAPTER53RECORDTEMPLATE Flat row template for Chapter 5.3 batch records.

rec = struct();

rec.status = "";
rec.errorMessage = "";

rec.fieldName = "";
rec.country = "";
rec.seed = NaN;

rec.area_m2 = NaN;
rec.area_ha = NaN;
rec.width_m = NaN;
rec.height_m = NaN;
rec.perimeter_m = NaN;
rec.shapeIndex = NaN;
rec.compactness = NaN;
rec.aspectRatio = NaN;
rec.convexityRatio = NaN;

rec.nSprayTasks = NaN;
rec.nFertTasks = NaN;
rec.nObstacles = NaN;
rec.nRefillCandidates = NaN;
rec.activeRefillCount = NaN;

rec.runtime_s = NaN;
rec.archiveSize = NaN;
rec.maxIter = NaN;
rec.popSize = NaN;

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

rec.makespanPerHa = NaN;
rec.totalPathLengthPerHa = NaN;
rec.uavPathLengthPerHa = NaN;
rec.ugvPathLengthPerHa = NaN;
rec.weightedEnergyPerHa = NaN;

rec.totalWaitingTime = NaN;
rec.conflictCount = NaN;
rec.minAirGroundDistance = NaN;

rec.sprayingCoverageRate = NaN;
rec.fertilizationCoverageRate = NaN;
rec.missedSprayingRatio = NaN;
rec.missedFertilizationRatio = NaN;
rec.repeatedSprayingRatio = NaN;
rec.repeatedFertilizationRatio = NaN;

rec.geometryValid = false;
rec.sprayObstacleOverlap = NaN;
rec.fertObstacleOverlap = NaN;
rec.spraySameTypeOverlap = NaN;
rec.fertSameTypeOverlap = NaN;
rec.refillObstacleViolations = NaN;
rec.depotObstacleViolation = NaN;

rec.finalArchiveSize = NaN;
rec.finalBestMakespan = NaN;
rec.finalBestEnergy = NaN;
rec.finalBestDrift = NaN;
end
