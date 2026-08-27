function [summaryByMethod, summaryByFieldMethod] = summarizeAblationResults(Traw, outDir)
%SUMMARIZEABLATIONRESULTS Summarize ablation results by method and by field-method.

ok = string(Traw.status) == "ok";
T = Traw(ok,:);

if height(T) == 0
    warning('No successful ablation records to summarize.');
    summaryByMethod = table();
    summaryByFieldMethod = table();
    return;
end

metrics = {'makespan','weightedEnergy','driftPenalty','totalPathLength', ...
    'uavPathLength','ugvPathLength','totalEnergy','totalWaitingTime', ...
    'conflictCount','sprayingCoverageRate','fertilizationCoverageRate','runtime_s'};

methodCol = string(T.method);
methods = unique(methodCol, 'stable');

rows = repmat(struct(), numel(methods), 1);
for i = 1:numel(methods)
    idx = methodCol == methods(i);
    rows(i).method = methods(i);
    rows(i).nRuns = sum(idx);
    rows(i).successRate = sum(idx) / height(Traw);

    for j = 1:numel(metrics)
        x = T.(metrics{j})(idx);
        rows(i).([metrics{j}, '_mean']) = localMean(x);
        rows(i).([metrics{j}, '_std']) = localStd(x);
        rows(i).([metrics{j}, '_best']) = localMin(x);
    end
end

summaryByMethod = struct2table(rows, 'AsArray', true);
writetable(summaryByMethod, fullfile(outDir, 'summary_by_method.csv'));

fieldCol = string(T.fieldName);
fields = unique(fieldCol, 'stable');
rows2 = struct([]);
k = 0;
for f = 1:numel(fields)
    for m = 1:numel(methods)
        idx = fieldCol == fields(f) & methodCol == methods(m);
        if ~any(idx)
            continue;
        end
        k = k + 1;
        rows2(k).fieldName = fields(f); %#ok<AGROW>
        rows2(k).method = methods(m);
        rows2(k).nRuns = sum(idx);
        rows2(k).area_m2 = localMean(T.area_m2(idx));
        for j = 1:numel(metrics)
            x = T.(metrics{j})(idx);
            rows2(k).([metrics{j}, '_mean']) = localMean(x);
            rows2(k).([metrics{j}, '_std']) = localStd(x);
            rows2(k).([metrics{j}, '_best']) = localMin(x);
        end
    end
end

summaryByFieldMethod = struct2table(rows2, 'AsArray', true);
writetable(summaryByFieldMethod, fullfile(outDir, 'summary_by_field_method.csv'));
end

function y = localMean(x)
x = x(:);
x = x(~isnan(x));
if isempty(x), y = NaN; else, y = mean(x); end
end

function y = localStd(x)
x = x(:);
x = x(~isnan(x));
if numel(x) <= 1, y = 0; else, y = std(x); end
end

function y = localMin(x)
x = x(:);
x = x(~isnan(x));
if isempty(x), y = NaN; else, y = min(x); end
end
