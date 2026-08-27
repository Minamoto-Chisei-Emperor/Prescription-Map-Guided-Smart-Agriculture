function applyPaperFigureStyle(figHandle)
%APPLYPAPERFIGURESTYLE Apply publication-oriented font settings.
%
% The function uses Times New Roman for English text and adjusts axes and
% legend fonts without forcing all objects to the same font size.

if nargin < 1 || isempty(figHandle)
    figHandle = gcf;
end

set(findall(figHandle, '-property', 'FontName'), 'FontName', 'Times New Roman');

axesHandles = findall(figHandle, 'Type', 'axes');
for i = 1:numel(axesHandles)
    set(axesHandles(i), 'FontName', 'Times New Roman', 'FontSize', 10, 'LineWidth', 0.8);
    titleHandle = get(axesHandles(i), 'Title');
    if ~isempty(titleHandle)
        set(titleHandle, 'FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');
    end
    xlabelHandle = get(axesHandles(i), 'XLabel');
    ylabelHandle = get(axesHandles(i), 'YLabel');
    zlabelHandle = get(axesHandles(i), 'ZLabel');
    set(xlabelHandle, 'FontName', 'Times New Roman', 'FontSize', 10);
    set(ylabelHandle, 'FontName', 'Times New Roman', 'FontSize', 10);
    set(zlabelHandle, 'FontName', 'Times New Roman', 'FontSize', 10);
end

legendHandles = findall(figHandle, 'Type', 'legend');
for i = 1:numel(legendHandles)
    set(legendHandles(i), 'FontName', 'Times New Roman', 'FontSize', 9);
end

colorbarHandles = findall(figHandle, 'Type', 'ColorBar');
for i = 1:numel(colorbarHandles)
    set(colorbarHandles(i), 'FontName', 'Times New Roman', 'FontSize', 9);
end
end
