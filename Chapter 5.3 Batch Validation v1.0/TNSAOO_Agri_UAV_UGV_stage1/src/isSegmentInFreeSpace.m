function free = isSegmentInFreeSpace(p1, p2, env, cfg)
%ISSEGMENTINFREESPACE Check whether a straight segment lies in free space.

if nargin < 4 || ~isfield(cfg, 'planner') || ~isfield(cfg.planner, 'lineCheckResolution')
    step = 1.0;
else
    step = cfg.planner.lineCheckResolution;
end

p1 = p1(:).';
p2 = p2(:).';

L = norm(p2 - p1);
n = max(2, ceil(L / max(step, eps)) + 1);
t = linspace(0, 1, n).';
xy = p1 + t .* (p2 - p1);

if isfield(env, 'operablePoly')
    insideFree = isinterior(env.operablePoly, xy(:,1), xy(:,2));
else
    insideFree = isinterior(env.field.poly, xy(:,1), xy(:,2));
    for k = 1:numel(env.obstacles)
        insideFree = insideFree & ~isinterior(env.obstacles(k), xy(:,1), xy(:,2));
    end
end

free = all(insideFree);
end
