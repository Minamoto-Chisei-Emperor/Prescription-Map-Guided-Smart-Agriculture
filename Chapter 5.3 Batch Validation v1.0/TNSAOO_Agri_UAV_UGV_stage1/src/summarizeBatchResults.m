function [summaryByField, summaryOverall] = summarizeBatchResults(Traw, outDir)
%SUMMARIZEBATCHRESULTS Create mean/std/best summaries from batch records.
% v1.4.3 uses local NaN-safe helpers instead of relying on nanflag support.

ok = string(Traw.status) == "ok";
Tok = Traw(ok,:);

if height(Tok) == 0
    warning('No successful batch records to summarize.');
    summaryByField = table();
    summaryOverall = table();
    return;
end

metrics = {'makespan','weightedEnergy','driftPenalty','totalPathLength', ...
    'uavPathLength','ugvPathLength','totalEnergy','totalWaitingTime', ...
    'conflictCount','sprayingCoverageRate','fertilizationCoverageRate','runtime_s'};

fieldCol = string(Tok.fieldName);
countryCol = string(Tok.country);
fieldNames = unique(fieldCol, 'stable');

rows = repmat(struct(), numel(fieldNames), 1);

for i = 1:numel(fieldNames)
    idx = fieldCol == fieldNames(i);
    rows(i).fieldName = fieldNames(i);
    firstIdx = find(idx, 1, 'first');
    rows(i).country = countryCol(firstIdx);
    rows(i).nRuns = sum(idx);
    rows(i).area_m2 = localMean(Tok.area_m2(idx));

    for j = 1:numel(metrics)
        x = Tok.(metrics{j})(idx);
        rows(i).([metrics{j}, '_mean']) = localMean(x);
        rows(i).([metrics{j}, '_std']) = localStd(x);
        rows(i).([metrics{j}, '_best']) = localMin(x);
    end
end

summaryByField = struct2table(rows, 'AsArray', true);
writetable(summaryByField, fullfile(outDir, 'summary_by_field.csv'));

overall = struct();
overall.nFields = numel(fieldNames);
overall.nRuns = height(Tok);

for j = 1:numel(metrics)
    x = Tok.(metrics{j});
    overall.([metrics{j}, '_mean']) = localMean(x);
    overall.([metrics{j}, '_std']) = localStd(x);
    overall.([metrics{j}, '_best']) = localMin(x);
end

summaryOverall = struct2table(overall, 'AsArray', true);
writetable(summaryOverall, fullfile(outDir, 'summary_overall.csv'));
end

function y = localMean(x)
x = x(:);
x = x(~isnan(x));
if isempty(x)
    y = NaN;
else
    y = mean(x);
end
end

function y = localStd(x)
x = x(:);
x = x(~isnan(x));
if numel(x) <= 1
    y = 0;
else
    y = std(x);
end
end

function y = localMin(x)
x = x(:);
x = x(~isnan(x));
if isempty(x)
    y = NaN;
else
    y = min(x);
end
end
