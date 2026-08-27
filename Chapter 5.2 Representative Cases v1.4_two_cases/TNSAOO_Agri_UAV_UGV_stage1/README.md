# TNSAOO_Agri_UAV_UGV_stage1

MATLAB stage-1 prototype for UAV–UGV collaborative path planning in smart agriculture.

## What this stage implements

- Read real field boundaries from Fields2Benchmark WKT files.
- Convert lon/lat WKT polygon to local meter coordinates.
- Generate synthetic UAV spraying task zones, UGV fertilization task zones, candidate refill stations, obstacles, crop rows, and simple demand maps inside the real field polygon.
- Run a simplified upper-layer multi-objective TNSAOO workflow:
  - random-key encoding;
  - ROV decoding for UAV/UGV task sequences;
  - Sigmoid decoding for candidate refill-station activation;
  - external Pareto archive;
  - non-dominated sorting;
  - crowding distance;
  - simplified Thinking Innovation Strategy.
- Run simplified lower-layer planners:
  - UAV coverage strips over spraying zones;
  - UGV row-guided fertilization strips;
  - straight-line inter-zone connection;
  - time-stamped conflict detection and waiting-based repair.
- Plot:
  - field environment;
  - collaborative paths;
  - Pareto front;
  - convergence curve.

## What is intentionally simplified

This first-stage code is a runnable research prototype, not the full high-fidelity model described in the manuscript.

Not yet fully implemented:
- adaptive Theta* with prescription-map guidance;
- full Hybrid A* with vehicle kinematics;
- Reeds–Shepp correction;
- dynamic UAV mass decay based on rotor momentum theory;
- detailed UGV soil-resistance energy model;
- local replanning conflict repair;
- full baseline suite.

These modules are left as clean interfaces so they can be strengthened step by step.

## How to run

1. Put `wkt.zip` into:

```text
TNSAOO_Agri_UAV_UGV_stage1/data/wkt.zip
```

or unzip it so the WKT folder is:

```text
TNSAOO_Agri_UAV_UGV_stage1/data/wkt/
```

2. In MATLAB, set the current folder to `TNSAOO_Agri_UAV_UGV_stage1`.

3. Run:

```matlab
main
```

4. Results will be saved in:

```text
results/
```

## Recommended first run

The default configuration uses:

```matlab
cfg.data.fieldFileName = 'ee_field_14.wkt';
cfg.alg.popSize = 24;
cfg.alg.maxIter = 25;
```

For fast debugging, reduce:

```matlab
cfg.alg.popSize = 8;
cfg.alg.maxIter = 5;
```

## Folder structure

```text
main.m
config.m
src/
  generateEnvironment.m
  readFields2BenchmarkWKT.m
  readWKTPolygon.m
  lonLatToLocalXY.m
  samplePointsInPolygon.m
  createCircularZone.m
  generateRowSegmentsInPolygon.m
  initializePopulation.m
  decodeSolution.m
  tnsaooOptimizer.m
  evaluateSolution.m
  planUAVPath.m
  planUGVPath.m
  generateCoverageStripsInPolygon.m
  detectAndRepairConflicts.m
  trajectoryFromPath.m
  interpTrajectory.m
  computeObjectives.m
  computeMetrics.m
  nonDominatedSort.m
  crowdingDistance.m
  updateArchive.m
  thinkingInnovation.m
  dominatesIndividual.m
  betterIndividual.m
  selectCompromiseSolution.m
  pathLength.m
  clampPosition.m
  plotEnvironment.m
  plotPaths.m
  plotParetoFront.m
  plotConvergence.m
  saveResults.m
  runBaselines.m
data/
  README_data.md
results/
```


## Stage-1 v1.3 update

This version adds:

- depot co-location filtering in air–ground conflict detection;
- robust conflict metrics with both raw and effective minimum distances;
- clearer fixed-color path visualization;
- less overlapping text labels;
- `runSingleCase.m` for quick debugging;
- best metrics and best schedule CSV export.

Run quick debugging:

```matlab
runSingleCase
```

Run normal experiment:

```matlab
main
```


## Stage-1 v1.4 update

This version adds two major improvements:

1. **Original-AOO-formula-adapted TNSAOO update**
   - `aooUpdateCandidate.m`
   - `initAOOState.m`
   - `levyFlight.m`
   - `boundaryRecall.m`
   - `thinkingInnovation.m`

   The original AOO is a single-objective continuous optimizer. In this project, its update equations are adapted to multi-objective random-key scheduling by replacing the scalar best solution with a Pareto-archive elite solution.

2. **Batch experiment framework**
   - `runBatchFields.m`
   - `listFields2Benchmark.m`
   - `summarizeBatchResults.m`
   - `plotBatchStatistics.m`

Quick batch test:

```matlab
runBatchFields
```

Recommended debug settings in `config.m`:

```matlab
cfg.batch.numFields = 3;
cfg.batch.seeds = [2026];
cfg.batch.fastPopSize = 8;
cfg.batch.fastMaxIter = 5;
```

Formal experiments can later increase these values.


## Stage-1 v1.4.1 patch

This patch fixes a MATLAB batch-record struct assignment error:

```text
在不同结构体之间进行下标赋值。
```

The batch framework now uses a fixed record template and robust append function.

New helper files:

```text
src/batchRecordTemplate.m
src/appendBatchRecord.m
src/standardizeBatchRecord.m
```


## Stage-1 v1.4.2 patch

This patch fixes the scalar struct-to-table error in `runBatchFields.m`:

```text
输入结构体为标量，但其字段的行数不同。如果您想创建一个包含一行的表，请将 'AsArray' 设置为 true。
```

