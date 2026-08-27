%% runChapter53BatchValidation.m
% Chapter 5.3 Batch Validation on Real Agricultural Field Boundaries
%
% This script validates TNSAOO over many real field boundaries and saves:
%   1) all raw experimental records;
%   2) field-level summary data;
%   3) overall summary data;
%   4) all plot-specific data tables;
%   5) publication-style figures in PNG/FIG/PDF formats.
%
% Design questions:
%   Q1. Can the method run stably on different real field boundaries?
%   Q2. Is there a reasonable relationship between field area and operation cost?
%   Q3. Does field shape complexity affect path efficiency?
%   Q4. Are UAV-UGV conflict counts controllable in batch validation?

clear; clc; close all;
addpath(genpath(fullfile(pwd, 'src')));

cfgBase = config();
cfgBase = ensureChapter53Config(cfgBase);

rng(cfgBase.seed, 'twister');

timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outDir = fullfile(cfgBase.paths.resultsDir, [cfgBase.chapter53.outputPrefix, '_', timestamp]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
dataDir = fullfile(outDir, 'data');
figDir = fullfile(outDir, 'figures');
matDir = fullfile(outDir, 'mat');
mkdirIfNeeded(dataDir);
mkdirIfNeeded(figDir);
mkdirIfNeeded(matDir);

diary(fullfile(outDir, 'chapter5_3_run_log.txt'));

fprintf('=== Chapter 5.3 Batch Validation ===\n');
fprintf('Output directory: %s\n', outDir);
fprintf('Target fields: %d | Seeds: %s | popSize=%d | maxIter=%d\n', ...
    cfgBase.chapter53.numFields, mat2str(cfgBase.chapter53.seeds), ...
    cfgBase.chapter53.popSize, cfgBase.chapter53.maxIter);

% 1) Select or load field list.
[selectedFields, candidateTable] = selectChapter53Fields(cfgBase, dataDir);
writetable(selectedFields, fullfile(dataDir, 'selected_fields.csv'));
writetable(candidateTable, fullfile(dataDir, 'field_selection_candidates.csv'));

fieldFiles = cellstr(selectedFields.fileName);
nFields = numel(fieldFiles);
seeds = cfgBase.chapter53.seeds(:).';
nRunsTotal = nFields * numel(seeds);

fprintf('Selected fields: %d\n', nFields);
fprintf('Total runs: %d\n', nRunsTotal);

records = repmat(chapter53RecordTemplate(), nRunsTotal, 1);
recIdx = 0;

% Save experiment configuration.
save(fullfile(matDir, 'chapter5_3_config.mat'), 'cfgBase', 'selectedFields', 'candidateTable');

rawCsvPath = fullfile(dataDir, 'batch_results_raw.csv');

% 2) Run batch experiments.
for f = 1:nFields
    fieldFile = fieldFiles{f};

    for s = 1:numel(seeds)
        recIdx = recIdx + 1;

        cfg = cfgBase;
        cfg.data.fieldFileName = fieldFile;
        cfg.seed = seeds(s);
        cfg.alg.popSize = cfgBase.chapter53.popSize;
        cfg.alg.maxIter = cfgBase.chapter53.maxIter;
        cfg.alg.archiveSize = cfgBase.chapter53.archiveSize;

        % Area-adaptive tasks are assigned after reading the field.
        rng(cfg.seed + 1000*f + 37*s, 'twister');

        fprintf('\n[%d/%d] Field=%s | seed=%d\n', recIdx, nRunsTotal, fieldFile, cfg.seed);

        try
            tRun = tic;

            env0 = readFields2BenchmarkWKT(cfg);
            cfg = applyChapter53AreaAdaptiveTasks(cfg, env0.fieldAreaForCompat); %#ok<NASGU>
        catch
            % Compatibility fallback: older read function returns field, not struct with fieldAreaForCompat.
        end

        try
            tRun = tic;

            % Build environment once actual cfg is fully set.
            % Read field first to determine task scale.
            fieldPreview = readFields2BenchmarkWKT(cfg);
            cfg = applyChapter53AreaAdaptiveTasks(cfg, fieldPreview.area);

            rng(cfg.seed + 1000*f + 37*s, 'twister');
            env = generateEnvironment(cfg);

            geo = validateScenarioGeometry(env, cfg);
            [archive, history] = tnsaooOptimizer(env, cfg);
            best = selectCompromiseSolution(archive);

            runtime = toc(tRun);
            rec = makeChapter53Record(env, best, archive, cfg, runtime, history, geo, 'ok', '');

            if cfg.chapter53.savePerRunMat
                save(fullfile(matDir, sprintf('run_%03d_%s_seed_%d.mat', recIdx, erase(fieldFile,'.wkt'), cfg.seed)), ...
                    'cfg', 'env', 'archive', 'history', 'best', 'rec');
            end

            fprintf('OK | makespan=%.2f | energy=%.2f | conflict=%g | runtime=%.2fs\n', ...
                rec.makespan, rec.weightedEnergy, rec.conflictCount, rec.runtime_s);

        catch ME
            runtime = NaN;
            rec = makeChapter53FailedRecord(cfg, runtime, ME);
            fprintf('FAILED | %s\n', ME.message);
        end

        records(recIdx) = rec;

        % Incremental saving after every run to prevent data loss.
        TrawPartial = struct2table(records(1:recIdx), 'AsArray', true);
        writetable(TrawPartial, rawCsvPath);
        save(fullfile(matDir, 'chapter5_3_incremental_records.mat'), 'records', 'recIdx', 'cfgBase', 'selectedFields');
    end
end

Traw = struct2table(records, 'AsArray', true);
writetable(Traw, rawCsvPath);

% 3) Summaries and plot data.
[summaryByField, summaryOverall] = summarizeChapter53Results(Traw, dataDir);
plotData = prepareChapter53PlotData(Traw, summaryByField, dataDir);

% 4) Figures.
plotChapter53Figures(plotData, figDir);

% 5) Save workspace.
if cfgBase.chapter53.saveWorkspace
    save(fullfile(matDir, 'chapter5_3_workspace.mat'), ...
        'cfgBase', 'selectedFields', 'candidateTable', 'Traw', 'summaryByField', 'summaryOverall', 'plotData');
end

fprintf('\n=== Chapter 5.3 batch validation finished ===\n');
fprintf('Raw data: %s\n', rawCsvPath);
fprintf('Figures: %s\n', figDir);

diary off;

function mkdirIfNeeded(p)
if ~exist(p, 'dir')
    mkdir(p);
end
end
