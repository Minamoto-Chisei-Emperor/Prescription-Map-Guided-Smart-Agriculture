function h = plotFieldBoundaryOnly(env, cfg)
%PLOTFIELDBOUNDARYONLY Plot only the real field boundary in local XY.

if nargin < 2 %#ok<INUSD>
    cfg = [];
end

hold on; axis equal; box on; grid on;
h = plot(env.field.poly, ...
    'FaceColor', 'none', ...
    'EdgeColor', [0.00 0.35 0.00], ...
    'LineWidth', 2.2);

xlabel('X (m)');
ylabel('Y (m)');
title(sprintf('Real field boundary (local coordinates): %s', env.field.name), 'Interpreter','none');
legend(h, {'Field boundary'}, 'Location', 'bestoutside');
hold off;
end
