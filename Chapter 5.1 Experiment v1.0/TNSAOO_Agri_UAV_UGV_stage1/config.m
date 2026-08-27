function cfg = config()
%CONFIG Centralized parameters for the stage-1 experiment.

cfg.seed = 2025;

cfg.paths.projectRoot = pwd;
cfg.paths.dataDir = fullfile(cfg.paths.projectRoot, 'data');
cfg.paths.wktDir = fullfile(cfg.paths.dataDir, 'wkt');
cfg.paths.wktZip = fullfile(cfg.paths.dataDir, 'wkt.zip');
cfg.paths.resultsDir = fullfile(cfg.paths.projectRoot, 'results');

if ~exist(cfg.paths.resultsDir, 'dir')
    mkdir(cfg.paths.resultsDir);
end

%% Data
cfg.data.fieldFileName = 'ee_field_14.wkt';  % change this to test other fields
cfg.data.autoPickIfMissing = true;

%% Environment generation
cfg.env.nSprayTasks = 6;
cfg.env.nFertTasks = 6;
cfg.env.nRefillCandidates = 4;
cfg.env.nObstacles = 2;
cfg.env.obstacleRadiusRange = [4, 10];       % meter
cfg.env.taskZoneRadiusRange = [8, 16];       % meter

% Chapter 5.1 figure generation:
% use irregular localized prescription patches instead of only circular zones.
cfg.env.useIrregularPatches = true;
cfg.env.patchNumVertices = 30;
cfg.env.patchPerturbationRange = [0.20, 0.38];
cfg.env.patchAspectRatioRange = [0.70, 1.35];
cfg.env.obstaclePatchPerturbationRange = [0.10, 0.25];

cfg.env.gridResolution = 3.0;                % meter, for prescription map
cfg.env.rowSpacing = 6.0;                    % meter
cfg.env.rowAngleDeg = NaN;                   % NaN means automatic principal direction
cfg.env.refillPreferBoundary = false;

%% UAV parameters
cfg.uav.speed = 5.0;                         % m/s
cfg.uav.sprayWidth = 8.0;                    % m
cfg.uav.overlapRate = 0.15;
cfg.uav.energyPerMeter = 0.055;              % simplified Wh/m
cfg.uav.energyPerArea = 0.002;               % simplified Wh/m^2
cfg.uav.maxEnergy = 450;                     % Wh
cfg.uav.maxSegmentDistance = 750;            % m between refills, simplified
cfg.uav.flightHeight = 3.0;                  % m
cfg.uav.driftBase = 1.0;
cfg.uav.driftHeightCoeff = 0.15;
cfg.uav.driftSpeedCoeff = 0.08;
cfg.uav.candidateAnglesDeg = 0:30:150;

%% UGV parameters
cfg.ugv.speed = 1.2;                         % m/s
cfg.ugv.fertWidth = 4.0;                     % m
cfg.ugv.energyPerMeter = 0.018;              % simplified Wh/m
cfg.ugv.maxEnergy = 700;                     % Wh
cfg.ugv.maxSegmentDistance = 1200;           % m between refills, simplified
cfg.ugv.minTurningRadius = 3.5;              % reserved for later Hybrid A*
cfg.ugv.rowDeviationWeight = 1.0;

%% Conflict detection
cfg.conflict.safetyDistance = 8.0;           % m, horizontal projection
cfg.conflict.dt = 1.0;                       % s
cfg.conflict.waitPerConflict = 3.0;          % s
cfg.conflict.enableRepair = true;
cfg.conflict.ignoreInitialTime = 8.0;         % s, ignore initial depot co-location
cfg.conflict.ignoreDepotRadius = 10.0;        % m, allow co-location near depot/base

%% Objective weights
cfg.obj.uavEnergyWeight = 1.0;
cfg.obj.ugvEnergyWeight = 0.6;
cfg.obj.coveragePenaltyWeight = 1000;
cfg.obj.conflictPenaltyWeight = 100;

%% TNSAOO algorithm
cfg.alg.popSize = 24;
cfg.alg.maxIter = 25;
cfg.alg.archiveSize = 50;
cfg.alg.lb = -5;
cfg.alg.ub = 5;
cfg.alg.tisProbability = 0.65;
cfg.alg.useOriginalAOOUpdate = true;          % v1.4: AOO formula-adapted update
cfg.alg.enableTIS = true;                     % enable/disable TIS for ablation
cfg.alg.tisMode = 'original_adapted';         % 'original_adapted' or 'stage1_simple'
cfg.alg.aooStepInitial = 1.2;
cfg.alg.aooStepFinal = 0.15;
cfg.alg.sigmoidThreshold = 0.50;
cfg.alg.minActiveRefill = 1;

%% Batch experiment
cfg.batch.countryFilter = '';                 % '', 'ee', 'lt', or 'nl'
cfg.batch.numFields = 10;                     % quick default; use 50/100/350 later
cfg.batch.shuffleFields = true;
cfg.batch.seeds = [2026, 2027, 2028];
cfg.batch.fastPopSize = 12;
cfg.batch.fastMaxIter = 10;
cfg.batch.savePerRunMat = false;
cfg.batch.outputPrefix = 'batch';

%% Ablation and baseline experiment
cfg.ablation.numFields = 5;                  % start small; later use 10/30/50
cfg.ablation.seeds = [2026];                 % start with one seed, later 3-5 seeds
cfg.ablation.fastPopSize = 8;
cfg.ablation.fastMaxIter = 5;
cfg.ablation.countryFilter = cfg.batch.countryFilter;
cfg.ablation.shuffleFields = true;
cfg.ablation.outputPrefix = 'ablation';
cfg.ablation.methods = {'FullTNSAOO','NoTIS','SimpleAOO','Independent'};

%% Plotting
cfg.plot.showTaskLabels = true;
cfg.plot.showCropRows = true;
cfg.plot.pathLineWidth = 1.8;
cfg.plot.saveDpi = 300;
cfg.plot.labelOffset = [2.0, 2.0];            % m, text-label offset

%% Chapter 5.1 figure generation
cfg.chapter51.outputPrefix = 'chapter5_1';
cfg.chapter51.saveFig = true;
cfg.chapter51.savePng = true;
cfg.chapter51.boundaryTitle = 'Real field boundary';
cfg.chapter51.prescriptionTitle = 'Synthetic prescription scenario';
end
