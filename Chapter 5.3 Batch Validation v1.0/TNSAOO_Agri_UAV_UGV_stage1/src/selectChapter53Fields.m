function [selectedFields, candidateTable] = selectChapter53Fields(cfg, dataDir)
%SELECTCHAPTER53FIELDS Select fields for batch validation.
%
% If cfg.chapter53.fieldFiles is non-empty, those fields are used directly.
% Otherwise, fields are selected from Fields2Benchmark in a stratified manner
% across country, area, and shape complexity. The full candidate metadata is
% saved so selection can be audited or adjusted later.

if ~exist(cfg.paths.wktDir, 'dir')
    if exist(cfg.paths.wktZip, 'file')
        fprintf('Unzipping WKT data from %s ...\n', cfg.paths.wktZip);
        unzip(cfg.paths.wktZip, cfg.paths.dataDir);
    else
        error('WKT data not found: %s', cfg.paths.wktZip);
    end
end

listing = dir(fullfile(cfg.paths.wktDir, '*.wkt'));
if isempty(listing)
    error('No WKT files found in %s', cfg.paths.wktDir);
end

fprintf('Reading field metadata for selection...\n');

rows = repmat(struct( ...
    'fileName',"", 'country',"", 'area_m2',NaN, 'area_ha',NaN, ...
    'width_m',NaN, 'height_m',NaN, 'aspectRatio',NaN, ...
    'perimeter_m',NaN, 'shapeIndex',NaN, 'compactness',NaN, ...
    'convexityRatio',NaN, 'valid',false, 'errorMessage',""), numel(listing), 1);

oldWarn = warning('off','all');
cleanupObj = onCleanup(@() warning(oldWarn)); %#ok<NASGU>

for i = 1:numel(listing)
    fn = listing(i).name;
    rows(i).fileName = string(fn);
    rows(i).country = string(lower(fn(1:min(2,end))));
    try
        p = fullfile(listing(i).folder, fn);
        [lon, lat] = readWKTPolygon(p);
        [x, y] = lonLatToLocalXY(lon, lat);
        poly = polyshape(x, y, 'Simplify', true);
        a = area(poly);
        if a <= 0
            error('Non-positive area.');
        end

        [metrics] = computeFieldShapeMetricsFromPoly(poly, [x(:),y(:)]);

        rows(i).area_m2 = a;
        rows(i).area_ha = a / 10000;
        rows(i).width_m = metrics.width_m;
        rows(i).height_m = metrics.height_m;
        rows(i).aspectRatio = metrics.aspectRatio;
        rows(i).perimeter_m = metrics.perimeter_m;
        rows(i).shapeIndex = metrics.shapeIndex;
        rows(i).compactness = metrics.compactness;
        rows(i).convexityRatio = metrics.convexityRatio;
        rows(i).valid = true;
    catch ME
        rows(i).valid = false;
        rows(i).errorMessage = string(ME.message);
    end
end

candidateTable = struct2table(rows, 'AsArray', true);

% User-fixed field list.
if isfield(cfg.chapter53, 'fieldFiles') && ~isempty(cfg.chapter53.fieldFiles)
    wanted = string(cfg.chapter53.fieldFiles(:));
    selectedFields = candidateTable(ismember(string(candidateTable.fileName), wanted), :);
    if height(selectedFields) ~= numel(wanted)
        warning('Some requested fields were not found or invalid.');
    end
    selectedFields.selectionRank = (1:height(selectedFields)).';
    return;
end

% Automatic filtering.
T = candidateTable;
valid = T.valid & ...
    T.area_m2 >= cfg.chapter53.minArea_m2 & ...
    T.area_m2 <= cfg.chapter53.maxArea_m2 & ...
    T.shapeIndex <= cfg.chapter53.maxShapeIndex & ...
    T.compactness >= cfg.chapter53.minCompactness;

countryList = string(cfg.chapter53.countryList);
valid = valid & ismember(T.country, countryList);

T = T(valid, :);
if height(T) == 0
    error('No fields satisfy the Chapter 5.3 selection filters.');
end

% Stratified selection by country and diversity score.
targetN = min(cfg.chapter53.numFields, height(T));
nCountries = numel(countryList);
baseQuota = floor(targetN / nCountries);
remQuota = targetN - baseQuota*nCountries;

selectedIdx = [];

for c = 1:nCountries
    country = countryList(c);
    idx = find(T.country == country);
    if isempty(idx)
        continue;
    end

    quota = baseQuota + double(c <= remQuota);
    quota = min(quota, numel(idx));

    sub = T(idx, :);
    areaRank = tiedRankLocal(sub.area_m2);
    shapeRank = tiedRankLocal(sub.shapeIndex);
    aspectRank = tiedRankLocal(sub.aspectRatio);
    score = 0.55*areaRank + 0.30*shapeRank + 0.15*aspectRank;

    [~, order] = sort(score, 'ascend');
    if quota == 1
        chosenLocal = order(round(numel(order)/2));
    else
        positions = round(linspace(1, numel(order), quota));
        positions = unique(max(1, min(numel(order), positions)), 'stable');
        chosenLocal = order(positions);
        if numel(chosenLocal) < quota
            remaining = setdiff(order, chosenLocal, 'stable');
            chosenLocal = [chosenLocal; remaining(1:min(quota-numel(chosenLocal), numel(remaining)))];
        end
    end

    selectedIdx = [selectedIdx; idx(chosenLocal)]; %#ok<AGROW>
end

% If quotas did not reach target, fill from remaining diverse candidates.
if numel(selectedIdx) < targetN
    remaining = setdiff((1:height(T)).', selectedIdx, 'stable');
    if ~isempty(remaining)
        fillN = min(targetN - numel(selectedIdx), numel(remaining));
        selectedIdx = [selectedIdx; remaining(1:fillN)];
    end
end

selectedFields = T(selectedIdx, :);
selectedFields.selectionRank = (1:height(selectedFields)).';

% Save a quick preview.
if nargin >= 2 && ~isempty(dataDir)
    writetable(selectedFields, fullfile(dataDir, 'selected_fields_preview.csv'));
end
end

function r = tiedRankLocal(x)
x = x(:);
[~, order] = sort(x);
r = zeros(size(x));
for i = 1:numel(x)
    r(order(i)) = i;
end
if numel(x) > 1
    r = (r - 1) ./ (numel(x) - 1);
else
    r(:) = 0.5;
end
end
