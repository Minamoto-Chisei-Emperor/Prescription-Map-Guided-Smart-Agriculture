function rec = makeRepresentativeCaseRecord(caseId, caseName, env, best, archive, cfg, runtime)
%MAKEREPRESENTATIVECASERECORD Convert one representative case to a table row.

rec = struct();
rec.caseId = caseId;
rec.caseName = string(caseName);
rec.fieldName = string(env.field.name);
rec.country = string(env.field.name(1:min(2, numel(env.field.name))));
rec.seed = cfg.seed;
rec.area_m2 = env.field.area;
rec.width_m = env.field.width;
rec.height_m = env.field.height;
rec.shapeIndex = localShapeIndex(env.field.xy, env.field.area);
rec.nSprayTasks = numel(env.sprayTasks);
rec.nFertTasks = numel(env.fertTasks);
rec.nObstacles = numel(env.obstacles);
rec.nRefillCandidates = numel(env.refillStations);
rec.activeRefillCount = numel(best.decoded.activeRefillIds);
rec.archiveSize = numel(archive);
rec.runtime_s = runtime;

geo = validateScenarioGeometry(env, cfg);
rec.geometryValid = geo.isValid;
rec.sprayObstacleOverlap = geo.sprayObstacleOverlap;
rec.fertObstacleOverlap = geo.fertObstacleOverlap;
rec.spraySameTypeOverlap = geo.spraySameTypeOverlap;
rec.fertSameTypeOverlap = geo.fertSameTypeOverlap;
rec.refillObstacleViolations = geo.refillObstacleViolations;
rec.depotObstacleViolation = geo.depotObstacleViolation;

rec.makespan = best.objectives(1);
rec.weightedEnergy = best.objectives(2);
rec.driftPenalty = best.objectives(3);

m = best.metrics;
rec.uavPathLength = m.uavPathLength;
rec.ugvPathLength = m.ugvPathLength;
rec.totalPathLength = m.totalPathLength;
rec.uavEnergy = m.uavEnergy;
rec.ugvEnergy = m.ugvEnergy;
rec.totalEnergy = m.totalEnergy;
rec.conflictCount = m.conflictCount;
rec.totalWaitingTime = m.totalWaitingTime;
rec.minAirGroundDistance = m.minAirGroundDistance;
rec.sprayingCoverageRate = m.sprayingCoverageRate;
rec.fertilizationCoverageRate = m.fertilizationCoverageRate;
rec.missedSprayingRatio = m.missedSprayingRatio;
rec.missedFertilizationRatio = m.missedFertilizationRatio;
rec.repeatedSprayingRatio = m.repeatedSprayingRatio;
rec.repeatedFertilizationRatio = m.repeatedFertilizationRatio;
end

function si = localShapeIndex(xy, areaVal)
if size(xy,1) < 2 || areaVal <= 0
    si = NaN;
    return;
end
if norm(xy(1,:) - xy(end,:)) > 1e-9
    xy = [xy; xy(1,:)];
end
d = diff(xy,1,1);
perim = sum(sqrt(sum(d.^2,2)));
si = perim^2 / (4*pi*areaVal);
end
