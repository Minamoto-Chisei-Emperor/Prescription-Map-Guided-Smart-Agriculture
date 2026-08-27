function handles = plotScenarioPanel(env, cfg, caseTitle, showLegend)
%PLOTSCENARIOPANEL Plot one representative prescription scenario panel.
%
% This panel shows the real field boundary, synthetic localized
% prescription patches, candidate refill stations, obstacle regions,
% crop-row direction, and depot. It does not show optimized UAV/UGV paths.

if nargin < 3 || isempty(caseTitle)
    caseTitle = env.field.name;
end
if nargin < 4
    showLegend = true;
end

hold on; axis equal; box on; grid on;
handles = struct();

colorFieldEdge = [0.00 0.35 0.00];
colorFieldFace = [0.93 0.98 0.93];
colorSpray = [0.10 0.45 0.95];
colorFert = [0.95 0.58 0.05];
colorObstacle = [0.42 0.42 0.42];
colorRefill = [0.10 0.10 0.10];
colorDepot = [0.00 0.00 0.00];
colorRows = [0.70 0.70 0.70];

handles.field = plot(env.field.poly, ...
    'FaceColor', colorFieldFace, 'FaceAlpha', 0.45, ...
    'EdgeColor', colorFieldEdge, 'LineWidth', 1.6);

handles.cropRows = gobjects(0);
if cfg.plot.showCropRows && isfield(env,'cropRows')
    for k = 1:numel(env.cropRows)
        p = [env.cropRows(k).start; env.cropRows(k).end];
        h = plot(p(:,1), p(:,2), ':', 'Color', colorRows, 'LineWidth', 0.45);
        handles.cropRows(end+1) = h; %#ok<AGROW>
    end
end

handles.obstacles = gobjects(0);
for k = 1:numel(env.obstacles)
    h = plot(env.obstacles(k), 'FaceColor', colorObstacle, 'FaceAlpha', 0.55, ...
        'EdgeColor', [0.18 0.18 0.18], 'LineWidth', 0.8);
    handles.obstacles(end+1) = h; %#ok<AGROW>
end

handles.sprayZones = gobjects(0);
for k = 1:numel(env.sprayTasks)
    h = plot(env.sprayTasks(k).zone, ...
        'FaceColor', colorSpray, 'FaceAlpha', 0.20, ...
        'EdgeColor', colorSpray, 'LineWidth', 0.85);
    handles.sprayZones(end+1) = h; %#ok<AGROW>
    if cfg.plot.showTaskLabels
        addLabel(env.sprayTasks(k).center, sprintf('U%d',k), cfg, colorSpray);
    end
end

handles.fertZones = gobjects(0);
for k = 1:numel(env.fertTasks)
    h = plot(env.fertTasks(k).zone, ...
        'FaceColor', colorFert, 'FaceAlpha', 0.22, ...
        'EdgeColor', colorFert, 'LineWidth', 0.85);
    handles.fertZones(end+1) = h; %#ok<AGROW>
    if cfg.plot.showTaskLabels
        addLabel(env.fertTasks(k).center, sprintf('G%d',k), cfg, colorFert);
    end
end

handles.refill = gobjects(0);
for k = 1:numel(env.refillStations)
    c = env.refillStations(k).center;
    h = scatter(c(1), c(2), 60, colorRefill, '^', ...
        'filled', 'MarkerEdgeColor','k');
    handles.refill(end+1) = h; %#ok<AGROW>
    if cfg.plot.showTaskLabels
        addLabel(c, sprintf('R%d',k), cfg, colorRefill);
    end
end

handles.depot = scatter(env.depot(1), env.depot(2), 85, colorDepot, '*', ...
    'LineWidth', 1.3);
if cfg.plot.showTaskLabels
    addLabel(env.depot, 'Depot', cfg, colorDepot);
end

xlabel('X (m)');
ylabel('Y (m)');
title(caseTitle, 'Interpreter','none');

if showLegend
    legendHandles = handles.field;
    legendNames = {'Field boundary'};
    if ~isempty(handles.sprayZones)
        legendHandles(end+1) = handles.sprayZones(1); %#ok<AGROW>
        legendNames{end+1} = 'Spraying patch'; %#ok<AGROW>
    end
    if ~isempty(handles.fertZones)
        legendHandles(end+1) = handles.fertZones(1); %#ok<AGROW>
        legendNames{end+1} = 'Fertilization patch'; %#ok<AGROW>
    end
    if ~isempty(handles.obstacles)
        legendHandles(end+1) = handles.obstacles(1); %#ok<AGROW>
        legendNames{end+1} = 'Obstacle'; %#ok<AGROW>
    end
    if ~isempty(handles.refill)
        legendHandles(end+1) = handles.refill(1); %#ok<AGROW>
        legendNames{end+1} = 'Refill candidate'; %#ok<AGROW>
    end
    legendHandles(end+1) = handles.depot;
    legendNames{end+1} = 'Depot';
    legend(legendHandles, legendNames, 'Location','bestoutside');
end

hold off;
end

function addLabel(pos, labelStr, cfg, colorVal)
offset = cfg.plot.labelOffset;
text(pos(1)+offset(1), pos(2)+offset(2), labelStr, ...
    'Color', colorVal, 'FontSize', 8.5, 'FontWeight','bold', ...
    'BackgroundColor', 'w', 'Margin', 0.4, 'Clipping','on');
end
