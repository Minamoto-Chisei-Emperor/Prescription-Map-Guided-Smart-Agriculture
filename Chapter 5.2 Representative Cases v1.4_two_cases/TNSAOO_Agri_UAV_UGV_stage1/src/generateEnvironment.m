function env = generateEnvironment(cfg)
%GENERATEENVIRONMENT Build a real-boundary synthetic agricultural scenario.
%
% v1.2 corrections:
% 1) Obstacles are generated before prescription patches.
% 2) The operable region is computed as field minus obstacles.
% 3) Same-type prescription patches are generated with non-overlap:
%    spraying patches do not overlap other spraying patches; fertilization
%    patches do not overlap other fertilization patches.
% 4) Cross-type overlap is allowed, because the same local area may require
%    both spraying and fertilization.

field = readFields2BenchmarkWKT(cfg);

env = struct();
env.field = field;
env.cfgSnapshot = cfg;

zoneOpts = struct();
zoneOpts.numVertices = cfg.env.patchNumVertices;
if isfield(cfg.env, 'patchAspectRatioRange')
    zoneOpts.aspectRatioRange = cfg.env.patchAspectRatioRange;
end

% 1) Generate obstacles first.
env.obstacles = polyshape.empty;
if cfg.env.nObstacles > 0
    obsCenters = samplePointsInPolygon(field.poly, cfg.env.nObstacles, field.bbox);
    for k = 1:cfg.env.nObstacles
        r = randomInRange(cfg.env.obstacleRadiusRange);
        if isfield(cfg.env,'useIrregularPatches') && cfg.env.useIrregularPatches
            zoneOpts.perturbation = randomInRange(cfg.env.obstaclePatchPerturbationRange);
            obs = createIrregularZone(obsCenters(k,:), r, field.poly, zoneOpts);
        else
            obs = createCircularZone(obsCenters(k,:), r, field.poly);
        end
        env.obstacles(k) = obs; %#ok<AGROW>
    end
end

% 2) Operable/croppable region excludes obstacles.
env.operablePoly = buildOperablePolygon(field.poly, env.obstacles);

% 3) Depot inside operable region.
[cx, cy] = centroid(env.operablePoly);
if isnan(cx) || ~isinterior(env.operablePoly, cx, cy)
    p = samplePointsInPolygon(env.operablePoly, 1, field.bbox);
    cx = p(1,1); cy = p(1,2);
end
env.depot = [cx, cy];

% 4) Prescription patches: same-type non-overlap; cross-type overlap allowed.
env.sprayTasks = generatePrescriptionTasks('spray', cfg.env.nSprayTasks, env.operablePoly, field.bbox, cfg, zoneOpts);
env.fertTasks  = generatePrescriptionTasks('fert',  cfg.env.nFertTasks,  env.operablePoly, field.bbox, cfg, zoneOpts);

% 5) Candidate refill stations inside operable region.
refillCenters = samplePointsInPolygon(env.operablePoly, cfg.env.nRefillCandidates, field.bbox);
env.refillStations = repmat(struct('id',[],'center',[]), cfg.env.nRefillCandidates, 1);
for k = 1:cfg.env.nRefillCandidates
    env.refillStations(k).id = k;
    env.refillStations(k).center = refillCenters(k,:);
end

% 6) Crop row direction and row segments in operable region.
if isnan(cfg.env.rowAngleDeg)
    env.rowAngleDeg = estimatePrincipalAngle(field.xy);
else
    env.rowAngleDeg = cfg.env.rowAngleDeg;
end
env.cropRows = generateRowSegmentsInPolygon(env.operablePoly, env.rowAngleDeg, cfg.env.rowSpacing, field.bbox);

% 7) Prescription maps only in the operable region.
[env.map.X, env.map.Y, env.map.inside] = buildGrid(env.operablePoly, field.bbox, cfg.env.gridResolution);
env.map.sprayDemand = demandFromTasks(env.map.X, env.map.Y, env.map.inside, env.sprayTasks);
env.map.fertDemand  = demandFromTasks(env.map.X, env.map.Y, env.map.inside, env.fertTasks);

