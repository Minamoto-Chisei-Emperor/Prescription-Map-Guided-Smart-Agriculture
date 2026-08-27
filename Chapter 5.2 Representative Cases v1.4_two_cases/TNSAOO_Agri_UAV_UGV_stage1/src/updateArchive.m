function archive = updateArchive(oldArchive, pop, cfg)
%UPDATEARCHIVE Maintain external Pareto archive.

if isempty(oldArchive)
    combined = pop(:);
else
    combined = [oldArchive(:); pop(:)];
end

% Remove exact duplicates by rounded objective and position signature.
combined = removeDuplicates(combined);

fronts = nonDominatedSort(combined);
if isempty(fronts)
    archive = combined([]);
    return;
end

rank1 = fronts{1};
archive = combined(rank1);

% If too many, prune by crowding distance.
if numel(archive) > cfg.alg.archiveSize
    idx = 1:numel(archive);
    d = crowdingDistance(archive, idx);
    [~, order] = sort(d, 'descend');
    archive = archive(order(1:cfg.alg.archiveSize));
end

% Store crowding.
if ~isempty(archive)
    d = crowdingDistance(archive, 1:numel(archive));
    for i = 1:numel(archive)
        archive(i).rank = 1;
        archive(i).crowding = d(i);
    end
end
end

function out = removeDuplicates(in)
if numel(in) <= 1
    out = in;
    return;
end
keys = strings(numel(in),1);
for i = 1:numel(in)
    keys(i) = sprintf('%.4f_', [in(i).objectives, in(i).violation, in(i).position]);
end
[~, ia] = unique(keys, 'stable');
out = in(ia);
end
