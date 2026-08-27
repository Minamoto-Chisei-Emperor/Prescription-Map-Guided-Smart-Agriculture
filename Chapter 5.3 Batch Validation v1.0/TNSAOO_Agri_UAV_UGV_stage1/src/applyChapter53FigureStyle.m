function applyChapter53FigureStyle(fig)
%APPLYCHAPTER53FIGURESTYLE Apply publication style.

if nargin < 1 || isempty(fig)
    fig = gcf;
end

set(findall(fig,'-property','FontName'), 'FontName', 'Times New Roman');
set(findall(fig,'Type','axes'), 'FontName', 'Times New Roman', ...
    'FontSize', 13, 'LineWidth', 1.1, 'Box', 'on', ...
    'TickDir', 'out', 'Layer', 'top');

set(findall(fig,'Type','text'), 'FontName', 'Times New Roman');

% Make line and marker visuals more readable.
lines = findall(fig,'Type','line');
for i = 1:numel(lines)
    if get(lines(i), 'LineWidth') < 1.5
        set(lines(i), 'LineWidth', 1.5);
    end
end
end