% 8) Planning grid for lower-layer planners.
env.planningGrid = buildPlanningGrid(env, cfg);

end

function tasks = generatePrescriptionTasks(kind, nTasks, operablePoly, bbox, cfg, zoneOpts)
tasks = repmat(struct('id',[],'center',[],'zone',[],'demand',[]), nTasks, 1);
sameTypeZones = polyshape.empty;

maxAttempts = cfg.env.maxPatchGenerationAttempts;
tolArea = cfg.env.sameTypeOverlapToleranceArea;
minArea = cfg.env.minPrescriptionPatchArea;

for k = 1:nTasks
    accepted = false;
    best = struct('center',[],'zone',[],'overlap',Inf,'area',0);

    for attempt = 1:maxAttempts
        c = samplePointsInPolygon(operablePoly, 1, bbox);
        r = randomInRange(cfg.env.taskZoneRadiusRange);

        % Reduce radius if generation is difficult in a narrow field.
        if attempt > 0.65 * maxAttempts
            r = 0.75 * r;
        end
        if attempt > 0.85 * maxAttempts
            r = 0.55 * r;
        end

        if isfield(cfg.env,'useIrregularPatches') && cfg.env.useIrregularPatches
            zoneOpts.perturbation = randomInRange(cfg.env.patchPerturbationRange);
            z = createIrregularZone(c, r, operablePoly, zoneOpts);
        else
            z = createCircularZone(c, r, operablePoly);
        end

        a = area(z);
        if a < minArea
            continue;
        end

        ov = overlapArea(z, sameTypeZones);
        if ov < best.overlap
            best.center = c;
            best.zone = z;
            best.overlap = ov;
            best.area = a;
        end

        if ov <= tolArea
            accepted = true;
            break;
        end
    end

    if ~accepted
        if isempty(best.zone)
            error('Failed to generate a valid %s prescription patch %d.', kind, k);
        else
            warning('Patch %s-%d accepted with residual same-type overlap %.3f m^2.', kind, k, best.overlap);
            c = best.center;
            z = best.zone;
        end
    end

    if accepted
        % c and z are already defined in the loop.
    end

    tasks(k).id = k;
    tasks(k).center = c;
    tasks(k).zone = z;
    tasks(k).demand = 0.7 + 0.6*rand();

    sameTypeZones(k) = z; %#ok<AGROW>
end
end

function a = overlapArea(zone, zones)
a = 0;
for j = 1:numel(zones)
    if area(zones(j)) <= 1e-9
        continue;
    end
    inter = intersect(zone, zones(j));
    a = a + area(inter);
end
end

function val = randomInRange(range2)
val = range2(1) + (range2(2)-range2(1))*rand();
end

function angleDeg = estimatePrincipalAngle(xy)
xy0 = xy - mean(xy,1);
C = cov(xy0);
[V,D] = eig(C);
[~,idx] = max(diag(D));
v = V(:,idx);
angleDeg = atan2d(v(2), v(1));
angleDeg = mod(angleDeg, 180);
end

function [X,Y,inside] = buildGrid(poly, bbox, res)
xv = bbox(1):res:bbox(2);
yv = bbox(3):res:bbox(4);
[X,Y] = meshgrid(xv,yv);
insideVec = isinterior(poly, X(:), Y(:));
inside = reshape(insideVec, size(X));
end

function D = demandFromTasks(X, Y, inside, tasks)
D = zeros(size(X));
for k = 1:numel(tasks)
    c = tasks(k).center;
    sigma = 18;
    D = D + tasks(k).demand * exp(-((X-c(1)).^2 + (Y-c(2)).^2)/(2*sigma^2));
end
D(~inside) = NaN;
finiteVals = D(isfinite(D));
if ~isempty(finiteVals) && max(finiteVals) > 0
    D = D ./ max(finiteVals);
end
end
