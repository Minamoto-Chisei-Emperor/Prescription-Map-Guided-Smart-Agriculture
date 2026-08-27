function saveResults(env, archive, history, best, cfg, figs)
%SAVERESULTS Save MAT, CSV, and figures.

if ~exist(cfg.paths.resultsDir, 'dir')
    mkdir(cfg.paths.resultsDir);
end

stamp = datestr(now, 'yyyymmdd_HHMMSS');

matPath = fullfile(cfg.paths.resultsDir, ['result_', stamp, '.mat']);
save(matPath, 'env', 'archive', 'history', 'best', 'cfg');

% Pareto objective table.
obj = reshape([archive.objectives], 3, []).';
T = array2table(obj, 'VariableNames', {'Makespan','WeightedEnergy','DriftPenalty'});
T.Violation = [archive.violation].';
csvPath = fullfile(cfg.paths.resultsDir, ['pareto_archive_', stamp, '.csv']);
writetable(T, csvPath);

% Best compromise metrics table.
metricsPath = fullfile(cfg.paths.resultsDir, ['best_metrics_', stamp, '.csv']);
bestMetricsTable = struct2table(flattenMetrics(best.metrics), 'AsArray', true);
writetable(bestMetricsTable, metricsPath);

% Best decoded scheduling information.
schedulePath = fullfile(cfg.paths.resultsDir, ['best_schedule_', stamp, '.csv']);
S = table();
S.UAVSequence = {mat2str(best.decoded.uavSeq)};
S.UGVSequence = {mat2str(best.decoded.ugvSeq)};
S.ActiveRefillIds = {mat2str(best.decoded.activeRefillIds)};
writetable(S, schedulePath);

for i = 1:numel(figs)
    figPath = fullfile(cfg.paths.resultsDir, sprintf('figure_%02d_%s.png', i, stamp));
    try
        exportgraphics(figs{i}, figPath, 'Resolution', cfg.plot.saveDpi);
    catch
        saveas(figs{i}, figPath);
    end
end

fprintf('Saved MAT: %s\n', matPath);
fprintf('Saved CSV: %s\n', csvPath);
fprintf('Saved best metrics CSV: %s\n', metricsPath);
fprintf('Saved best schedule CSV: %s\n', schedulePath);
end

function out = flattenMetrics(metrics)
names = fieldnames(metrics);
out = struct();
for i = 1:numel(names)
    v = metrics.(names{i});
    if isnumeric(v) && isscalar(v)
        out.(names{i}) = v;
    elseif islogical(v) && isscalar(v)
        out.(names{i}) = double(v);
    else
        % Keep this function numeric-table friendly for CSV.
    end
end
end
