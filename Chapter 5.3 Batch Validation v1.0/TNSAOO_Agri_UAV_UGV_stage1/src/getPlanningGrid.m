function grid = getPlanningGrid(env, cfg)
%GETPLANNINGGRID Return cached planning grid or build one on demand.

if isfield(env, 'planningGrid') && ~isempty(env.planningGrid)
    grid = env.planningGrid;
else
    grid = buildPlanningGrid(env, cfg);
end
end
