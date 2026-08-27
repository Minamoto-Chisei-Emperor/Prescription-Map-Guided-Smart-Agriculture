function best = selectCompromiseSolution(archive)
%SELECTCOMPROMISESOLUTION Select compromise solution by normalized distance to utopia.

if isempty(archive)
    error('Archive is empty.');
end

obj = reshape([archive.objectives], 3, []).';
mins = min(obj, [], 1);
maxs = max(obj, [], 1);
normObj = (obj - mins) ./ max(maxs - mins, eps);

dist = sqrt(sum(normObj.^2, 2));
[~, idx] = min(dist);
best = archive(idx);
end
