function plotPaths(env, best, cfg)
%PLOTPATHS Plot UAV and UGV paths for the selected solution.

handles = plotEnvironment(env, cfg);
hold on;

uPath = best.details.uavPlan.path;
gPath = best.details.ugvPlan.path;

colorUAV = [0.00 0.35 0.85];
colorUGV = [0.55 0.15 0.70];
colorActiveRefill = [0.85 0.10 0.10];

hUAV = plot(uPath(:,1), uPath(:,2), '-', ...
    'Color', colorUAV, 'LineWidth', cfg.plot.pathLineWidth+0.8);
hUGV = plot(gPath(:,1), gPath(:,2), '--', ...
    'Color', colorUGV, 'LineWidth', cfg.plot.pathLineWidth+0.8);

hActive = gobjects(0);
active = best.decoded.activeRefillIds;
for k = active
    c = env.refillStations(k).center;
    h = scatter(c(1), c(2), 130, colorActiveRefill, 'd', 'filled', ...
        'MarkerEdgeColor','k', 'LineWidth',1.0);
    hActive(end+1) = h; %#ok<AGROW>
end

title(sprintf('Collaborative paths | Makespan %.1f s | Energy %.1f | Drift %.1f', ...
    best.objectives(1), best.objectives(2), best.objectives(3)));

legendHandles = [handles.field, hUAV, hUGV];
legendNames = {'Field','UAV path','UGV path'};
if ~isempty(hActive)
    legendHandles(end+1) = hActive(1);
    legendNames{end+1} = 'Active refill';
end
legend(legendHandles, legendNames, 'Location','bestoutside');

hold off;
end