The batch scripts now use:

```matlab
struct2table(records, 'AsArray', true)
```

and store text fields as string scalars.


## Stage-1 v1.4.3 patch

This patch is a static-review hardening update for the batch framework:

- centralized batch record conversion with `recordsToTable.m`;
- safer `summarizeBatchResults.m`;
- safer `plotBatchStatistics.m`;
- `subplot` fallback for older MATLAB versions;
- best metrics CSV export uses `struct2table(...,'AsArray',true)`.


## Stage-1 v1.4.4 patch

This is a static-review hardening patch after v1.4.3.

Main changes:

- complete self-contained batch patch package;
- `safeGetReport.m` for robust error logging;
- `strrep` replaces `erase` in `runBatchFields.m`;
- removed `extractBefore` dependency in batch field/country parsing;
- updated `manifest.json`.

Recommended command:

```matlab
runBatchFields
```


## Stage-1 v1.5 update

This version adds ablation and baseline experiments.

Run:

```matlab
runAblationBatch
```

Default compared methods:

- `FullTNSAOO`
- `NoTIS`
- `SimpleAOO`
- `Independent`

Outputs are saved to:

```text
results/ablation_yyyymmdd_HHMMSS/
```

Key files:

```text
ablation_results_raw.csv
summary_by_method.csv
summary_by_field_method.csv
ablation_objective_means.png
ablation_conflict_runtime.png
```

## Chapter 5.1 Experiment v1.0 update

This update is prepared for the figure group used in Chapter 5.1 of the paper.

New features:

- irregular localized prescription patches are used instead of only circular zones;
- added `runChapter51Experiment.m` to generate two separate figures:
  1. the real field boundary only;
  2. the synthetic prescription scenario;
- added `plotFieldBoundaryOnly.m` and `saveFigureFiles.m`.

Run in MATLAB:

```matlab
runChapter51Experiment
```

The script saves files under:

```text
results/chapter5_1_yyyymmdd_HHMMSS/
```

Main outputs:

```text
figure_ch5_1_field_boundary_only.png
figure_ch5_1_synthetic_prescription.png
chapter5_1_environment.mat
```


## Chapter 5.2 Representative Cases v1.0

This version generates the figures and numerical table for Section 5.2.

Run:

```matlab
runChapter52RepresentativeCases
```

The four representative fields are fixed as:

```text
ee_field_9.wkt
lt_field_258.wkt
lt_field_137.wkt
nl_field_54.wkt
```

The default case-study optimization settings are:

```matlab
cfg.chapter52.popSize = 20;
cfg.chapter52.maxIter = 20;
cfg.chapter52.seed = 2026;
```

Main outputs:

```text
representative_case_results.csv
figure_ch5_2_representative_scenarios.png
figure_ch5_2_representative_paths.png
figure_ch5_2_pareto_convergence_case_01.png
case_01_scenario.png ... case_04_scenario.png
case_01_paths.png ... case_04_paths.png
```

The Pareto/convergence figure has been redesigned for publication use. Instead of a cluttered raw 3D scatter plot, it shows a normalized Pareto archive distribution with drift penalty encoded by color and a normalized convergence plot for the three objectives.


## Chapter 5.2 Representative Cases v1.1

This patch fixes a critical scenario-consistency issue.

Obstacle regions are now generated before prescription patches. The operable region is computed as the real field boundary minus obstacle regions. Therefore, localized spraying and fertilization prescription patches, crop rows, depot, and refill stations are generated only in obstacle-free regions.

UAV and UGV transfer paths are also routed using a lightweight obstacle-aware visibility planner so that plotted paths do not directly pass through obstacle regions.

Important limitation: the new transfer planner is still a simplified stage-1 planner. It is intended to remove logically invalid obstacle crossings in the current figures and metrics, but it is not a full replacement for the later adaptive Theta*/Hybrid A* implementation.


## Chapter 5.2 Representative Cases v1.2

This version corrects two important modeling issues.

First, same-type prescription patches are now non-overlapping. Spraying patches do not overlap other spraying patches, and fertilization patches do not overlap other fertilization patches. Cross-type overlap between spraying and fertilization is still allowed because a local area may reasonably require both operations.

Second, the lower-layer transfer planner is upgraded. UAV transfer uses a grid-based any-angle Theta*-style planner, while UGV transfer uses a row-constrained grid A* planner. Both avoid obstacles and field exterior.

The result table now includes geometry validation fields so users can check whether obstacle overlap and same-type patch overlap constraints are satisfied.


## Chapter 5.2 Representative Cases v1.3_fast

This version is the practical fast version for Chapter 5.2.

It preserves the geometry corrections:
- no obstacle-task overlap;
- no spraying-spraying overlap;
- no fertilization-fertilization overlap;
- spraying-fertilization overlap allowed.

It restores the fast lightweight obstacle-aware visibility transfer planner instead of the slow grid-based Theta*/row-A* transfer planner from v1.2.


## Chapter 5.2 Representative Cases v1.4_two_cases

This supplemental version only runs two cases:

```text
Case 1: ee_field_9.wkt
Case 2: lt_field_119.wkt
```

It adds a fixed known obstacle for the internal tree/woodland patch visible in the satellite image of `ee_field_9.wkt`. The known obstacle is subtracted from the operable/croppable region before generating spraying and fertilization prescription patches.

Run:

```matlab
runChapter52RepresentativeCases
```

Main outputs are saved under:

```text
results/chapter5_2_two_cases_supplement_yyyymmdd_HHMMSS/
```
