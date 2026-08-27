function out = smoothPathLineOfSight(path, env, cfg)
%SMOOTHPATHLINEOFSIGHT Greedy line-of-sight path shortening.

if size(path,1) <= 2
    out = path;
    return;
end

out = path(1,:);
i = 1;
n = size(path,1);

while i < n
    j = n;
    while j > i + 1
        if isSegmentInFreeSpace(path(i,:), path(j,:), env, cfg)
            break;
        end
        j = j - 1;
    end
    out = [out; path(j,:)]; %#ok<AGROW>
    i = j;
end

out = removeNearDuplicatePoints(out);
end
