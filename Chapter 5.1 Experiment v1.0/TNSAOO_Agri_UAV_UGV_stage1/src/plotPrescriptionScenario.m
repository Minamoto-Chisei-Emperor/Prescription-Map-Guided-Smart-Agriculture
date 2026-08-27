function handles = plotPrescriptionScenario(env, cfg)
%PLOTPRESCRIPTIONSCENARIO Plot synthetic prescription scenario for Chapter 5.1.
%
% This function generates the third panel of the Chapter 5.1 figure:
% real field boundary + localized spraying/fertilization prescription
% patches + candidate refill stations + obstacle regions + crop-row
% direction. It does not plot optimized UAV/UGV paths.

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
    'EdgeColor', colorFieldEdge, 'LineWidth', 1.8);

% Crop rows are drawn behind patches.
handles.cropRows = gobjects(0);
if cfg.plot.showCropRows && isfield(env,'cropRows')
    for k = 1:numel(env.cropRows)
        p = [env.cropRows(k).start; env.cropRows(k).end];
        h = plot(p(:,1), p(:,2), ':', 'Color', colorRows, 'LineWidth', 0.55);
        handles.cropRows(end+1) = h; %#ok<AGROW>
    end
end

% Obstacles.
handles.obstacles = gobjects(0);
for k = 1:numel(env.obstacles)
    h = plot(env.obstacles(k), ...
        'FaceColor', colorObstacle, 'FaceAlpha', 0.55, ...
        'EdgeColor', [0.18 0.18 0.18], 'LineWidth', 0.8);
    handles.obstacles(end+1) = h; %#ok<AGROW>
end

% Spraying prescription patches.
handles.sprayZones = gobjects(0);
for k = 1:numel(env.sprayTasks)
    h = plot(env.sprayTasks(k).zone, ...
        'FaceColor', colorSpray, 'FaceAlpha', 0.20, ...
        'EdgeColor', colorSpray, 'LineWidth', 0.95);
    handles.sprayZones(end+1) = h; %#ok<AGROW>
    if cfg.plot.showTaskLabels
        addLabel(env.sprayTasks(k).center, sprintf('U%d',k), cfg, colorSpray);
    end
end

% Fertilization prescription patches.
handles.fertZones = gobjects(0);
for k = 1:numel(env.fertTasks)
    h = plot(env.fertTasks(k).zone, ...
        'FaceColor', colorFert, 'FaceAlpha', 0.22, ...
        'EdgeColor', colorFert, 'LineWidth', 0.95);
    handles.fertZones(end+1) = h; %#ok<AGROW>
    if cfg.plot.showTaskLabels
        addLabel(env.fertTasks(k).center, sprintf('G%d',k), cfg, colorFert);
    end
end

% Candidate refill stations.
handles.refill = gobjects(0);
for k = 1:numel(env.refillStations)
    c = env.refillStations(k).center;
    h = scatter(c(1), c(2), 76, colorRefill, '^', ...
        'filled', 'MarkerEdgeColor','k');
    handles.refill(end+1) = h; %#ok<AGROW>
    if cfg.plot.showTaskLabels
        addLabel(c, sprintf('R%d',k), cfg, colorRefill);
    end
end

% Depot/base.
handles.depot = scatter(env.depot(1), env.depot(2), 100, colorDepot, '*', ...
    'LineWidth', 1.4);
if cfg.plot.showTaskLabels
    addLabel(env.depot, 'Depot', cfg, colorDepot);
end

xlabel('X (m)');
ylabel('Y (m)');


title(sprintf('Synthetic prescription scenario: %s', env.field.name), ...
    'Interpreter','none', ...
    'FontName','Times New Roman', ...
    'FontSize',20, ...
    'FontWeight','bold');


legendHandles = handles.field;
legendNames = {'Real field boundary'};

if ~isempty(handles.sprayZones)
    legendHandles(end+1) = handles.sprayZones(1); %#ok<AGROW>
    legendNames{end+1} = 'Spraying prescription patch'; %#ok<AGROW>
end
if ~isempty(handles.fertZones)
    legendHandles(end+1) = handles.fertZones(1); %#ok<AGROW>
    legendNames{end+1} = 'Fertilization prescription patch'; %#ok<AGROW>
end
if ~isempty(handles.obstacles)
    legendHandles(end+1) = handles.obstacles(1); %#ok<AGROW>
    legendNames{end+1} = 'Obstacle region'; %#ok<AGROW>
end
if ~isempty(handles.refill)
    legendHandles(end+1) = handles.refill(1); %#ok<AGROW>
    legendNames{end+1} = 'Candidate refill station'; %#ok<AGROW>
end
legendHandles(end+1) = handles.depot;
legendNames{end+1} = 'Depot';

legend(legendHandles, legendNames, 'Location','bestoutside');
hold off;
end

function addLabel(pos, labelStr, cfg, colorVal)
offset = cfg.plot.labelOffset;
text(pos(1)+offset(1), pos(2)+offset(2), labelStr, ...
    'Color', colorVal, 'FontSize', 9, 'FontWeight','bold', ...
    'BackgroundColor', 'w', 'Margin', 0.5, 'Clipping','on');
end
