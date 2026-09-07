# Prescription-Map-Guided Smart Agriculture

**Prescription-Map-Guided Bi-Level Multi-Objective Path Planning for UAV-UGV Collaborative Spraying and Fertilization in Smart Agriculture**

<p align="center">
  <a href="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture">
    <img src="https://img.shields.io/badge/MATLAB-R2021b%2B-0076A8?logo=mathworks&logoColor=white" alt="MATLAB">
  </a>
  <img src="https://img.shields.io/badge/Research%20prototype-Stage--1-orange" alt="Research prototype">
  <img src="https://img.shields.io/badge/Precision%20agriculture-UAV--UGV-2E8B57" alt="Precision agriculture">
</p>

> A reproducible MATLAB research prototype for coordinating UAV spraying and UGV fertilization under prescription-map demands, heterogeneous vehicle constraints, multi-objective optimization, and air-ground safety requirements.

本项目面向智慧农业中的变量施药与变量施肥任务，研究如何在不规则真实农田边界内，对无人机（UAV）与无人地面车辆（UGV）进行协同任务排序、路径规划、补给点选择和时空冲突处理。

## Why this project / 研究问题

Most agricultural planning studies optimize aerial spraying or ground fertilization separately. This project treats them as one heterogeneous air-ground system and jointly considers:

- localized spraying and fertilization demands from prescription maps;
- UAV payload, battery, flight and drift-related costs;
- UGV crop-row, obstacle and turning constraints;
- refill-station activation and task ordering;
- time-window synchronization and air-ground conflict avoidance;
- the trade-off among makespan, weighted energy consumption and pesticide-drift penalty.

现有研究通常将无人机喷洒和地面机器人施肥分开规划。本项目将二者建模为统一的空地协同系统，同时考虑处方图任务需求、载荷与电量、农田障碍、作物行方向、补给点、同步约束和农药漂移风险。

## Research architecture / 方法框架

```text
Real farmland boundary + simulated prescription scenario
                    |
                    v
      Upper level: TNSAOO multi-objective scheduling
      - UAV/UGV task sequences
      - refill-station activation
      - Pareto archive and constraint handling
                    |
                    v
      Lower level: heterogeneous path generation
      - UAV coverage strips and prescription-guided transitions
      - UGV row-constrained fertilization paths
      - timestamped trajectories
                    |
                    v
      Air-ground conflict detection and wait/local-repair correction
                    |
                    v
      Makespan | weighted energy | drift penalty | coverage | safety
```

