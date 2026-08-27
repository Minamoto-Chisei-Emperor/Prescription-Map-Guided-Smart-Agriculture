%% runChapter52RepresentativeCases.m
% Chapter 5.2 Representative Cases v1.0
%
% This script generates the figures and table for Section 5.2:
%   - four representative synthetic prescription scenarios;
%   - four optimized UAV-UGV path figures;
%   - combined 2x2 scenario figure;
%   - combined 2x2 path figure;
%   - representative Pareto archive + convergence figure;
%   - representative_case_results.csv.

clear; clc; close all;
addpath(genpath(fullfile(pwd, 'src')));

cfgBase = config();

caseFiles = cfgBase.chapter52.caseFiles;
caseNames = cfgBase.chapter52.caseNames;
nCases = numel(caseFiles);

timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outDir = fullfile(cfgBase.paths.resultsDir, [cfgBase.chapter52.outputPrefix, '_', timestamp]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

fprintf('=== Chapter 5.2 Representative Cases v1.0 ===\n');
fprintf('Cases: %d\n', nCases);
fprintf('Output directory: %s\n', outDir);

envs = cell(nCases,1);
archives = cell(nCases,1);
histories = cell(nCases,1);
bests = cell(nCases,1);
caseCfgs = cell(nCases,1);
records = struct([]);

for i = 1:nCases
    cfg = cfgBase;
    cfg.data.fieldFileName = caseFiles{i};
    cfg.seed = cfgBase.chapter52.seed + i - 1;
    cfg.alg.popSize = cfgBase.chapter52.popSize;
    cfg.alg.maxIter = cfgBase.chapter52.maxIter;
    cfg.alg.archiveSize = cfgBase.chapter52.archiveSize;

    cfg.env.nSprayTasks = cfgBase.chapter52.nSprayTasks(i);
    cfg.env.nFertTasks = cfgBase.chapter52.nFertTasks(i);
    cfg.env.nObstacles = cfgBase.chapter52.nObstacles(i);
    cfg.env.nRefillCandidates = cfgBase.chapter52.nRefillCandidates(i);
    cfg.env.useIrregularPatches = true;

    rng(cfg.seed, 'twister');

    fprintf('\n--- %s | %s ---\n', caseNames{i}, cfg.data.fieldFileName);
    fprintf('Seed=%d | popSize=%d | maxIter=%d\n', cfg.seed, cfg.alg.popSize, cfg.alg.maxIter);

    env = generateEnvironment(cfg);
    geoCheck = validateScenarioGeometry(env, cfg);
    if ~geoCheck.isValid
        warning('Scenario geometry validation failed for %s.', cfg.data.fieldFileName);
    end

    % Individual scenario figure.
    cfgScenario = cfg;
    cfgScenario.plot.showTaskLabels = cfgBase.chapter52.showLabelsIndividual;
    figScenario = figure('Name', ['Scenario - ', caseNames{i}], 'Color','w');
    plotScenarioPanel(env, cfgScenario, sprintf('%s (%s)', caseNames{i}, env.field.name), true);
    saveFigureFiles(figScenario, fullfile(outDir, sprintf('case_%02d_scenario', i)), cfg.plot.saveDpi);

    % Optimization.
    tStart = tic;
    [archive, history] = tnsaooOptimizer(env, cfg);
    best = selectCompromiseSolution(archive);
    runtime = toc(tStart);

    % Individual path figure.
    cfgPath = cfg;
    cfgPath.plot.showTaskLabels = cfgBase.chapter52.showLabelsIndividual;
    figPath = figure('Name', ['Path - ', caseNames{i}], 'Color','w');
    plotPathsPaper(env, best, cfgPath, sprintf('%s (%s)', caseNames{i}, env.field.name), true);
    saveFigureFiles(figPath, fullfile(outDir, sprintf('case_%02d_paths', i)), cfg.plot.saveDpi);

    envs{i} = env;
    archives{i} = archive;
    histories{i} = history;
    bests{i} = best;
    caseCfgs{i} = cfg;

    rec = makeRepresentativeCaseRecord(i, caseNames{i}, env, best, archive, cfg, runtime);
    if i == 1
        records = rec;
    else
        records(i) = rec; %#ok<SAGROW>
    end
end

T = struct2table(records, 'AsArray', true);
writetable(T, fullfile(outDir, 'representative_case_results.csv'));

% Combined scenario figure.
figScenarioAll = figure('Name','Representative scenarios - combined','Color','w', ...
    'Position', [100, 100, 1200, 900]);
try
    makeCaseTiledLayout(nCases);
    useTiled = true;
catch
    useTiled = false;
end
for i = 1:nCases
    if useTiled
        nexttile;
    else
        subplot(1,nCases,i);
    end
    cfgPlot = caseCfgs{i};
    cfgPlot.plot.showTaskLabels = cfgBase.chapter52.showLabelsCombined;
    plotScenarioPanel(envs{i}, cfgPlot, sprintf('%s: %s', char('A'+i-1), envs{i}.field.name), false);
end
saveFigureFiles(figScenarioAll, fullfile(outDir, 'figure_ch5_2_representative_scenarios'), cfgBase.plot.saveDpi);

% Combined path figure.
figPathAll = figure('Name','Representative paths - combined','Color','w', ...
    'Position', [100, 100, 1200, 900]);
try
    makeCaseTiledLayout(nCases);
    useTiled = true;
catch
    useTiled = false;
end
for i = 1:nCases
    if useTiled
        nexttile;
    else
        subplot(1,nCases,i);
    end
    cfgPlot = caseCfgs{i};
    cfgPlot.plot.showTaskLabels = cfgBase.chapter52.showLabelsCombined;
    plotPathsPaper(envs{i}, bests{i}, cfgPlot, sprintf('%s: %s', char('A'+i-1), envs{i}.field.name), false);
end
saveFigureFiles(figPathAll, fullfile(outDir, 'figure_ch5_2_representative_paths'), cfgBase.plot.saveDpi);

% Improved Pareto + convergence figure for one representative case.
paretoIdx = cfgBase.chapter52.paretoCaseIndex;
paretoIdx = max(1, min(nCases, paretoIdx));
figPareto = figure('Name','Pareto and convergence - paper style','Color','w', ...
    'Position', [100, 100, 1100, 420]);
plotParetoConvergencePaper(archives{paretoIdx}, histories{paretoIdx}, bests{paretoIdx}, ...
    caseCfgs{paretoIdx}, sprintf('Pareto and convergence of %s (%s)', caseNames{paretoIdx}, envs{paretoIdx}.field.name));
saveFigureFiles(figPareto, fullfile(outDir, sprintf('figure_ch5_2_pareto_convergence_case_%02d', paretoIdx)), cfgBase.plot.saveDpi);

save(fullfile(outDir, 'chapter5_2_workspace.mat'), ...
    'cfgBase', 'caseCfgs', 'envs', 'archives', 'histories', 'bests', 'T');

fprintf('\nChapter 5.2 representative cases finished.\n');
fprintf('Results table: %s\n', fullfile(outDir, 'representative_case_results.csv'));
fprintf('Combined scenarios: %s\n', fullfile(outDir, 'figure_ch5_2_representative_scenarios.png'));
fprintf('Combined paths: %s\n', fullfile(outDir, 'figure_ch5_2_representative_paths.png'));
fprintf('Pareto/convergence: %s\n', fullfile(outDir, sprintf('figure_ch5_2_pareto_convergence_case_%02d.png', paretoIdx)));


function makeCaseTiledLayout(nCases)
%MAKECASETILEDLAYOUT Choose a compact layout for representative cases.
if nCases <= 2
    tiledlayout(1, nCases, 'TileSpacing','compact', 'Padding','compact');
else
    tiledlayout(2, ceil(nCases/2), 'TileSpacing','compact', 'Padding','compact');
end
end
