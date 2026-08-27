function env = generateEnvironment(cfg)
%GENERATEENVIRONMENT Build a real-boundary synthetic agricultural scenario.

field = readFields2BenchmarkWKT(cfg);

env = struct();
env.field = field;
env.cfgSnapshot = cfg;

% Safe depot: polygon centroid, fallback to a sampled interior point.
[cx, cy] = centroid(field.poly);
if isnan(cx) || ~isinterior(field.poly, cx, cy)
    p = samplePointsInPolygon(field.poly, 1, field.bbox);
    cx = p(1,1); cy = p(1,2);
end
env.depot = [cx, cy];

% Synthetic spraying and fertilization task nodes.
sprayCenters = samplePointsInPolygon(field.poly, cfg.env.nSprayTasks, field.bbox);
fertCenters  = samplePointsInPolygon(field.poly, cfg.env.nFertTasks,  field.bbox);
refillCenters = samplePointsInPolygon(field.poly, cfg.env.nRefillCandidates, field.bbox);

zoneOpts = struct();
zoneOpts.numVertices = cfg.env.patchNumVertices;
if isfield(cfg.env, 'patchAspectRatioRange')
    zoneOpts.aspectRatioRange = cfg.env.patchAspectRatioRange;
end

env.sprayTasks = repmat(struct('id',[],'center',[],'zone',[],'demand',[]), cfg.env.nSprayTasks, 1);
for k = 1:cfg.env.nSprayTasks
    r = randomInRange(cfg.env.taskZoneRadiusRange);
    if isfield(cfg.env,'useIrregularPatches') && cfg.env.useIrregularPatches
        zoneOpts.perturbation = randomInRange(cfg.env.patchPerturbationRange);
        zone = createIrregularZone(sprayCenters(k,:), r, field.poly, zoneOpts);
    else
        zone = createCircularZone(sprayCenters(k,:), r, field.poly);
    end
    env.sprayTasks(k).id = k;
    env.sprayTasks(k).center = sprayCenters(k,:);
    env.sprayTasks(k).zone = zone;
    env.sprayTasks(k).demand = 0.7 + 0.6*rand();
end

env.fertTasks = repmat(struct('id',[],'center',[],'zone',[],'demand',[]), cfg.env.nFertTasks, 1);
for k = 1:cfg.env.nFertTasks
    r = randomInRange(cfg.env.taskZoneRadiusRange);
    if isfield(cfg.env,'useIrregularPatches') && cfg.env.useIrregularPatches
        zoneOpts.perturbation = randomInRange(cfg.env.patchPerturbationRange);
        zone = createIrregularZone(fertCenters(k,:), r, field.poly, zoneOpts);
    else
        zone = createCircularZone(fertCenters(k,:), r, field.poly);
    end
    env.fertTasks(k).id = k;
    env.fertTasks(k).center = fertCenters(k,:);
    env.fertTasks(k).zone = zone;
    env.fertTasks(k).demand = 0.7 + 0.6*rand();
end

env.refillStations = repmat(struct('id',[],'center',[]), cfg.env.nRefillCandidates, 1);
for k = 1:cfg.env.nRefillCandidates
    env.refillStations(k).id = k;
    env.refillStations(k).center = refillCenters(k,:);
end

% Synthetic obstacles.
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

% Crop row direction.
if isnan(cfg.env.rowAngleDeg)
    env.rowAngleDeg = estimatePrincipalAngle(field.xy);
else
    env.rowAngleDeg = cfg.env.rowAngleDeg;
end

env.cropRows = generateRowSegmentsInPolygon(field.poly, env.rowAngleDeg, cfg.env.rowSpacing, field.bbox);

% Simple prescription maps for visualization and later guidance.
[env.map.X, env.map.Y, env.map.inside] = buildGrid(field.poly, field.bbox, cfg.env.gridResolution);
env.map.sprayDemand = demandFromTasks(env.map.X, env.map.Y, env.map.inside, env.sprayTasks);
env.map.fertDemand  = demandFromTasks(env.map.X, env.map.Y, env.map.inside, env.fertTasks);

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