The manuscript-level framework uses a prescription-map-guided adaptive Theta* planner for UAV transitions, a row-constrained Hybrid A* planner for UGV motion, dynamic UAV-load energy modelling, and time-window conflict correction. The public repository currently contains a staged implementation of these ideas; see [Implementation status](#implementation-status--当前实现状态).

## What is included / 仓库内容

| Package | Purpose | Main entry point |
|---|---|---|
| `Chapter 5.1 Experiment v1.0` | Real field boundary and synthetic prescription scenarios | `runChapter51Experiment.m` |
| `Chapter 5.2 Representative Cases v1.4_two_cases` | Four representative field cases, paths and Pareto/convergence figures | `runChapter52RepresentativeCases.m` |
| `Chapter 5.3 Batch Validation v1.0` | Multi-field batch validation and summary statistics | `runChapter53BatchValidation.m` or `runBatchFields.m` |
| `Chapter 5.4 Algorithm Comparison v1.0.zip` | TNSAOO, NSGA-II, MOPSO, NSWOA and MOEA/D comparison | `runChapter54AlgorithmComparison.m` after extraction |
| `Chapter_5_5_Ablation_Sensitivity_Project_v1_1.zip` | Ablation study, TIS sensitivity and safety-distance sensitivity | `runChapter55AblationSensitivity.m` after extraction |

The code is organized around reusable MATLAB functions for environment generation, WKT parsing, scheduling, path planning, objective evaluation, conflict detection, result export and publication-style plotting.

## Selected results reported in the manuscript / 论文报告的代表性结果

The simulation study uses 30 real farmland boundaries from the Fields2Benchmark data and 90 randomized prescription scenarios. Reported batch statistics include:

| Metric | Mean |
|---|---:|
| UAV spraying coverage | 98.82% |
| UGV fertilization coverage | 98.95% |
| Makespan | 1041.32 s |
| Weighted energy | 68.02 |
| Drift penalty | 336.83 |
| Total UAV + UGV path length | 2158.66 m |
| Air-ground conflict count | 0.36 |
| Conflict-repair waiting time | 1.07 s |

Across the 90 batch experiments, 100% of scenarios generated feasible collaborative plans, and 96.7% of experiments had no more than one detected air-ground conflict. These numbers are manuscript simulation results, not claims of field or hardware validation.

## Quick start / 快速运行

### Requirements

- MATLAB R2021b or newer is recommended.
- No third-party MATLAB toolbox is required by the stage-1 scripts beyond functions available in a standard MATLAB installation; some advanced extensions may benefit from additional toolboxes.
- The repository does not include the full dataset because of file-size and redistribution constraints.

### 1. Obtain the field-boundary data

The code expects Fields2Benchmark WKT files under a project-local `data/wkt/` directory. Copy the data from your local dataset directory into the corresponding experiment folder, or create a symbolic/junction link if preferred.

Expected layout:

```text
<experiment-root>/
├─ main.m
├─ config.m
├─ src/
└─ data/
   └─ wkt/
      ├─ ee_field_9.wkt
      ├─ lt_field_258.wkt
      └─ ...
```

The tracked `data/README_data.md` contains the same data-placement note. The original local working copy used for development was:

```text
D:\桌面\郭奉孝\新Paper-智慧农业空地协同\GitHub\data
```

This path is machine-specific and is provided only as a local reference; do not hard-code it in MATLAB scripts intended for other machines.

### 2. Run a fast single-case check

Open one experiment folder in MATLAB and set it as the current folder:

```matlab
runSingleCase
```

For a normal stage-1 run:

```matlab
main
```

Results are written to a timestamped folder under `results/`.

### 3. Run the chapter experiments

```matlab
% Chapter 5.1: field boundary and prescription scenario
runChapter51Experiment

% Chapter 5.2: representative cases
runChapter52RepresentativeCases

% Chapter 5.3: batch validation
runChapter53BatchValidation

% Chapter 5.4: algorithm comparison
% Extract Chapter 5.4 ZIP first, then run from its MATLAB project root
runChapter54AlgorithmComparison

% Chapter 5.5: ablation and sensitivity analysis
% Extract Chapter 5.5 ZIP first, then run from its MATLAB project root
runChapter55AblationSensitivity
```

For debugging, reduce population size and iteration count in `config.m`, for example:

```matlab
cfg.alg.popSize = 8;
cfg.alg.maxIter = 5;
```

Formal runs should use the chapter-specific settings documented in the corresponding package README files.

## Data and reproducibility / 数据与复现说明

The field geometries are based on real parcel boundaries from Fields2Benchmark. The public dataset used in the experiments is not bundled in this repository because it is too large for convenient GitHub distribution and may be subject to dataset-specific sharing conditions.

Important distinction:

- real data: farmland parcel boundaries in WKT format;
- simulated data: prescription patches, crop-row structure, obstacles, refill candidates and depot locations generated inside the real boundaries;
- simulation outputs: paths, schedules, objective values, coverage statistics and conflict metrics generated by MATLAB.

This distinction is important when interpreting the paper results: the study is simulation-based and does not yet constitute field hardware validation.

## Implementation status / 当前实现状态

This repository is intentionally transparent about its development stage.

Implemented or supported by the current staged codebase:

- real-field WKT parsing and longitude/latitude to local planar coordinates;
- synthetic localized prescription scenarios inside valid field regions;
- UAV and UGV task sequencing with random-key/ROV-style decoding;
- Pareto archive, non-dominated sorting, crowding distance and TNSAOO-style updates;
- UAV coverage-strip generation and UGV row-guided coverage;
- obstacle-aware transfer paths in the stage-1 experiment packages;
- timestamped air-ground conflict detection and waiting-based correction;
- batch validation, algorithm comparison, ablation and parameter sensitivity workflows;
- CSV/MAT result export and publication-style figure generation.

The following manuscript-level components are still being refined or simplified in parts of the public prototype:

- full prescription-map-guided adaptive Theta* implementation;
- full kinematic Hybrid A* and Reeds-Shepp turning correction;
- dynamic UAV mass decay and rotor-momentum energy integration;
- detailed UGV terrain/soil-resistance energy modelling;
- complete local replanning under repeated air-ground conflicts;
- hardware-in-the-loop and field experiments.

The separation between implemented modules and research targets is deliberate so that the repository remains reproducible and technically honest.

## Project structure / 项目结构

```text
Prescription-Map-Guided-Smart-Agriculture/
├─ Chapter 5.1 Experiment v1.0/
├─ Chapter 5.2 Representative Cases v1.4_two_cases/
├─ Chapter 5.3 Batch Validation v1.0/
├─ Chapter 5.4 Algorithm Comparison v1.0.zip
├─ Chapter_5_5_Ablation_Sensitivity_Project_v1_1.zip
└─ README.md
```

Each experiment package contains a `main.m`/chapter entry script, `config.m`, a `src/` function library, a `data/` note and a `results/` output convention. The ZIP packages are preserved as self-contained release snapshots for the later chapters.

## Paper / 论文

**Prescription-Map-Guided Bi-Level Multi-Objective Path Planning for UAV-UGV Collaborative Spraying and Fertilization in Smart Agriculture**  
Authors: Shiyang Li, Jisong Lv, Yuchen Lu and Yuxuan Zhang.

The manuscript PDF/Word source is not redistributed here by default. Please add the final paper link, DOI or preprint URL below when available:

```text
Paper / DOI / Preprint: [add link here]
```

## Citation / 引用

If you use this code or build on the modelling framework, please cite the associated paper once the bibliographic information is finalized:

```bibtex
@article{li_prescription_map_guided,
  title   = {Prescription-Map-Guided Bi-Level Multi-Objective Path Planning for UAV-UGV Collaborative Spraying and Fertilization in Smart Agriculture},
  author  = {Li, Shiyang and Lv, Jisong and Lu, Yuchen and Zhang, Yuxuan},
  journal = {To be updated},
  year    = {2026}
}
```

## Contact / 联系方式

For research collaboration, reproducibility questions or PhD/MPhil supervision discussions, please contact:

```text
Name: [Your Name]
Email: [your.email@example.com]
Research interests: precision agriculture, agricultural robotics, UAV-UGV collaboration, multi-objective optimization
```

## License

No open-source license has been selected yet. Until a license is added, please treat the code as research material and contact the author before redistribution or commercial use.

---

## 中文项目简介

这是一个面向智慧农业空地协同作业的 MATLAB 研究代码仓库，围绕“处方图引导的无人机喷洒 + 无人地面车辆施肥”展开。项目使用真实农田地块边界，并在其内部生成仿真的局部施药/施肥处方区域、障碍、作物行、补给候选点和作业基地，从而研究不规则农田中的协同调度与路径规划。

项目的核心特点包括：

- 上层使用 TNSAOO 进行 UAV/UGV 任务顺序与补给点激活决策；
- 下层分别生成 UAV 覆盖路径和 UGV 作物行约束路径；
- 联合优化完工时间、加权能耗和漂移惩罚；
- 使用时间戳轨迹检测空地接近风险，并通过等待或局部修正处理冲突；
- 提供代表性案例、批量验证、算法对比、消融实验和敏感性分析。

如果你是潜在导师，可以优先查看以下内容：

1. `Chapter 5.2 Representative Cases...`：了解典型农田场景、路径和 Pareto 结果；
2. `Chapter 5.3 Batch Validation...`：了解多地块稳定性与规模适应性；
3. `Chapter 5.4 Algorithm Comparison...`：了解与 NSGA-II、MOPSO、NSWOA、MOEA/D 的公平对比；
4. `Chapter 5.5 Ablation...`：了解 TIS 策略和安全距离参数的作用；
5. `src/`：查看环境生成、目标函数、路径规划、冲突检测和结果导出等实现。

数据集没有直接上传 GitHub。真实地块边界可以按照上面的 `data/wkt/` 结构放置；处方图、障碍和作物行等部分在当前研究中属于仿真生成内容。README 中已经明确区分了真实数据、仿真数据和论文仿真结果，方便你把仓库发给导师时保持学术表述准确。
