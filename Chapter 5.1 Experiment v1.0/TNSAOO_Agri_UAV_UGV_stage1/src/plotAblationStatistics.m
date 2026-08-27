function plotAblationStatistics(summaryByMethod, outDir)
%PLOTABLATIONSTATISTICS Plot method comparison figures.

if isempty(summaryByMethod) || height(summaryByMethod) == 0
    warning('No summary data for ablation plotting.');
    return;
end

methods = string(summaryByMethod.method);
x = 1:numel(methods);

fig1 = figure('Name','Ablation objectives','Color','w');

try
    tiledlayout(3,1);
    nexttile;
catch
    subplot(3,1,1);
end
bar(x, summaryByMethod.makespan_mean);
set(gca, 'XTick', x, 'XTickLabel', cellstr(methods));
ylabel('Makespan (s)');
title('Mean makespan by method');
grid on;

try
    nexttile;
catch
    subplot(3,1,2);
end
bar(x, summaryByMethod.weightedEnergy_mean);
set(gca, 'XTick', x, 'XTickLabel', cellstr(methods));
ylabel('Weighted energy');
title('Mean weighted energy by method');
grid on;

try
    nexttile;
catch
    subplot(3,1,3);
end
bar(x, summaryByMethod.driftPenalty_mean);
set(gca, 'XTick', x, 'XTickLabel', cellstr(methods));
ylabel('Drift penalty');
title('Mean drift penalty by method');
grid on;

safeExport(fig1, fullfile(outDir, 'ablation_objective_means.png'));

fig2 = figure('Name','Ablation conflict/runtime','Color','w');
try
    tiledlayout(2,1);
    nexttile;
catch
    subplot(2,1,1);
end
bar(x, summaryByMethod.conflictCount_mean);
set(gca, 'XTick', x, 'XTickLabel', cellstr(methods));
ylabel('Conflict count');
title('Mean air-ground conflict count by method');
grid on;

try
    nexttile;
catch
    subplot(2,1,2);
end
bar(x, summaryByMethod.runtime_s_mean);
set(gca, 'XTick', x, 'XTickLabel', cellstr(methods));
ylabel('Runtime (s)');
title('Mean runtime by method');
grid on;

safeExport(fig2, fullfile(outDir, 'ablation_conflict_runtime.png'));
end

function safeExport(fig, outPath)
try
    exportgraphics(fig, outPath, 'Resolution', 300);
catch
    saveas(fig, outPath);
end
end
