function plotParetoFront(archive, cfg)
%PLOTPARETOFRONT 3-D Pareto scatter plot.

if isempty(archive)
    warning('Empty archive.');
    return;
end
obj = reshape([archive.objectives], 3, []).';

scatter3(obj(:,1), obj(:,2), obj(:,3), 50, 'filled');
grid on; box on;
xlabel('Makespan (s)');
ylabel('Weighted energy');
zlabel('Pesticide drift penalty');
title('External Pareto archive');
view(135, 25);
end
