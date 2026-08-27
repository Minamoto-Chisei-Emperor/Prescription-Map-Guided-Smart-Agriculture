function dist = crowdingDistance(pop, idx)
%CROWDINGDISTANCE Calculate crowding distance for selected indices.

m = numel(pop(1).objectives);
n = numel(idx);
dist = zeros(n,1);

if n <= 2
    dist(:) = Inf;
    return;
end

obj = reshape([pop(idx).objectives], m, []).';

for j = 1:m
    [vals, order] = sort(obj(:,j));
    dist(order(1)) = Inf;
    dist(order(end)) = Inf;

    range = vals(end) - vals(1);
    if range < eps
        continue;
    end

    for k = 2:n-1
        dist(order(k)) = dist(order(k)) + ...
            (vals(k+1) - vals(k-1)) / range;
    end
end
end
