function plotChapter53Figures(plotData, figDir)
%PLOTCHAPTER53FIGURES Publication-style figures for Chapter 5.3.
%
% All figures use Times New Roman, large labels, and a calm pastel palette.

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

palette = chapter53Palette();

plotObjectiveDistribution(plotData.objectiveData, figDir, palette);
plotAreaCostRelationship(plotData.areaData, figDir, palette);
plotShapeEfficiency(plotData.shapeData, figDir, palette);
plotConflictDistribution(plotData.conflictData, plotData.conflictHist, figDir, palette);
end

function plotObjectiveDistribution(T, figDir, palette)
fig = figure('Name','Chapter 5.3 objective distribution', 'Color','w', ...
    'Units','centimeters', 'Position',[2,2,28,10]);

try
    tiledlayout(1,3,'TileSpacing','compact','Padding','compact');
    ax1 = nexttile; drawBoxWithJitter(ax1, T.makespan, 'Makespan (s)', palette.blue);
    ax2 = nexttile; drawBoxWithJitter(ax2, T.weightedEnergy, 'Weighted energy', palette.teal);
    ax3 = nexttile; drawBoxWithJitter(ax3, T.driftPenalty, 'Drift penalty', palette.rose);
catch
    subplot(1,3,1); drawBoxWithJitter(gca, T.makespan, 'Makespan (s)', palette.blue);
    subplot(1,3,2); drawBoxWithJitter(gca, T.weightedEnergy, 'Weighted energy', palette.teal);
    subplot(1,3,3); drawBoxWithJitter(gca, T.driftPenalty, 'Drift penalty', palette.rose);
end

