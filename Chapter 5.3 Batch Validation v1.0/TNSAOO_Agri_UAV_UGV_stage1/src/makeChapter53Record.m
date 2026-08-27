function rec = makeChapter53Record(env, best, archive, cfg, runtime, history, geo, status, errorMessage)
%MAKECHAPTER53RECORD Convert a successful run into a Chapter 5.3 row.

rec = chapter53RecordTemplate();

rec.status = string(status);
rec.errorMessage = string(errorMessage);

rec.fieldName = string(env.field.name);
rec.country = string(lower(env.field.name(1:min(2,numel(env.field.name)))));
rec.seed = cfg.seed;

metricsShape = computeFieldShapeMetricsFromPoly(env.field.poly, env.field.xy);

rec.area_m2 = env.field.area;
rec.area_ha = env.field.area / 10000;
rec.width_m = env.field.width;
rec.height_m = env.field.height;
rec.perimeter_m = metricsShape.perimeter_m;
rec.shapeIndex = metricsShape.shapeIndex;
rec.compactness = metricsShape.compactness;
rec.aspectRatio = metricsShape.aspectRatio;
rec.convexityRatio = metricsShape.convexityRatio;

rec.nSprayTasks = numel(env.sprayTasks);
rec.nFertTasks = numel(env.fertTasks);
rec.nObstacles = numel(env.obstacles);
rec.nRefillCandidates = numel(env.refillStations);
rec.activeRefillCount = numel(best.decoded.activeRefillIds);

rec.runtime_s = runtime;
rec.archiveSize = numel(archive);
rec.maxIter = cfg.alg.maxIter;
rec.popSize = cfg.alg.popSize;

rec.makespan = best.objectives(1);
rec.weightedEnergy = best.objectives(2);
rec.driftPenalty = best.objectives(3);
rec.violation = best.violation;

m = best.metrics;
rec.uavTime = safeMetric(m, 'uavTime');
rec.ugvTime = safeMetric(m, 'ugvTime');
rec.uavPathLength = safeMetric(m, 'uavPathLength');
rec.ugvPathLength = safeMetric(m, 'ugvPathLength');
rec.totalPathLength = safeMetric(m, 'totalPathLength');
rec.uavEnergy = safeMetric(m, 'uavEnergy');
rec.ugvEnergy = safeMetric(m, 'ugvEnergy');
rec.totalEnergy = safeMetric(m, 'totalEnergy');

rec.makespanPerHa = rec.makespan / max(rec.area_ha, eps);
rec.totalPathLengthPerHa = rec.totalPathLength / max(rec.area_ha, eps);
rec.uavPathLengthPerHa = rec.uavPathLength / max(rec.area_ha, eps);
rec.ugvPathLengthPerHa = rec.ugvPathLength / max(rec.area_ha, eps);
rec.weightedEnergyPerHa = rec.weightedEnergy / max(rec.area_ha, eps);

rec.totalWaitingTime = safeMetric(m, 'totalWaitingTime');
rec.conflictCount = safeMetric(m, 'conflictCount');
rec.minAirGroundDistance = safeMetric(m, 'minAirGroundDistance');

rec.sprayingCoverageRate = safeMetric(m, 'sprayingCoverageRate');
rec.fertilizationCoverageRate = safeMetric(m, 'fertilizationCoverageRate');
rec.missedSprayingRatio = safeMetric(m, 'missedSprayingRatio');
rec.missedFertilizationRatio = safeMetric(m, 'missedFertilizationRatio');
rec.repeatedSprayingRatio = safeMetric(m, 'repeatedSprayingRatio');
rec.repeatedFertilizationRatio = safeMetric(m, 'repeatedFertilizationRatio');

if nargin >= 7 && ~isempty(geo)
    rec.geometryValid = logical(geo.isValid);
    rec.sprayObstacleOverlap = geo.sprayObstacleOverlap;
    rec.fertObstacleOverlap = geo.fertObstacleOverlap;
    rec.spraySameTypeOverlap = geo.spraySameTypeOverlap;
    rec.fertSameTypeOverlap = geo.fertSameTypeOverlap;
    rec.refillObstacleViolations = geo.refillObstacleViolations;
    rec.depotObstacleViolation = geo.depotObstacleViolation;
end

if nargin >= 6 && ~isempty(history)
    rec.finalArchiveSize = numel(archive);
    rec.finalBestMakespan = lastFinite(history.bestMakespan);
    rec.finalBestEnergy = lastFinite(history.bestEnergy);
    rec.finalBestDrift = lastFinite(history.bestDrift);
end
end

function val = safeMetric(m, name)
if isfield(m, name)
    val = m.(name);
else
    val = NaN;
end
end

function val = lastFinite(x)
x = x(:);
x = x(isfinite(x));
if isempty(x)
    val = NaN;
else
    val = x(end);
end
end
