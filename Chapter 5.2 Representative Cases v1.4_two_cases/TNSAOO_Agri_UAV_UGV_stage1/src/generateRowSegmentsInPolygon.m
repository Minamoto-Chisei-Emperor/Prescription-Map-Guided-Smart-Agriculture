function rows = generateRowSegmentsInPolygon(poly, angleDeg, spacing, bbox)
%GENERATEROWSEGMENTSINPOLYGON Generate row-like line segments inside polygon.
% This avoids requiring Mapping Toolbox line-polygon intersection functions.

v = [cosd(angleDeg), sind(angleDeg)];
n = [-v(2), v(1)];
center = [(bbox(1)+bbox(2))/2, (bbox(3)+bbox(4))/2];

diagLen = hypot(bbox(2)-bbox(1), bbox(4)-bbox(3));
tVals = linspace(-diagLen, diagLen, 600);
dVals = -diagLen:spacing:diagLen;

rows = struct('start',{},'end',{},'angleDeg',{});

for d = dVals
    pts = center + d*n + tVals(:)*v;
    inside = isinterior(poly, pts(:,1), pts(:,2));
    if ~any(inside)
        continue;
    end
    idx = find(inside);
    breaks = [1; find(diff(idx)>1)+1; numel(idx)+1];
    for b = 1:numel(breaks)-1
        group = idx(breaks(b):breaks(b+1)-1);
        if numel(group) < 3
            continue;
        end
        s = pts(group(1),:);
        e = pts(group(end),:);
        if norm(e-s) > spacing
            rows(end+1).start = s; %#ok<AGROW>
            rows(end).end = e;
            rows(end).angleDeg = angleDeg;
        end
    end
end
end
