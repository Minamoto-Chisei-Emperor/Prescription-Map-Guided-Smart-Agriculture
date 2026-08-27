function stripPath = generateCoverageStripsInPolygon(poly, angleDeg, spacing)
%GENERATECOVERAGESTRIPSINPOLYGON Generate boustrophedon-like strips.
% Uses point sampling along parallel lines, so it is robust and toolbox-light.

if area(poly) <= 1e-6
    stripPath = [];
    return;
end

[xv,yv] = boundary(poly);
bbox = [min(xv), max(xv), min(yv), max(yv)];
diagLen = hypot(bbox(2)-bbox(1), bbox(4)-bbox(3));
center = [(bbox(1)+bbox(2))/2, (bbox(3)+bbox(4))/2];

v = [cosd(angleDeg), sind(angleDeg)];
n = [-v(2), v(1)];

tVals = linspace(-diagLen, diagLen, 800);
dVals = -diagLen:spacing:diagLen;

segments = {};
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
        if norm(e-s) > spacing*0.5
            segments{end+1} = [s; e]; %#ok<AGROW>
        end
    end
end

if isempty(segments)
    stripPath = [];
    return;
end

stripPath = [];
reverseFlag = false;
for k = 1:numel(segments)
    seg = segments{k};
    if reverseFlag
        seg = flipud(seg);
    end
    if isempty(stripPath)
        stripPath = seg;
    else
        stripPath = [stripPath; seg]; %#ok<AGROW>
    end
    reverseFlag = ~reverseFlag;
end
end
