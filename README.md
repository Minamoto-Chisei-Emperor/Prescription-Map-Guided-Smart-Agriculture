# Prescription-Map-Guided Smart Agriculture

**Prescription-Map-Guided Bi-Level Multi-Objective Path Planning for UAV-UGV Collaborative Spraying and Fertilization in Smart Agriculture**

<p align="center">
  <img src="https://img.shields.io/badge/MATLAB-R2021b%2B-0076A8?logo=mathworks&logoColor=white" alt="MATLAB">
  <img src="https://img.shields.io/badge/Precision%20Agriculture-UAV--UGV-2E8B57" alt="Precision agriculture">
  <img src="https://img.shields.io/badge/Study-Simulation--based-orange" alt="Simulation based study">
</p>

> A research project on prescription-map-guided coordination of UAV spraying and UGV fertilization in irregular agricultural fields.

本项目研究智慧农业中的无人机（UAV）精准喷洒与无人地面车辆（UGV）精准施肥协同规划问题。项目将真实农田地块边界、局部处方任务、车辆约束、补给决策和空地时空安全统一到一个双层多目标规划框架中。

## Project at a glance / 项目概览

Most existing agricultural path-planning studies optimize aerial spraying or ground fertilization separately. This work models them as one heterogeneous air-ground system and jointly optimizes:

- prescription-map-driven local spraying and fertilization;
- UAV and UGV task sequences and refill-point activation;
- makespan, weighted energy consumption and pesticide-drift penalty;
- field boundaries, obstacles, crop-row constraints and vehicle mobility;
- timestamped air-ground synchronization and conflict correction.

现有研究往往分别规划无人机喷洒和地面机器人作业。本研究将两类平台放在同一个协同系统中，联合考虑处方图任务需求、任务顺序、补给点选择、完工时间、能耗、漂移风险以及空地冲突。

## From research question to system design / 从问题到系统设计

### 1. Why coordination matters / 为什么需要协同

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/01_independent_vs_coordinated.png" width="92%" alt="Independent and coordinated UAV-UGV operation modes">
</p>

Independent routes may be individually feasible while still causing redundant travel, poorly synchronized resupply, waiting and air-ground interference. The project therefore treats UAV and UGV planning as a coupled system.

### 2. Bi-level planning framework / 双层规划框架

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/02_bilevel_framework.png" width="92%" alt="Prescription-map-guided bi-level framework">
</p>

The upper layer makes discrete system-level decisions. The lower layer converts those decisions into executable heterogeneous paths and returns feasibility and operational feedback.

上层负责任务分配、访问顺序和补给点激活；下层负责将上层结果转化为具体的 UAV/UGV 路径，并反馈覆盖率、路径代价和可行性。

### 3. Upper-level multi-objective scheduling / 上层多目标调度

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/03_upper_tnsaoo_flow.png" width="78%" alt="TNSAOO upper-level flowchart">
</p>

TNSAOO combines random-key encoding, heterogeneous decoding, non-dominated sorting, an external Pareto archive, crowding-distance maintenance and a Thinking Innovation Strategy (TIS) for task-scheduling search.

### 4. Lower-level path generation / 下层异构路径生成

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/04_lower_path_planning.png" width="78%" alt="Lower-level heterogeneous path planning flowchart">
</p>

The manuscript-level design uses prescription-map-guided adaptive Theta* for UAV transitions and row-constrained Hybrid A* for UGV motion, followed by trajectory-level safety checks.

### 5. Air-ground conflict correction / 空地冲突修正

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/05_conflict_correction.png" width="92%" alt="Air-ground conflict detection and correction">
</p>

Timestamped trajectories are checked for proximity conflicts. Waiting, speed adjustment or local replanning can be used to restore the required safety distance.

## Experimental story / 实验设计与结果

### Real boundaries, simulated prescription scenarios / 真实地块边界与仿真处方场景

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/06_real_boundary_to_scenario.png" width="92%" alt="From real field boundary to synthetic prescription scenario">
</p>

The experiments use real farmland parcel boundaries from Fields2Benchmark. Because the benchmark provides parcel geometry rather than measured pest, nutrient or crop-row maps, localized prescription patches, obstacles, crop rows, refill candidates and depots are generated synthetically inside the real boundaries.

实验使用 Fields2Benchmark 的真实农田地块边界。需要特别区分：地块边界是真实数据，而处方区域、障碍、作物行、补给候选点和基地位置是用于构造协同任务的仿真数据。

### Representative field scenarios / 典型地块场景

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/07_case1_scenario.png" width="47%" alt="Case 1 prescription scenario">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/08_case2_scenario.png" width="47%" alt="Case 2 prescription scenario">
</p>
<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/09_case3_scenario.png" width="47%" alt="Case 3 prescription scenario">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/10_case4_scenario.png" width="47%" alt="Case 4 prescription scenario">
</p>

The four cases cover different field sizes, boundary shapes, internal non-operational areas and task distributions across Estonia, Lithuania and the Netherlands.

### Optimized UAV-UGV paths / 优化后的协同路径

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/11_case1_paths.png" width="47%" alt="Case 1 optimized paths">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/12_case2_paths.png" width="47%" alt="Case 2 optimized paths">
</p>
<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/13_case3_paths.png" width="47%" alt="Case 3 optimized paths">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/14_case4_paths.png" width="47%" alt="Case 4 optimized paths">
</p>

