%% main.m
% Stage-1 MATLAB prototype for UAV-UGV collaborative path planning.
% Author: generated with ChatGPT assistance
% Date: 2026

clear; clc; close all;

addpath(genpath(fullfile(pwd, 'src')));

cfg = config();
rng(cfg.seed, 'twister');

fprintf('=== TNSAOO agricultural UAV-UGV stage-1 prototype ===\n');
fprintf('Field file: %s\n', cfg.data.fieldFileName);

env = generateEnvironment(cfg);

fig1 = figure('Name','Agricultural field environment','Color','w');
plotEnvironment(env, cfg);
drawnow;

[archive, history] = tnsaooOptimizer(env, cfg);
best = selectCompromiseSolution(archive);

fprintf('\n=== Best compromise solution ===\n');
disp(best.objectives);
disp(best.metrics);

fig2 = figure('Name','Collaborative UAV-UGV paths','Color','w');
plotPaths(env, best, cfg);
drawnow;

fig3 = figure('Name','Pareto front','Color','w');
plotParetoFront(archive, cfg);
drawnow;

fig4 = figure('Name','Convergence curve','Color','w');
plotConvergence(history, cfg);
drawnow;

saveResults(env, archive, history, best, cfg, {fig1, fig2, fig3, fig4});

fprintf('Done. Results saved to: %s\n', cfg.paths.resultsDir);
