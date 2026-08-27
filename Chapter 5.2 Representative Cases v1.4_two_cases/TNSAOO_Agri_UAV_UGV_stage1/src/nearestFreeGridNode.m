function [r, c] = nearestFreeGridNode(pt, grid)
%NEARESTFREEGRIDNODE Find nearest free grid cell to a point.

[~, c0] = min(abs(grid.xv - pt(1)));
[~, r0] = min(abs(grid.yv - pt(2)));

if grid.free(r0, c0)
    r = r0;
    c = c0;
    return;
end

freeIdx = find(grid.free);
if isempty(freeIdx)
    error('No free node exists in the planning grid.');
end
[rr, cc] = ind2sub(size(grid.free), freeIdx);
dx = grid.X(freeIdx) - pt(1);
dy = grid.Y(freeIdx) - pt(2);
[~, id] = min(dx.^2 + dy.^2);
r = rr(id);
c = cc(id);
end
