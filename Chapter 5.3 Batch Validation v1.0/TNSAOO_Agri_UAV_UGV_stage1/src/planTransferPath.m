function path = planTransferPath(startPt, goalPt, env, cfg)
%PLANTRANSFERPATH Plan an obstacle-aware transfer polyline.
%
% This is a lightweight visibility-graph planner used in the current
% simulation stage. It keeps UAV/UGV transfer segments outside obstacle
% regions. It is not a replacement for the later high-fidelity Theta*/Hybrid
% A* lower-layer planner, but it prevents the obvious problem that a vehicle
% path directly crosses obstacle regions.

startPt = startPt(:).';
goalPt = goalPt(:).';

if isSegmentInFreeSpace(startPt, goalPt, env, cfg)
    path = [startPt; goalPt];
    return;
end

margin = 3.0;
if isfield(cfg.env, 'obstacleSafetyMargin')
    margin = cfg.env.obstacleSafetyMargin;
end

nodes = [startPt; goalPt];

% Generate candidate waypoints around each obstacle.
for k = 1:numel(env.obstacles)
    obs = env.obstacles(k);
    if area(obs) <= 1e-9
        continue;
    end

    [cx, cy] = centroid(obs);
    if isnan(cx) || isnan(cy)
        continue;
    end
    c = [cx, cy];

    V = obs.Vertices;
    V = V(all(isfinite(V), 2), :);
    if isempty(V)
        continue;
    end

    d = sqrt(sum((V - c).^2, 2));
    R = max(d) + margin;

    % Circular guard points.
    angles = linspace(0, 2*pi, 13);
    angles(end) = [];
    cand1 = c + R * [cos(angles(:)), sin(angles(:))];

    % Vertex-expanded guard points.
    dir = V - c;
    dn = sqrt(sum(dir.^2, 2));
    valid = dn > 1e-9;
    dir(valid,:) = dir(valid,:) ./ dn(valid);
    cand2 = V(valid,:) + margin * dir(valid,:);

    cand = [cand1; cand2];

    for j = 1:size(cand,1)
        if isPointInFreeSpace(cand(j,:), env)
            nodes = [nodes; cand(j,:)]; %#ok<AGROW>
        end
    end
end

% Remove near-duplicate nodes.
nodes = unique(nodes, 'rows', 'stable');
n = size(nodes,1);

W = inf(n,n);
for i = 1:n
    for j = i+1:n
        if isSegmentInFreeSpace(nodes(i,:), nodes(j,:), env, cfg)
            w = norm(nodes(i,:) - nodes(j,:));
            W(i,j) = w;
            W(j,i) = w;
        end
    end
end

% Dijkstra from node 1 to node 2.
dist = inf(n,1);
prev = zeros(n,1);
visited = false(n,1);
dist(1) = 0;

for it = 1:n
    unvisited = find(~visited);
    if isempty(unvisited)
        break;
    end
    [~, pos] = min(dist(unvisited));
    u = unvisited(pos);
    if isinf(dist(u)) || u == 2
        break;
    end
    visited(u) = true;

    neigh = find(isfinite(W(u,:)));
    for v = neigh
        if visited(v), continue; end
        alt = dist(u) + W(u,v);
        if alt < dist(v)
            dist(v) = alt;
            prev(v) = u;
        end
    end
end

if isinf(dist(2))
    % Conservative fallback: keep the original segment but mark the issue in
    % the command window. This should be rare; users can increase waypoint
    % margin or lower obstacle density if it appears.
    warning('Obstacle-aware transfer path was not found. Falling back to straight segment.');
    path = [startPt; goalPt];
    return;
end

idx = 2;
seq = idx;
while idx ~= 1
    idx = prev(idx);
    if idx == 0
        warning('Invalid transfer path predecessor chain. Falling back to straight segment.');
        path = [startPt; goalPt];
        return;
    end
    seq = [idx; seq]; %#ok<AGROW>
end

path = nodes(seq,:);
end
