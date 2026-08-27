function h = plotFieldBoundaryOnly(env, cfg)
%PLOTFIELDBOUNDARYONLY Plot only the real field outer boundary.
%
% This function is designed for the second panel of the Chapter 5.1 figure:
% no prescription patches, no refill stations, no obstacles, no crop rows,
% and no depot are displayed.

if nargin < 2 %#ok<INUSD>
    cfg = [];
end

hold on; axis equal; box on; grid on;

h = plot(env.field.poly, ...
    'FaceColor', 'none', ...
    'EdgeColor', [0.00 0.35 0.00], ...
    'LineWidth', 2.4);

xlabel('X (m)');
ylabel('Y (m)');

title(sprintf('Real field boundary: %s', env.field.name), ...
    'Interpreter','none', ...
    'FontName','Times New Roman', ...
    'FontSize',20, ...
    'FontWeight','bold');


legend(h, {'Real field boundary'}, 'Location','bestoutside');

hold off;
end
