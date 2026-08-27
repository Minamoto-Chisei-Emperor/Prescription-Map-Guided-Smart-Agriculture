function plotBatchStatistics(Traw, outDir)
%PLOTBATCHSTATISTICS Generate simple publication-oriented batch figures.
% v1.4.3 is robust to string/cellstr table variables and NaN values.

ok = string(Traw.status) == "ok";
T = Traw(ok,:);

if height(T) == 0
    warning('No successful records for plotting.');
    return;
end

fieldCol = string(T.fieldName);
fieldNames = unique(fieldCol, 'stable');
n = numel(fieldNames);

makespan = nan(n,1);
energy = nan(n,1);
drift = nan(n,1);

for i = 1:n
    idx = fieldCol == fieldNames(i);
    makespan(i) = localMean(T.makespan(idx));
    energy(i) = localMean(T.weightedEnergy(idx));
    drift(i) = localMean(T.driftPenalty(idx));
end

fig1 = figure('Name','Batch objective means','Color','w');
try
    tiledlayout(3,1);
    nexttile;
catch
    subplot(3,1,1);
end

bar(makespan);
ylabel('Makespan (s)');
title('Mean makespan by field');
grid on;

try
    nexttile;
catch
    subplot(3,1,2);
end
bar(energy);
ylabel('Weighted energy');
title('Mean weighted energy by field');
grid on;

try
    nexttile;
catch
    subplot(3,1,3);
end
bar(drift);
ylabel('Drift penalty');
xlabel('Field index');
title('Mean drift penalty by field');
grid on;

safeExport(fig1, fullfile(outDir, 'batch_objective_means.png'));

fig2 = figure('Name','Area vs makespan','Color','w');
scatter(T.area_m2, T.makespan, 45, 'filled');
xlabel('Field area (m^2)');
ylabel('Makespan (s)');
title('Field area vs makespan');
grid on; box on;
safeExport(fig2, fullfile(outDir, 'batch_area_vs_makespan.png'));

fig3 = figure('Name','Conflict count distribution','Color','w');
cc = T.conflictCount;
cc = cc(~isnan(cc));
if isempty(cc)
    edges = [0 1];
else
    lo = floor(min(cc));
    hi = ceil(max(cc));
    if lo == hi
        edges = [lo, lo+1];
    else
        edges = lo:(hi+1);
    end
end
histogram(cc, edges);
xlabel('Conflict count');
ylabel('Frequency');
title('Air-ground conflict count distribution');
grid on; box on;
safeExport(fig3, fullfile(outDir, 'batch_conflict_distribution.png'));
end

function y = localMean(x)
x = x(:);
x = x(~isnan(x));
if isempty(x)
    y = NaN;
else
    y = mean(x);
end
end

function safeExport(fig, outPath)
try
    exportgraphics(fig, outPath, 'Resolution', 300);
catch
    saveas(fig, outPath);
end
end
