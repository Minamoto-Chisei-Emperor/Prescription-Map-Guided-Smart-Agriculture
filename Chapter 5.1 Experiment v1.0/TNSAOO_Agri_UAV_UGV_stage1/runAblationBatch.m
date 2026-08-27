%% runAblationBatch.m
% v1.5 ablation/baseline experiment.
%
% This script compares:
%   1. FullTNSAOO
%   2. NoTIS
%   3. SimpleAOO
%   4. Independent baseline
%
% Start small before formal experiments.

clear; clc; close all;
addpath(genpath(fullfile(pwd, 'src')));

cfg = config();

cfg.alg.popSize = cfg.ablation.fastPopSize;
cfg.alg.maxIter = cfg.ablation.fastMaxIter;
cfg.plot.showTaskLabels = false;

ablationStamp = datestr(now, 'yyyymmdd_HHMMSS');
outDir = fullfile(cfg.paths.resultsDir, [cfg.ablation.outputPrefix, '_', ablationStamp]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

rng(cfg.seed, 'twister');

fields = listFields2Benchmark(cfg, ...
    'country', cfg.ablation.countryFilter, ...
    'maxFields', cfg.ablation.numFields, ...
    'shuffle', cfg.ablation.shuffleFields);

variants = getExperimentVariants(cfg);

fprintf('=== Ablation/baseline experiment ===\n');
fprintf('Fields: %d | Seeds: %d | Methods: %d | popSize=%d | maxIter=%d\n', ...
    height(fields), numel(cfg.ablation.seeds), numel(variants), cfg.alg.popSize, cfg.alg.maxIter);
fprintf('Output directory: %s\n', outDir);

Traw = table();
runId = 0;
totalRuns = height(fields) * numel(cfg.ablation.seeds) * numel(variants);

for f = 1:height(fields)
    for s = 1:numel(cfg.ablation.seeds)
        % Generate the same environment once per field-seed so methods are comparable.
        cfgEnv = cfg;
        cfgEnv.data.fieldFileName = char(fields.fileName(f));
        cfgEnv.seed = cfg.ablation.seeds(s);
        rng(cfgEnv.seed, 'twister');

        try
            env = generateEnvironment(cfgEnv);
        catch MEenv
            % If environment generation fails, record all methods as failed.
            for v = 1:numel(variants)
                runId = runId + 1;
                rec = makeFailedRecord(char(fields.fileName(f)), char(fields.country(f)), cfgEnv.seed, 0, MEenv);
                rec = makeAblationRecord(rec, variants(v), runId);
                Traw = recordsTableAppend(Traw, rec);
            end
            continue;
        end

        for v = 1:numel(variants)
            runId = runId + 1;
            variant = variants(v);

            cfgRun = applyExperimentVariant(cfgEnv, variant);
            cfgRun.paths.resultsDir = outDir;

            % Method-specific seed for optimizer randomness, while keeping the
            % generated environment fixed across variants.
            rng(cfgEnv.seed + 1000*v, 'twister');

            fprintf('\n[%d/%d] Field=%s | seed=%d | method=%s\n', ...
                runId, totalRuns, cfgRun.data.fieldFileName, cfgRun.seed, string(variant.method));

            tStart = tic;

            try
                if variant.type == "baseline"
                    [best, archive, history] = runIndependentPlanningBaseline(env, cfgRun);
                else
                    [archive, history] = tnsaooOptimizer(env, cfgRun);
                    best = selectCompromiseSolution(archive);
                end

                runtime = toc(tStart);
                rec = makeBatchRecord(env, best, archive, cfgRun, runtime, "ok", "");
                rec = makeAblationRecord(rec, variant, runId);
                Traw = recordsTableAppend(Traw, rec);

            catch ME
                runtime = toc(tStart);
                rec = makeFailedRecord(char(fields.fileName(f)), char(fields.country(f)), cfgRun.seed, runtime, ME);
                rec = makeAblationRecord(rec, variant, runId);
                Traw = recordsTableAppend(Traw, rec);

                warning('Failed field %s seed %d method %s: %s', ...
                    cfgRun.data.fieldFileName, cfgRun.seed, string(variant.method), ME.message);

                fid = fopen(fullfile(outDir, sprintf('error_run_%03d.txt', runId)), 'w');
                if fid > 0
                    fprintf(fid, '%s\n', safeGetReport(ME));
                    fclose(fid);
                end
            end

            writetable(Traw, fullfile(outDir, 'ablation_results_raw.csv'));
        end
    end
end

writetable(Traw, fullfile(outDir, 'ablation_results_raw.csv'));

[summaryByMethod, summaryByFieldMethod] = summarizeAblationResults(Traw, outDir);
plotAblationStatistics(summaryByMethod, outDir);

save(fullfile(outDir, 'ablation_workspace.mat'), ...
    'Traw', 'summaryByMethod', 'summaryByFieldMethod', 'cfg', 'fields', 'variants');

fprintf('\nAblation batch done.\n');
fprintf('Raw results: %s\n', fullfile(outDir, 'ablation_results_raw.csv'));
fprintf('Summary by method: %s\n', fullfile(outDir, 'summary_by_method.csv'));
fprintf('Summary by field-method: %s\n', fullfile(outDir, 'summary_by_field_method.csv'));