### Batch validation / 多地块批量验证

The manuscript reports 30 real farmland boundaries and 90 randomized prescription scenarios. The reported mean statistics are:

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

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/15_batch_objectives.png" width="92%" alt="Distribution of batch objective values">
</p>

Across the 90 batch experiments, all scenarios generated feasible collaborative plans. In 96.7% of experiments, the detected air-ground conflict count did not exceed one.

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/16_area_cost_relationships.png" width="92%" alt="Field area and collaborative-operation costs">
</p>

The results show a clear positive relationship between field area and operational cost, while boundary morphology and task distribution explain variation among fields of similar area.

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/17_conflict_statistics.png" width="78%" alt="Air-ground conflict and waiting-time statistics">
</p>

### Algorithm comparison / 多目标算法对比

The comparison package evaluates TNSAOO against NSGA-II, MOPSO, NSWOA and MOEA/D under a shared scenario, encoding, lower-level evaluation and computational budget.

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/18_algorithm_quality.png" width="78%" alt="HV and IGD comparison">
</p>
<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/19_algorithm_compromise.png" width="92%" alt="Compromise-solution objective comparison">
</p>

The paper interprets TNSAOO and NSGA-II as competitive overall Pareto-search methods, rather than claiming universal dominance by one optimizer.

### Ablation and sensitivity / 消融与敏感性分析

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/20_ablation.png" width="82%" alt="Ablation comparison">
</p>

The ablation study separates the effect of the TIS refinement mechanism from the effect of explicit joint UAV-UGV scheduling.

<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/21_tis_sensitivity.png" width="92%" alt="TIS probability sensitivity">
</p>
<p align="center">
  <img src="https://github.com/Minamoto-Chisei-Emperor/Prescription-Map-Guided-Smart-Agriculture/raw/main/assets/figures/22_safety_distance_sensitivity.png" width="92%" alt="Air-ground safety distance sensitivity">
</p>

The sensitivity experiments examine TIS probability values from 0.35 to 0.95 and air-ground safety distances from 2 m to 10 m. The results indicate that moderate-to-high TIS intensity and moderate safety distances often provide a practical trade-off, but the best setting remains scenario-dependent.

## Code organization / 代码组织

| Package | Focus | Entry point |
|---|---|---|
| `Chapter 5.1 Experiment v1.0` | Boundary and prescription-scenario figures | `runChapter51Experiment.m` |
| `Chapter 5.2 Representative Cases v1.4_two_cases` | Representative field cases and paths | `runChapter52RepresentativeCases.m` |
| `Chapter 5.3 Batch Validation v1.0` | Multi-field validation and statistics | `runChapter53BatchValidation.m` |
| `Chapter 5.4 Algorithm Comparison v1.0.zip` | TNSAOO vs. four multi-objective baselines | Extract, then run `runChapter54AlgorithmComparison.m` |
| `Chapter_5_5_Ablation_Sensitivity_Project_v1_1.zip` | Ablation and parameter sensitivity | Extract, then run `runChapter55AblationSensitivity.m` |

The repository contains research snapshots from different chapter stages. Some files are prototypes, intermediate versions or release bundles rather than a single polished software package.

## Minimal reproduction / 最小复现说明

1. Install MATLAB R2021b or newer.
2. Place the Fields2Benchmark WKT files under the experiment package's `data/wkt/` directory.
3. Open the desired experiment folder in MATLAB.
4. Run its chapter entry script or `runSingleCase` for a quick check.
5. Inspect the timestamped `results/` directory.

The full dataset is intentionally not committed to GitHub. The local development copy used the following machine-specific directory:

```text
D:\桌面\郭奉孝\新Paper-智慧农业空地协同\GitHub\data
```

Use a project-local relative path on other machines.

## Paper / 论文

**Prescription-Map-Guided Bi-Level Multi-Objective Path Planning for UAV-UGV Collaborative Spraying and Fertilization in Smart Agriculture**  
Authors: Shiyang Li, Jisong Lv, Yuchen Lu and Yuxuan Zhang.

Paper / DOI / preprint link: **to be added**

## Citation / 引用

```bibtex
@article{li_prescription_map_guided,
  title   = {Prescription-Map-Guided Bi-Level Multi-Objective Path Planning for UAV-UGV Collaborative Spraying and Fertilization in Smart Agriculture},
  author  = {Li, Shiyang and Lv, Jisong and Lu, Yuchen and Zhang, Yuxuan},
  journal = {To be updated},
  year    = {2026}
}
```

## Scope and current status / 研究范围与当前状态

This repository documents a simulation-based research project and its evolving MATLAB implementation. It should be read as a transparent research record, not as a production-ready agricultural autonomy stack. The reported results are simulation results; hardware-in-the-loop and field validation remain future work.

本仓库记录的是一个持续演进中的仿真研究项目及其 MATLAB 实现，不是面向生产部署的完整农业自动驾驶软件。论文中的实验结果属于仿真结果，硬件在环测试和真实田间验证属于后续工作。

## Contact / 联系方式

```text
Name: [Your Name]
Email: [your.email@example.com]
Research interests: precision agriculture, agricultural robotics, UAV-UGV collaboration, multi-objective optimization
```

## License

No open-source license has been selected yet. Until a license is added, please contact the author before redistribution or commercial use.



