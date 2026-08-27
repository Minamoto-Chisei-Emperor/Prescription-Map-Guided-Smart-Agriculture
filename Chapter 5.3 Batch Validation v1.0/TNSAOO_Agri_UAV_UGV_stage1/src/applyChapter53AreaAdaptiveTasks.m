function cfg = applyChapter53AreaAdaptiveTasks(cfg, area_m2)
%APPLYCHAPTER53AREAADAPTIVETASKS Set scenario complexity by field area.

if area_m2 < cfg.chapter53.smallAreaThreshold_m2
    cfg.env.nSprayTasks = 4;
    cfg.env.nFertTasks = 4;
    cfg.env.nObstacles = 1;
    cfg.env.nRefillCandidates = 3;
elseif area_m2 < cfg.chapter53.largeAreaThreshold_m2
    cfg.env.nSprayTasks = 6;
    cfg.env.nFertTasks = 6;
    cfg.env.nObstacles = 2;
    cfg.env.nRefillCandidates = 4;
else
    cfg.env.nSprayTasks = 8;
    cfg.env.nFertTasks = 8;
    cfg.env.nObstacles = 3;
    cfg.env.nRefillCandidates = 5;
end
end
