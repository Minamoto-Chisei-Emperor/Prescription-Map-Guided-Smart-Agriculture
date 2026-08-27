function plotData = prepareChapter53PlotData(Traw, summaryByField, dataDir)
%PREPARECHAPTER53PLOTDATA Save all plot-specific data.

ok = string(Traw.status) == "ok";
Tok = Traw(ok,:);

plotData = struct();
plotData.rawSuccessful = Tok;
plotData.fieldLevel = summaryByField;

% Objective distribution uses successful run-level records.
objectiveData = Tok(:, {'fieldName','country','seed','makespan','weightedEnergy','driftPenalty'});
writetable(objectiveData, fullfile(dataDir, 'plot_data_objective_distribution.csv'));
plotData.objectiveData = objectiveData;

% Area-cost relationship uses field-level mean data to avoid pseudo-replication.
areaData = summaryByField(:, {'fieldName','country','area_ha','shapeIndex','aspectRatio', ...
    'makespan_mean','totalPathLength_mean','weightedEnergy_mean','driftPenalty_mean'});
writetable(areaData, fullfile(dataDir, 'plot_data_area_cost_relationship.csv'));
plotData.areaData = areaData;

% Shape efficiency uses field-level mean, normalized by hectare.
shapeData = summaryByField(:, {'fieldName','country','area_ha','shapeIndex','compactness','aspectRatio', ...
    'ugvPathLengthPerHa_mean','totalPathLengthPerHa_mean','makespanPerHa_mean','weightedEnergyPerHa_mean'});
writetable(shapeData, fullfile(dataDir, 'plot_data_shape_efficiency.csv'));
plotData.shapeData = shapeData;

% Conflict distribution uses run-level records.
conflictData = Tok(:, {'fieldName','country','seed','conflictCount','totalWaitingTime','minAirGroundDistance'});
writetable(conflictData, fullfile(dataDir, 'plot_data_conflict_distribution_raw.csv'));

cc = Tok.conflictCount;
cc = cc(isfinite(cc));
if isempty(cc)
    cats = 0;
    counts = 0;
else
    maxC = max(cc);
    cats = 0:max(maxC, 3);
    counts = zeros(numel(cats),1);
    for i = 1:numel(cats)
        if cats(i) < max(cats)
            counts(i) = sum(cc == cats(i));
        else
            counts(i) = sum(cc >= cats(i));
        end
    end
end

labels = strings(numel(cats),1);
for i = 1:numel(cats)
    if i == numel(cats) && cats(i) >= 3
        labels(i) = string(sprintf('>=%.0f', cats(i)));
    else
        labels(i) = string(sprintf('%.0f', cats(i)));
    end
end

conflictHist = table(labels, counts, 'VariableNames', {'conflictCountBin','numberOfRuns'});
writetable(conflictHist, fullfile(dataDir, 'plot_data_conflict_count_histogram.csv'));

plotData.conflictData = conflictData;
plotData.conflictHist = conflictHist;
end
