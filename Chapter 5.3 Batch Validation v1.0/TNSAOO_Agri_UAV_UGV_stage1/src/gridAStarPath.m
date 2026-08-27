function path = gridAStarPath(startPt, goalPt, env, cfg, mode)
%GRIDASTARPATH Obstacle-free grid A* path between two points.

grid = getPlanningGrid(env, cfg);
[rs, cs] = nearestFreeGridNode(startPt, grid);
[rg, cg] = nearestFreeGridNode(goalPt, grid);

[nr, nc] = size(grid.free);

gScore = inf(nr, nc);
fScore = inf(nr, nc);
openSet = false(nr, nc);
closedSet = false(nr, nc);
prevR = zeros(nr, nc);
prevC = zeros(nr, nc);

gScore(rs, cs) = 0;
fScore(rs, cs) = heuristicCost(gridNodePoint(grid, rs, cs), goalPt);
openSet(rs, cs) = true;

dirs = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];

found = false;
maxIter = nr * nc;

for iter = 1:maxIter
    if ~any(openSet(:))
        break;
    end

    tmp = fScore;
    tmp(~openSet) = Inf;
    [bestF, linIdx] = min(tmp(:)); %#ok<ASGLU>
    if isinf(bestF)
        break;
    end

    [r, c] = ind2sub([nr, nc], linIdx);

    if r == rg && c == cg
        found = true;
        break;
    end

    openSet(r, c) = false;
    closedSet(r, c) = true;

    p = gridNodePoint(grid, r, c);

    for k = 1:size(dirs,1)
        rr = r + dirs(k,1);
        cc = c + dirs(k,2);

        if rr < 1 || rr > nr || cc < 1 || cc > nc
            continue;
        end
        if ~grid.free(rr, cc) || closedSet(rr, cc)
            continue;
        end

        q = gridNodePoint(grid, rr, cc);

        % Prevent diagonal corner cutting and obstacle crossing.
        if ~isSegmentInFreeSpace(p, q, env, cfg)
            continue;
        end

        stepCost = norm(q - p);
        if strcmpi(mode, 'ugv')
            stepCost = stepCost * rowMotionPenalty(p, q, env, cfg);
        end

        tentativeG = gScore(r,c) + stepCost;

        if tentativeG < gScore(rr,cc)
            prevR(rr,cc) = r;
            prevC(rr,cc) = c;
            gScore(rr,cc) = tentativeG;
            fScore(rr,cc) = tentativeG + heuristicCost(q, goalPt);
            openSet(rr,cc) = true;
        end
    end
end

if ~found
    warning('Grid A* path not found. Falling back to visibility planner.');
    path = planTransferPath(startPt, goalPt, env, cfg);
    return;
end

% Reconstruct path from grid nodes.
r = rg; c = cg;
path = gridNodePoint(grid, r, c);

while ~(r == rs && c == cs)
    pr = prevR(r,c);
    pc = prevC(r,c);
    if pr == 0 || pc == 0
        warning('Invalid A* predecessor chain. Falling back to visibility planner.');
        path = planTransferPath(startPt, goalPt, env, cfg);
        return;
    end
    r = pr; c = pc;
    path = [gridNodePoint(grid, r, c); path]; %#ok<AGROW>
end
end

function h = heuristicCost(p, goalPt)
h = norm(p - goalPt);
end

function penalty = rowMotionPenalty(p, q, env, cfg)
d = q - p;
if norm(d) < 1e-9
    penalty = 1;
    return;
end

moveAngle = mod(atan2d(d(2), d(1)), 180);
rowAngle = mod(env.rowAngleDeg, 180);
delta = abs(moveAngle - rowAngle);
delta = min(delta, 180 - delta);

w = 0.55;
if isfield(cfg, 'planner') && isfield(cfg.planner, 'rowDeviationWeight')
    w = cfg.planner.rowDeviationWeight;
end

penalty = 1 + w * (sind(delta)^2);
end
