function plotParetoConvergencePaper(archive, history, best, cfg, caseTitle)
%PLOTPARETOCONVERGENCEPAPER Publication-style Pareto and convergence plot.
%
% Instead of using a visually cluttered 3D scatter alone, this function
% shows a normalized 2D Pareto archive distribution. Makespan and energy
% are used as axes, while drift penalty is represented by color. The second
% panel shows normalized convergence curves of the three objectives.

if nargin < 5 || isempty(caseTitle)
    caseTitle = 'Representative case';
end

obj = reshape([archive.objectives], 3, []).';
if isempty(obj)
    error('Archive is empty. Cannot plot Pareto archive.');
end

normObj = localNormalizeColumns(obj);
bestObj = best.objectives(:).';
normBest = localNormalizePoint(bestObj, obj);

try
    tiledlayout(1,2, 'TileSpacing','compact', 'Padding','compact');
    ax1 = nexttile;
catch
    subplot(1,2,1);
    ax1 = gca;
end

scatter(normObj(:,1), normObj(:,2), 52, normObj(:,3), 'filled', ...
    'MarkerEdgeColor', [0.18 0.18 0.18]);
hold on;
plot(normBest(1), normBest(2), 'p', 'MarkerSize', 13, ...
    'MarkerFaceColor', [0.95 0.10 0.10], 'MarkerEdgeColor', 'k', 'LineWidth', 0.9);
hold off;
grid on; box on;
xlabel('Normalized makespan');
ylabel('Normalized weighted energy');
title('(a) Pareto archive distribution');
cb = colorbar;
ylabel(cb, 'Normalized drift penalty');
try
    colormap(ax1, parula);
catch
    colormap(parula);
end
xlim([0, 1]); ylim([0, 1]);

try
    ax2 = nexttile;
catch
    subplot(1,2,2);
    ax2 = gca; %#ok<NASGU>
end

iters = (1:numel(history.bestMakespan)).';
c1 = localNormalizeVector(history.bestMakespan);
c2 = localNormalizeVector(history.bestEnergy);
c3 = localNormalizeVector(history.bestDrift);

plot(iters, c1, '-o', 'LineWidth', 1.4, 'MarkerSize', 4); hold on;
plot(iters, c2, '-s', 'LineWidth', 1.4, 'MarkerSize', 4);
plot(iters, c3, '-^', 'LineWidth', 1.4, 'MarkerSize', 4);
hold off;
grid on; box on;
xlabel('Iteration');
ylabel('Normalized best objective');
title('(b) Convergence behavior');
legend({'Makespan','Weighted energy','Drift penalty'}, 'Location','northeast');

sgtitle(caseTitle, 'FontName','Times New Roman', 'FontSize', 13, 'FontWeight','bold');
end

function Y = localNormalizeColumns(X)
Y = zeros(size(X));
for j = 1:size(X,2)
    x = X(:,j);
    mn = min(x);
    mx = max(x);
    if mx - mn < eps
        Y(:,j) = 0.5;
    else
        Y(:,j) = (x - mn) ./ (mx - mn);
    end
end
end

function y = localNormalizePoint(x, Xref)
y = zeros(size(x));
for j = 1:numel(x)
    mn = min(Xref(:,j));
    mx = max(Xref(:,j));
    if mx - mn < eps
        y(j) = 0.5;
    else
        y(j) = (x(j) - mn) ./ (mx - mn);
    end
end
y = max(0, min(1, y));
end

function y = localNormalizeVector(x)
x = x(:);
finiteMask = isfinite(x);
if ~any(finiteMask)
    y = nan(size(x));
    return;
end
mn = min(x(finiteMask));
mx = max(x(finiteMask));
if mx - mn < eps
    y = 0.5 * ones(size(x));
else
    y = (x - mn) ./ (mx - mn);
end
end
