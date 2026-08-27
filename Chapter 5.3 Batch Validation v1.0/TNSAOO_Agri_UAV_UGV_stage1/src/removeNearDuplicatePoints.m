function path = removeNearDuplicatePoints(path)
%REMOVENEARDUPLICATEPOINTS Remove consecutive duplicate or near-duplicate points.

if isempty(path) || size(path,1) <= 1
    return;
end

keep = true(size(path,1),1);
for i = 2:size(path,1)
    if norm(path(i,:) - path(i-1,:)) < 1e-8
        keep(i) = false;
    end
end
path = path(keep,:);
end
