function [summaryByField, summaryOverall] = summarizeChapter53Results(Traw, dataDir)
%SUMMARIZECHAPTER53RESULTS Summaries for Chapter 5.3.

ok = string(Traw.status) == "ok";
Tok = Traw(ok,:);

if height(Tok) == 0
    warning('No successful runs for Chapter 5.3 summary.');
    summaryByField = table();
    summaryOverall = table();
    return;
end

fieldNames = unique(string(Tok.fieldName), 'stable');

metrics = {'makespan','weightedEnergy','driftPenalty','totalPathLength', ...
    'uavPathLength','ugvPathLength','totalEnergy','runtime_s', ...
    'conflictCount','totalWaitingTime','sprayingCoverageRate', ...
    'fertilizationCoverageRate','makespanPerHa','ugvPathLengthPerHa', ...
    'totalPathLengthPerHa','weightedEnergyPerHa'};

rows = repmat(struct(), numel(fieldNames), 1);

for i = 1:numel(fieldNames)
    idx = string(Tok.fieldName) == fieldNames(i);
    first = find(idx, 1, 'first');

    rows(i).fieldName = fieldNames(i);
    rows(i).country = Tok.country(first);
    rows(i).nRuns = sum(idx);

    rows(i).area_m2 = localMean(Tok.area_m2(idx));
    rows(i).area_ha = localMean(Tok.area_ha(idx));
    rows(i).shapeIndex = localMean(Tok.shapeIndex(idx));
    rows(i).compactness = localMean(Tok.compactness(idx));
    rows(i).aspectRatio = localMean(Tok.aspectRatio(idx));
    rows(i).convexityRatio = localMean(Tok.convexityRatio(idx));

    rows(i).successRate = sum(string(Traw.status) == "ok" & string(Traw.fieldName) == fieldNames(i)) / ...
        max(sum(string(Traw.fieldName) == fieldNames(i)), 1);
    rows(i).geometryValidRate = localMean(double(Tok.geometryValid(idx)));

    for j = 1:numel(metrics)
        x = Tok.(metrics{j})(idx);
        rows(i).([metrics{j}, '_mean']) = localMean(x);
        rows(i).([metrics{j}, '_std']) = localStd(x);
        rows(i).([metrics{j}, '_min']) = localMin(x);
        rows(i).([metrics{j}, '_max']) = localMax(x);
    end
end

summaryByField = struct2table(rows, 'AsArray', true);
writetable(summaryByField, fullfile(dataDir, 'summary_by_field.csv'));

overall = struct();
overall.nFields = numel(fieldNames);
overall.nRunsTotal = height(Traw);
overall.nRunsSuccessful = height(Tok);
overall.successRate = height(Tok) / max(height(Traw), 1);
overall.geometryValidRate = localMean(double(Tok.geometryValid));
overall.conflictFreeRate = localMean(double(Tok.conflictCount == 0));

overall.meanSprayCoverage = localMean(Tok.sprayingCoverageRate);
overall.meanFertCoverage = localMean(Tok.fertilizationCoverageRate);
overall.meanConflictCount = localMean(Tok.conflictCount);
overall.maxConflictCount = localMax(Tok.conflictCount);
overall.meanWaitingTime = localMean(Tok.totalWaitingTime);
overall.maxWaitingTime = localMax(Tok.totalWaitingTime);

for j = 1:numel(metrics)
    x = Tok.(metrics{j});
    overall.([metrics{j}, '_mean']) = localMean(x);
    overall.([metrics{j}, '_std']) = localStd(x);
    overall.([metrics{j}, '_min']) = localMin(x);
    overall.([metrics{j}, '_max']) = localMax(x);
end

summaryOverall = struct2table(overall, 'AsArray', true);
writetable(summaryOverall, fullfile(dataDir, 'summary_overall.csv'));
end

function y = localMean(x)
x = double(x(:));
x = x(isfinite(x));
if isempty(x), y = NaN; else, y = mean(x); end
end

function y = localStd(x)
x = double(x(:));
x = x(isfinite(x));
if numel(x) <= 1, y = 0; else, y = std(x); end
end

function y = localMin(x)
x = double(x(:));
x = x(isfinite(x));
if isempty(x), y = NaN; else, y = min(x); end
end

function y = localMax(x)
x = double(x(:));
x = x(isfinite(x));
if isempty(x), y = NaN; else, y = max(x); end
end
