%% runChapter51Experiment.m
% Generate the Chapter 5.1 figures:
% (1) real field boundary only, and
% (2) synthetic prescription scenario with localized spraying/fertilization.

clear; clc; close all;
addpath(genpath(fullfile(pwd, 'src')));

cfg = config();
rng(cfg.seed, 'twister');

fprintf('=== Chapter 5.1 Experiment v1.0 ===\n');
fprintf('Field file: %s\n', cfg.data.fieldFileName);

env = generateEnvironment(cfg);

timestamp = datestr(now, 'yyyymmdd_HHMMSS');
outDir = fullfile(cfg.paths.resultsDir, ['chapter5_1_', timestamp]);
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

figBoundary = figure('Name','Chapter 5.1 - Boundary only','Color','w');
plotFieldBoundaryOnly(env, cfg);
drawnow;
saveFigureFiles(figBoundary, fullfile(outDir, 'figure_ch5_1_field_boundary_only'), cfg.plot.saveDpi);

figPrescription = figure('Name','Chapter 5.1 - Prescription scenario','Color','w');
plotEnvironment(env, cfg);
drawnow;
saveFigureFiles(figPrescription, fullfile(outDir, 'figure_ch5_1_synthetic_prescription'), cfg.plot.saveDpi);

save(fullfile(outDir, 'chapter5_1_environment.mat'), 'env', 'cfg');

fprintf('Saved boundary figure: %s\n', fullfile(outDir, 'figure_ch5_1_field_boundary_only.png'));
fprintf('Saved prescription figure: %s\n', fullfile(outDir, 'figure_ch5_1_synthetic_prescription.png'));
fprintf('Saved environment MAT: %s\n', fullfile(outDir, 'chapter5_1_environment.mat'));