try
    sgtitle('Distribution of key optimization objectives over multiple field boundaries', ...
        'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
catch
end

applyChapter53FigureStyle(fig);
saveChapter53Figure(fig, figDir, 'figure_ch5_3_objective_distribution');
end

function plotAreaCostRelationship(T, figDir, palette)
fig = figure('Name','Chapter 5.3 area-cost relationship', 'Color','w', ...
    'Units','centimeters', 'Position',[2,2,28,12]);

try
    tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
    ax1 = nexttile;
    drawCountryScatterWithFit(ax1, T, 'area_ha', 'makespan_mean', ...
        'Field area (ha)', 'Mean makespan (s)', palette);
    title(ax1, '(a) Field area vs. makespan', 'FontName','Times New Roman', 'FontSize',16, 'FontWeight','bold');

    ax2 = nexttile;
    drawCountryScatterWithFit(ax2, T, 'area_ha', 'totalPathLength_mean', ...
        'Field area (ha)', 'Mean total path length (m)', palette);
    title(ax2, '(b) Field area vs. total path length', 'FontName','Times New Roman', 'FontSize',16, 'FontWeight','bold');
catch
    subplot(1,2,1);
    drawCountryScatterWithFit(gca, T, 'area_ha', 'makespan_mean', ...
        'Field area (ha)', 'Mean makespan (s)', palette);
    subplot(1,2,2);
    drawCountryScatterWithFit(gca, T, 'area_ha', 'totalPathLength_mean', ...
        'Field area (ha)', 'Mean total path length (m)', palette);
end

try
    sgtitle('Effects of field area on collaborative operation cost', ...
        'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
catch
end

applyChapter53FigureStyle(fig);
saveChapter53Figure(fig, figDir, 'figure_ch5_3_area_cost_relationship');
end

function plotShapeEfficiency(T, figDir, palette)
fig = figure('Name','Chapter 5.3 shape-efficiency relationship', 'Color','w', ...
    'Units','centimeters', 'Position',[2,2,28,12]);

try
    tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
    ax1 = nexttile;
    drawCountryScatterWithFit(ax1, T, 'shapeIndex', 'ugvPathLengthPerHa_mean', ...
        'Shape index', 'UGV path length per ha (m/ha)', palette);
    title(ax1, '(a) Shape index vs. UGV path efficiency', 'FontName','Times New Roman', 'FontSize',16, 'FontWeight','bold');

    ax2 = nexttile;
    drawCountryScatterWithFit(ax2, T, 'aspectRatio', 'makespanPerHa_mean', ...
        'Aspect ratio', 'Makespan per ha (s/ha)', palette);
    title(ax2, '(b) Aspect ratio vs. time efficiency', 'FontName','Times New Roman', 'FontSize',16, 'FontWeight','bold');
catch
    subplot(1,2,1);
    drawCountryScatterWithFit(gca, T, 'shapeIndex', 'ugvPathLengthPerHa_mean', ...
        'Shape index', 'UGV path length per ha (m/ha)', palette);
    subplot(1,2,2);
    drawCountryScatterWithFit(gca, T, 'aspectRatio', 'makespanPerHa_mean', ...
        'Aspect ratio', 'Makespan per ha (s/ha)', palette);
end

try
    sgtitle('Influence of field shape complexity on path efficiency', ...
        'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
catch
end

applyChapter53FigureStyle(fig);
saveChapter53Figure(fig, figDir, 'figure_ch5_3_shape_efficiency');
end

function plotConflictDistribution(T, conflictHist, figDir, palette)
fig = figure('Name','Chapter 5.3 conflict distribution', 'Color','w', ...
    'Units','centimeters', 'Position',[2,2,28,12]);

try
    tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
    ax1 = nexttile;
catch
    subplot(1,2,1);
    ax1 = gca;
end

bar(ax1, categorical(conflictHist.conflictCountBin), conflictHist.numberOfRuns, ...
    'FaceColor', palette.blue, 'EdgeColor', palette.darkBlue, 'LineWidth', 1.1);
xlabel(ax1, 'Conflict count', 'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
ylabel(ax1, 'Number of runs', 'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
title(ax1, '(a) Conflict count distribution', 'FontName','Times New Roman','FontSize',16,'FontWeight','bold');
grid(ax1, 'on'); box(ax1, 'on');

try
    ax2 = nexttile;
catch
    subplot(1,2,2);
    ax2 = gca;
end

wt = T.totalWaitingTime;
wt = wt(isfinite(wt));
if isempty(wt)
    wt = 0;
end

edges = unique([0, 1, 3, 6, 9, 12, max(15, ceil(max(wt)+3))]);
histogram(ax2, wt, edges, 'FaceColor', palette.teal, 'EdgeColor', palette.darkTeal, 'LineWidth', 1.1);
xlabel(ax2, 'Waiting time (s)', 'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
ylabel(ax2, 'Number of runs', 'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
title(ax2, '(b) Waiting-time distribution', 'FontName','Times New Roman','FontSize',16,'FontWeight','bold');
grid(ax2, 'on'); box(ax2, 'on');

try
    sgtitle('Distribution of UAV-UGV conflicts and repair cost', ...
        'FontName','Times New Roman','FontSize',18,'FontWeight','bold');
catch
end

applyChapter53FigureStyle(fig);
saveChapter53Figure(fig, figDir, 'figure_ch5_3_conflict_distribution');
end

function drawBoxWithJitter(ax, x, yLabel, colorVal)
x = double(x(:));
x = x(isfinite(x));
if isempty(x)
    x = NaN;
end

axes(ax); %#ok<LAXES>
hold(ax, 'on');

q1 = prctileLocal(x, 25);
q2 = prctileLocal(x, 50);
q3 = prctileLocal(x, 75);
iqrVal = q3 - q1;
lo = max(min(x), q1 - 1.5*iqrVal);
hi = min(max(x), q3 + 1.5*iqrVal);

boxX = [0.78, 1.22, 1.22, 0.78];
boxY = [q1, q1, q3, q3];
patch(ax, boxX, boxY, colorVal, 'FaceAlpha', 0.40, 'EdgeColor', colorVal*0.75, 'LineWidth', 1.5);
plot(ax, [0.78,1.22], [q2,q2], '-', 'Color', colorVal*0.65, 'LineWidth', 2.2);
plot(ax, [1,1], [lo,q1], '-', 'Color', colorVal*0.65, 'LineWidth', 1.5);
plot(ax, [1,1], [q3,hi], '-', 'Color', colorVal*0.65, 'LineWidth', 1.5);
plot(ax, [0.90,1.10], [lo,lo], '-', 'Color', colorVal*0.65, 'LineWidth', 1.5);
plot(ax, [0.90,1.10], [hi,hi], '-', 'Color', colorVal*0.65, 'LineWidth', 1.5);

rng(123);
jitter = 0.08*(rand(size(x))-0.5);
scatter(ax, 1+jitter, x, 34, 'MarkerFaceColor', colorVal, ...
    'MarkerEdgeColor', [0.25,0.25,0.25], 'MarkerFaceAlpha', 0.58, 'LineWidth', 0.45);

xlim(ax, [0.55,1.45]);
set(ax, 'XTick', []);
ylabel(ax, yLabel, 'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
grid(ax, 'on'); box(ax, 'on');
hold(ax, 'off');
end

function drawCountryScatterWithFit(ax, T, xName, yName, xLab, yLab, palette)
axes(ax); %#ok<LAXES>
hold(ax, 'on');

countries = string(T.country);
countryList = unique(countries, 'stable');

for i = 1:numel(countryList)
    c = countryList(i);
    idx = countries == c;
    col = countryColor(c, palette);
    scatter(ax, T.(xName)(idx), T.(yName)(idx), 64, ...
        'MarkerFaceColor', col, 'MarkerEdgeColor', [0.25,0.25,0.25], ...
        'MarkerFaceAlpha', 0.78, 'LineWidth', 0.6, 'DisplayName', upper(c));
end

x = double(T.(xName));
y = double(T.(yName));
valid = isfinite(x) & isfinite(y);
if sum(valid) >= 2
    p = polyfit(x(valid), y(valid), 1);
    xx = linspace(min(x(valid)), max(x(valid)), 100);
    yy = polyval(p, xx);
    plot(ax, xx, yy, '-', 'Color', palette.gray, 'LineWidth', 2.2, 'DisplayName', 'Linear fit');

    r = corrLocal(x(valid), y(valid));
    text(ax, 0.04, 0.94, sprintf('r = %.2f', r), 'Units','normalized', ...
        'FontName','Times New Roman','FontSize',13,'FontWeight','bold', ...
        'Color',[0.22,0.22,0.22], 'BackgroundColor','w', 'Margin',4);
end

xlabel(ax, xLab, 'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
ylabel(ax, yLab, 'FontName','Times New Roman','FontSize',15,'FontWeight','bold');
grid(ax, 'on'); box(ax, 'on');
legend(ax, 'Location','best', 'FontName','Times New Roman','FontSize',12, 'Box','off');
hold(ax, 'off');
end

function q = prctileLocal(x, p)
x = sort(x(:));
x = x(isfinite(x));
if isempty(x)
    q = NaN;
    return;
end
if numel(x) == 1
    q = x;
    return;
end
pos = 1 + (p/100)*(numel(x)-1);
lo = floor(pos);
hi = ceil(pos);
if lo == hi
    q = x(lo);
else
    q = x(lo) + (pos-lo)*(x(hi)-x(lo));
end
end

function r = corrLocal(x, y)
x = x(:); y = y(:);
valid = isfinite(x) & isfinite(y);
x = x(valid); y = y(valid);
if numel(x) < 2
    r = NaN;
else
    x = x - mean(x);
    y = y - mean(y);
    r = sum(x.*y) / max(sqrt(sum(x.^2)*sum(y.^2)), eps);
end
end

function col = countryColor(country, palette)
country = lower(string(country));
switch country
    case "ee"
        col = palette.blue;
    case "lt"
        col = palette.teal;
    case "nl"
        col = palette.rose;
    otherwise
        col = palette.orange;
end
end
