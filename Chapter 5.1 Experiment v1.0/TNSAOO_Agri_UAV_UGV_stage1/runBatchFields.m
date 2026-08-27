%% runBatchFields.m
% Batch experiment over multiple Fields2Benchmark WKT fields.
%
% Recommended first test:
%   cfg.batch.numFields = 3;
%   cfg.batch.seeds = [2026];
%   cfg.batch.fastPopSize = 8;
%   cfg.batch.fastMaxIter = 5;
%
% Formal experiment can later use 50/100/350 fields and multiple seeds.

clear; clc; close all;
addpath(genpath(fullfile(pwd, 'src')));

cfg = config();

% Fast batch defaults. Edit config.m or override below.
cfg.alg.popSize = cfg.batch.fastPopSize;
cfg.alg.maxIter = cfg.batch.fastMaxIter;
cfg.plot.showTaskLabels = false;

batchStamp = datestr(now, 'yyyymmdd_HHMMSS');
batchDir = fullfile(cfg.paths.resultsDir, [cfg.batch.outputPrefix, '_', batchStamp]);
if ~exist(batchDir, 'dir')
    mkdir(batchDir);
end

rng(cfg.seed, 'twister');
fields = listFields2Benchmark(cfg, ...
    'country', cfg.batch.countryFilter, ...
    'maxFields', cfg.batch.numFields, ...
    'shuffle', cfg.batch.shuffleFields);

fprintf('=== Batch experiment ===\n');
fprintf('Fields: %d | Seeds: %d | popSize=%d | maxIter=%d\n', ...
    height(fields), numel(cfg.batch.seeds), cfg.alg.popSize, cfg.alg.maxIter);
fprintf('Output directory: %s\n', batchDir);

records = repmat(batchRecordTemplate(), 0, 1);
runId = 0;

for f = 1:height(fields)
    for s = 1:numel(cfg.batch.seeds)
        runId = runId + 1;

        cfgRun = cfg;
        cfgRun.data.fieldFileName = char(fields.fileName(f));
        cfgRun.seed = cfg.batch.seeds(s);
        cfgRun.paths.resultsDir = batchDir;
        rng(cfgRun.seed, 'twister');

        fprintf('\n[%d/%d] Field=%s | seed=%d\n', ...
            runId, height(fields)*numel(cfg.batch.seeds), ...
            cfgRun.data.fieldFileName, cfgRun.seed);

        tStart = tic;

        try
            env = generateEnvironment(cfgRun);
            [archive, history] = tnsaooOptimizer(env, cfgRun);
            best = selectCompromiseSolution(archive);
            runtime = toc(tStart);

            rec = makeBatchRecord(env, best, archive, cfgRun, runtime, "ok", "");
            records = appendBatchRecord(records, rec);

            if cfg.batch.savePerRunMat
                matName = sprintf('run_%03d_%s_seed%d.mat', runId, strrep(cfgRun.data.fieldFileName,'.wkt',''), cfgRun.seed);
                save(fullfile(batchDir, matName), 'env', 'archive', 'history', 'best', 'cfgRun');
            end

        catch ME
            runtime = toc(tStart);
            rec = makeFailedRecord(char(fields.fileName(f)), char(fields.country(f)), cfgRun.seed, runtime, ME);
            records = appendBatchRecord(records, rec);

            warning('Failed field %s seed %d: %s', cfgRun.data.fieldFileName, cfgRun.seed, ME.message);

            fid = fopen(fullfile(batchDir, sprintf('error_run_%03d.txt', runId)), 'w');
            if fid > 0
                fprintf(fid, '%s\n', safeGetReport(ME));
                fclose(fid);
            end
        end

        Traw = recordsToTable(records);
        writetable(Traw, fullfile(batchDir, 'batch_results_raw.csv'));
    end
end

Traw = recordsToTable(records);
writetable(Traw, fullfile(batchDir, 'batch_results_raw.csv'));

[summaryByField, summaryOverall] = summarizeBatchResults(Traw, batchDir);
plotBatchStatistics(Traw, batchDir);

save(fullfile(batchDir, 'batch_workspace.mat'), 'Traw', 'summaryByField', 'summaryOverall', 'cfg', 'fields');

fprintf('\nBatch done.\n');
fprintf('Raw results: %s\n', fullfile(batchDir, 'batch_results_raw.csv'));
fprintf('Summary by field: %s\n', fullfile(batchDir, 'summary_by_field.csv'));
fprintf('Overall summary: %s\n', fullfile(batchDir, 'summary_overall.csv'));
