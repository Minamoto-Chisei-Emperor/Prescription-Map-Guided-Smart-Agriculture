function cfg = config()
%CONFIG Centralized parameters for UAV-UGV agricultural planning experiments.
%
% Clean configuration for Chapter 5.3 batch validation.

cfg.seed = 2026;

%% Paths
cfg.paths.projectRoot = pwd;
cfg.paths.dataDir = fullfile(cfg.paths.projectRoot, 'data');
cfg.paths.wktDir = fullfile(cfg.paths.dataDir, 'wkt');
cfg.paths.wktZip = fullfile(cfg.paths.dataDir, 'wkt.zip');
cfg.paths.resultsDir = fullfile(cfg.paths.projectRoot, 'results');

if ~exist(cfg.paths.resultsDir, 'dir')
    mkdir(cfg.paths.resultsDir);
end

%% Data
cfg.data.fieldFileName = 'ee_field_9.wkt';
cfg.data.autoPickIfMissing = true;

%% Environment generation
cfg.env.nSprayTasks = 6;
cfg.env.nFertTasks = 6;
cfg.env.nRefillCandidates = 4;
cfg.env.nObstacles = 2;

cfg.env.obstacleRadiusRange = [4, 10];        % m
cfg.env.obstacleSafetyMargin = 3.0;           % m
cfg.env.transferCheckResolution = 1.0;        % m
cfg.env.taskZoneRadiusRange = [8, 16];        % m

cfg.env.useIrregularPatches = true;
cfg.env.patchNumVertices = 28;
cfg.env.patchPerturbationRange = [0.18, 0.35];
cfg.env.patchAspectRatioRange = [0.70, 1.35];
cfg.env.obstaclePatchPerturbationRange = [0.10, 0.25];

cfg.env.sameTypeOverlapToleranceArea = 0.5;   % m^2
cfg.env.minPrescriptionPatchArea = 8.0;       % m^2
cfg.env.maxPatchGenerationAttempts = 500;

cfg.env.gridResolution = 3.0;                 % m, for prescription map
cfg.env.rowSpacing = 6.0;                     % m
cfg.env.rowAngleDeg = NaN;
cfg.env.refillPreferBoundary = false;
cfg.env.includeKnownFieldObstacles = false;   % batch validation uses general WKT boundaries

%% UAV parameters
cfg.uav.speed = 5.0;                          % m/s
cfg.uav.sprayWidth = 8.0;                     % m
cfg.uav.overlapRate = 0.15;
cfg.uav.energyPerMeter = 0.055;               % simplified Wh/m
cfg.uav.energyPerArea = 0.002;                % simplified Wh/m^2
cfg.uav.maxEnergy = 450;                      % Wh
cfg.uav.maxSegmentDistance = 750;             % m
cfg.uav.flightHeight = 3.0;                   % m
cfg.uav.driftBase = 1.0;
cfg.uav.driftHeightCoeff = 0.15;
cfg.uav.driftSpeedCoeff = 0.08;
cfg.uav.candidateAnglesDeg = 0:30:150;

%% UGV parameters
cfg.ugv.speed = 1.2;                          % m/s
cfg.ugv.fertWidth = 4.0;                      % m
cfg.ugv.energyPerMeter = 0.018;               % simplified Wh/m
cfg.ugv.maxEnergy = 700;                      % Wh
cfg.ugv.maxSegmentDistance = 1200;            % m
cfg.ugv.minTurningRadius = 3.5;
cfg.ugv.rowDeviationWeight = 1.0;

%% Fast obstacle-aware transfer
cfg.planner.transferMode = 'visibility_fast';
cfg.planner.lineCheckResolution = 1.0;
cfg.planner.gridResolution = 5.0;
cfg.planner.maxGridNodesWarning = 160000;

%% Conflict detection
cfg.conflict.safetyDistance = 8.0;            % m
cfg.conflict.dt = 1.0;                        % s
cfg.conflict.waitPerConflict = 3.0;           % s
cfg.conflict.enableRepair = true;
cfg.conflict.ignoreInitialTime = 8.0;         % s
cfg.conflict.ignoreDepotRadius = 10.0;        % m

%% Objective weights
cfg.obj.uavEnergyWeight = 1.0;
cfg.obj.ugvEnergyWeight = 0.6;
cfg.obj.coveragePenaltyWeight = 1000;
cfg.obj.conflictPenaltyWeight = 100;

%% TNSAOO algorithm
cfg.alg.popSize = 20;
cfg.alg.maxIter = 20;
cfg.alg.archiveSize = 50;
cfg.alg.lb = -5;
cfg.alg.ub = 5;
cfg.alg.tisProbability = 0.65;
cfg.alg.useOriginalAOOUpdate = true;
cfg.alg.enableTIS = true;
cfg.alg.tisMode = 'original_adapted';
cfg.alg.aooStepInitial = 1.2;
cfg.alg.aooStepFinal = 0.15;
cfg.alg.sigmoidThreshold = 0.50;
cfg.alg.minActiveRefill = 1;

%% Chapter 5.3 batch validation
cfg.chapter53.numFields = 30;
cfg.chapter53.seeds = [2026, 2027, 2028];
cfg.chapter53.popSize = 20;
cfg.chapter53.maxIter = 20;
cfg.chapter53.archiveSize = 50;
cfg.chapter53.outputPrefix = 'chapter5_3_batch_validation';

% Set fieldFiles to a non-empty cell array if you want a fixed set.
% Otherwise, the script automatically selects fields in a stratified way.
cfg.chapter53.fieldFiles = {};

% Selection and filtering
cfg.chapter53.countryList = {'ee','lt','nl'};
cfg.chapter53.minArea_m2 = 2500;
cfg.chapter53.maxArea_m2 = 300000;
cfg.chapter53.maxShapeIndex = 4.5;
cfg.chapter53.minCompactness = 0.03;

% Area-adaptive task generation
cfg.chapter53.smallAreaThreshold_m2 = 20000;  % < 2 ha
cfg.chapter53.largeAreaThreshold_m2 = 80000;  % >= 8 ha

% Data-saving controls
cfg.chapter53.savePerRunMat = false;
cfg.chapter53.saveWorkspace = true;
cfg.chapter53.saveAllPlotData = true;

% Quick debug option. Keep false for formal experiments.
cfg.chapter53.quickTest = false;
if cfg.chapter53.quickTest
    cfg.chapter53.numFields = 3;
    cfg.chapter53.seeds = 2026;
    cfg.chapter53.popSize = 6;
    cfg.chapter53.maxIter = 3;
end
end
