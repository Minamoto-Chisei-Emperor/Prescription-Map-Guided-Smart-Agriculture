function handles = plotPathsPaper(env, best, cfg, caseTitle, showLegend)
%PLOTPATHSPAPER Plot optimized UAV and UGV paths in a paper-style panel.

if nargin < 4 || isempty(caseTitle)
    caseTitle = env.field.name;
end
if nargin < 5
    showLegend = true;
end

handles = plotScenarioPanel(env, cfg, caseTitle, false);
hold on;

uPath = best.details.uavPlan.path;
gPath = best.details.ugvPlan.path;

colorUAV = [0.00 0.30 0.85];
colorUGV = [0.55 0.10 0.70];
colorActiveRefill = [0.85 0.10 0.10];

hUAV = plot(uPath(:,1), uPath(:,2), '-', ...
    'Color', colorUAV, 'LineWidth', cfg.plot.pathLineWidth + 0.8);
hUGV = plot(gPath(:,1), gPath(:,2), '--', ...
    'Color', colorUGV, 'LineWidth', cfg.plot.pathLineWidth + 0.8);

hActive = gobjects(0);
active = best.decoded.activeRefillIds;
for k = active
    c = env.refillStations(k).center;
    h = scatter(c(1), c(2), 115, colorActiveRefill, 'd', 'filled', ...
        'MarkerEdgeColor','k', 'LineWidth', 1.0);
    hActive(end+1) = h; %#ok<AGROW>
end

title(caseTitle, 'Interpreter','none');

if showLegend
    legendHandles = [handles.field, hUAV, hUGV];
    legendNames = {'Field boundary','UAV path','UGV path'};
    if ~isempty(hActive)
        legendHandles(end+1) = hActive(1); %#ok<AGROW>
        legendNames{end+1} = 'Active refill'; %#ok<AGROW>
    end
    legend(legendHandles, legendNames, 'Location','bestoutside');
end

hold off;
end
