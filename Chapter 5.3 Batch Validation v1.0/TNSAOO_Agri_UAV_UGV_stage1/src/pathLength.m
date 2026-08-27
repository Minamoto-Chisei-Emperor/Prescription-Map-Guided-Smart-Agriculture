function len = pathLength(path)
%PATHLENGTH Total Euclidean length of a 2-D path.

if isempty(path) || size(path,1) < 2
    len = 0;
else
    d = diff(path,1,1);
    len = sum(sqrt(sum(d.^2,2)));
end
end
