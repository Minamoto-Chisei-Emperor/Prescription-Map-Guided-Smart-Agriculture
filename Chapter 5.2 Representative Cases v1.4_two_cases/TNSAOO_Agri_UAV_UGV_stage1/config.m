function cfg = config()
%CONFIG Centralized parameters for the stage-1 experiment.

cfg.seed = 2026;

cfg.paths.projectRoot = pwd;
cfg.paths.dataDir = fullfile(cfg.paths.projectRoot, 'data');
cfg.paths.wktDir = fullfile(cfg.paths.dataDir, 'wkt');
cfg.paths.wktZip = fullfile(cfg.paths.dataDir, 'wkt.zip');
cfg.paths.resultsDir = fullfile(cfg.paths.projectRoot, 'results');

if ~exist(cfg.paths.resultsDir, 'dir')
    mkdir(cfg.paths.resultsDir);

%% Chapter 5.2 representative cases
cfg.chapter52.seed = 2026;
cfg.chapter52.caseFiles = {'ee_field_9.wkt','lt_field_119.wkt'};
cfg.chapter52.caseNames = {'Case 1: Large Estonian field','Case 2: Lithuanian field'};
cfg.chapter52.popSize = 20;
cfg.chapter52.maxIter = 20;
cfg.chapter52.archiveSize = 50;
cfg.chapter52.nSprayTasks = [8, 6];
cfg.chapter52.nFertTasks = [8, 6];
cfg.chapter52.nObstacles = [2, 2];             % plus known field obstacle for ee_field_9
cfg.chapter52.nRefillCandidates = [5, 4];
cfg.chapter52.paretoCaseIndex = 1;
cfg.chapter52.showLabelsIndividual = true;
cfg.chapter52.showLabelsCombined = false;
cfg.chapter52.outputPrefix = 'chapter5_2_two_cases_supplement';

%% Known field obstacles
% ee_field_9 contains an evident internal tree/woodland patch in the
% satellite image. It is treated as a fixed non-croppable obstacle.
cfg.env.includeKnownFieldObstacles = true;

end
