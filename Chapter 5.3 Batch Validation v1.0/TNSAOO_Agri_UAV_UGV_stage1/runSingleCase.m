%% runSingleCase.m
% Quick single-field run for debugging and figure generation.
% This script uses smaller population/iteration settings than main.m.

clear; clc; close all;
addpath(genpath(fullfile(pwd, 'src')));

cfg = config();

% Fast debug settings. Change these values for more stable results.
cfg.alg.popSize = 12;
cfg.alg.maxIter = 10;
cfg.plot.showTaskLabels = true;

rng(cfg.seed, 'twister');

fprintf('=== Quick single-case run ===\n');
fprintf('Field file: %s\n', cfg.data.fieldFileName);

env = generateEnvironment(cfg);

figure('Name','Single-case environment','Color','w');
plotEnvironment(env, cfg);

[archive, history] = tnsaooOptimizer(env, cfg);
best = selectCompromiseSolution(archive);

figure('Name','Single-case paths','Color','w');
plotPaths(env, best, cfg);

figure('Name','Single-case Pareto front','Color','w');
plotParetoFront(archive, cfg);

figure('Name','Single-case convergence','Color','w');
plotConvergence(history, cfg);

fprintf('\nBest objectives:\n');
disp(best.objectives);
fprintf('Best metrics:\n');
disp(best.metrics);
