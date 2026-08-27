function plotConvergence(history, cfg)
%PLOTCONVERGENCE Plot objective convergence curves.

iters = (1:numel(history.bestMakespan))';
plot(iters, history.bestMakespan, '-', 'LineWidth', 1.5); hold on;
plot(iters, history.bestEnergy, '-', 'LineWidth', 1.5);
plot(iters, history.bestDrift, '-', 'LineWidth', 1.5);
grid on; box on;
xlabel('Iteration');
ylabel('Best value in archive');
title('Convergence curves');
legend({'Makespan','Weighted energy','Drift penalty'}, 'Location','best');
hold off;
end
