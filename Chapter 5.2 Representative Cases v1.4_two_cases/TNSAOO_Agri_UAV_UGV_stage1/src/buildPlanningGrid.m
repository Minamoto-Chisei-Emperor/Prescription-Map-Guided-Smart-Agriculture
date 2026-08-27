function grid = buildPlanningGrid(env, cfg)
%BUILDPLANNINGGRID Build an obstacle-free grid for lower-layer planning.

if isfield(cfg, 'planner') && isfield(cfg.planner, 'gridResolution')
    res = cfg.planner.gridResolution;
else
    res = cfg.env.gridResolution;
end

bbox = env.field.bbox;
xv = bbox(1):res:bbox(2);
yv = bbox(3):res:bbox(4);
[X,Y] = meshgrid(xv, yv);

if isfield(env, 'operablePoly')
    freeVec = isinterior(env.operablePoly, X(:), Y(:));
else
    freeVec = isinterior(env.field.poly, X(:), Y(:));
end
free = reshape(freeVec, size(X));

nNodes = numel(free);
if isfield(cfg, 'planner') && isfield(cfg.planner, 'maxGridNodesWarning')
    if nNodes > cfg.planner.maxGridNodesWarning
        warning('Planning grid contains %d nodes. Runtime may be high.', nNodes);
    end
end

grid = struct();
grid.xv = xv;
grid.yv = yv;
grid.X = X;
grid.Y = Y;
grid.free = free;
grid.resolution = res;
end
